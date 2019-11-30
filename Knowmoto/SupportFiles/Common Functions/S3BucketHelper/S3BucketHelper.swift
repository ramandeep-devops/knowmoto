//
//  AWSBucket.swift
//  Kabootz
//
//  Created by Sierra 4 on 08/06/17.
//  Copyright © 2017 Sierra 4. All rights reserved.
//

import UIKit
import Foundation
import AWSS3
import AVFoundation
import AVKit


struct AWSConstants {
    
    static let S3BucketName = "knowmotodev"
    static let accessKey = "AKIAS74JC3GBF3TCE7XP"
    static let secretKey = "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"
    static let baseUrl = "https://static.knowmoto.com/"
}

enum media {
  
    case image
    case video
    case document
  
    func key() -> String {
        switch self {
        case .image: return "image.jpeg"
        case .video: return "video.mp4"
        case .document: return "document.pdf"
        }
    }
  
    func contentType() -> String {
        switch self {
        case .image: return "image/jpeg"
        case .video: return "video/mp4"
        case .document: return "application/pdf"
        }
    }
}

typealias returnReponse = (URL?) -> Void
typealias transferUtility = (AWSS3TransferManagerUploadRequest?, AWSS3TransferManager?) -> Void


class S3BucketHelper: NSObject {
  
    static let shared = S3BucketHelper()
    
    
    let videosFolder = "bhive/"
    
    private override init() {}
  
    //MARK: - Save Image -> return Path
    func returnImageUrl(data: Data) -> URL {
      
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("image\(arc4random()).jpeg")
      
        fileManager.createFile(atPath: path as String, contents: data, attributes: nil)
        let fileUrl = URL(fileURLWithPath: path)
        return fileUrl
    }
  
    
  func returnVideoUrl(data: Data) -> URL {
    
    let fileManager = FileManager.default
    let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("image\(arc4random()).mp4")
    
    fileManager.createFile(atPath: path as String, contents: data, attributes: nil)
    let fileUrl = URL(fileURLWithPath: path)
    return fileUrl
  }
  
  
    //MARK: - Create Upload Request Object
    func uploadRequest(data: Any? , fileName: String, mediaType: media,mimeType : String?) -> AWSS3TransferManagerUploadRequest {
      
        let uploadRequest = AWSS3TransferManagerUploadRequest()!
        
      
        switch mediaType {
          
        case .image:
            guard let imageData = data as? Data else {
                return uploadRequest
            }
            
            uploadRequest.body = self.returnImageUrl(data: imageData)
            uploadRequest.key = "\(fileName)"
            uploadRequest.bucket = AWSConstants.S3BucketName
            uploadRequest.contentType = mediaType.contentType()
            //  uploadRequest.acl = .publicRead
            return uploadRequest
          
        case .video:
            guard let videoUrl = data as? Data else {
                return uploadRequest
            }
            print(videoUrl)
            uploadRequest.body = self.returnImageUrl(data : videoUrl)
            uploadRequest.key = "\(fileName)"
            uploadRequest.bucket = AWSConstants.S3BucketName
            uploadRequest.contentType = mediaType.contentType()
            //   uploadRequest.acl = .publicRead
            return uploadRequest
            
            
        case .document :
            guard let documentUrl = data as? URL else {
                return uploadRequest
            }
            uploadRequest.body = documentUrl
            uploadRequest.key = "\(fileName)"
            uploadRequest.bucket = AWSConstants.S3BucketName
            uploadRequest.contentType = /mimeType
            //   uploadRequest.acl = .publicRead
            return uploadRequest
            
        }
    }
  
    //MARK: - Setup S3Bucket
    func setupForS3Bucket() {
        
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: AWSConstants.accessKey, secretKey: AWSConstants.secretKey)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.USWest2, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
  
    //MARK: - Upload Images/Videos
    func uploadRequest(data: Any?, fileName:String, mediaType: media ,mimeType : String?, oncompletion:@escaping returnReponse) -> (AWSS3TransferManagerUploadRequest, AWSS3TransferManager) {
        
        setupForS3Bucket()
      
        let uploadRequest = self.uploadRequest(data: data,  fileName: fileName, mediaType: mediaType,mimeType:mimeType)
        
        let transferManager = AWSS3TransferManager.default()
        
        transferManager.upload(uploadRequest).continueWith(block: { (task: AWSTask) -> Any? in
            //Loader.shared.stop()
            if let error = task.error {
                oncompletion(URL.init(string: ""))
                print("Upload failed with error: (\(error.localizedDescription))")
            }
          print(fileName)
          print(mediaType)
          
            let url = AWSS3.default().configuration.endpoint.url
            let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(/uploadRequest.key)
            //print("Uploaded to:\(publicURL)")
          
            if task.result != nil {
                
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(/uploadRequest.key)
                //                print("Uploaded to:\(publicURL)")
                oncompletion(publicURL)
            } else {
                oncompletion(URL.init(string: ""))
            }
            
            return nil
        })
        return (uploadRequest, transferManager)
    }
  
    //MARK: - Delete FIle from Bucket
    func deleteFile(name: String) {
        setupForS3Bucket()
        
        let transferManager = AWSS3.default()
        
        let deleteObjectRequest = AWSS3DeleteObjectRequest()
        deleteObjectRequest?.bucket = AWSConstants.S3BucketName
        
        deleteObjectRequest?.key = "\(name)"
        
        transferManager.deleteObject(deleteObjectRequest!).continueWith { (task:AWSTask) -> AnyObject? in
            if let error = task.error {
                print("Error occurred: \(error)")
                return nil
            }
            print("Deleted successfully.")
            return nil
        }
    }
  
    //MARK: - Remove Image
    func abortUpload(imageData:Uploading?) {
        
        guard let obj = imageData else { return }
        
        guard let uploadRequest = obj.uploadRequest else { return }
        
        switch uploadRequest.state {
            
        case .completed:
            self.deleteFile(name:/obj.fileName)
            
        default:
            self.cancelUpload(obj.transferManager)
        }
    }
  
    ////MARK: - Delete from AWS Bucket
    //func deleteFromBucket(_ fileName: String?) {
    //    guard let name = fileName else { return }
    //    S3BucketHelper.shared.deleteFile(name: name)
    //}
  
    //MARK: - Cancel AWS Upload
    func cancelUpload(_ transferManager: AWSS3TransferManager?) {
        transferManager?.cancelAll()
    }
    
//    //MARK: - Save video -> return Path
//    func getVideoOutputUrl() -> URL? {
//
//        let videosDirectoryPath = (/(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first) as NSString).appendingPathComponent("bhiveVideo/")
//
//        let fileManager = FileManager.default
//        if !fileManager.fileExists(atPath: videosDirectoryPath) {
//
//            do {
//                try fileManager.createDirectory(atPath: videosDirectoryPath,
//                                                withIntermediateDirectories: false,
//                                                attributes: nil)
//            } catch {
//                print("Error creating images folder in documents dir: \(error)")
//                return nil
//            }
//        }
//
//        let videoFilePath = (videosDirectoryPath as NSString).appendingPathComponent("\(uniqueVideoName())")
//        let fileUrl = URL(fileURLWithPath: videoFilePath)
//        return fileUrl
//    }
//
//    func getAudioOutputUrl() -> URL? {
//
//        let videosDirectoryPath = (/(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first) as NSString).appendingPathComponent("\(videosFolder)")
//
//        let fileManager = FileManager.default
//        if !fileManager.fileExists(atPath: videosDirectoryPath) {
//            do {
//                try fileManager.createDirectory(atPath: videosDirectoryPath,
//                                                withIntermediateDirectories: false,
//                                                attributes: nil)
//            } catch {
//                print("Error creating images folder in documents dir: \(error)")
//                return nil
//            }
//        }
//
//        let videoFilePath = (videosDirectoryPath as NSString).appendingPathComponent("\(uniqueAudioName()).m4a")
//        let fileUrl = URL(fileURLWithPath: videoFilePath)
//        return fileUrl
//    }
    
    func deleteExportedVideos() {
        let videosDirectoryPath = (/(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first) as NSString).appendingPathComponent("\(videosFolder)")
        
        do {
            let paths = try FileManager.default.contentsOfDirectory(atPath: videosDirectoryPath)
            for path in paths
            {
                try FileManager.default.removeItem(atPath: "\(videosDirectoryPath)/\(path)")
            }
        } catch {
            print("Error in deleting video \(error.localizedDescription)")
        }
    }
    
    
}


//MARK:- --------AWS Upload Functions---------
extension S3BucketHelper {
    
    func uploadImage(image: UIImage , completion:@escaping(_ original : String , _ thumbnail : String)->()) -> (Uploading , Uploading) {
        
        
        let fileName = "image_\(arc4random()).jpeg"
        let fileNameThumb = "image_\(arc4random()).jpeg"
        
        var originalUrl  : String?
        var thumbnailUrl : String?
        var isOriginalBlock = false
        var isThumbnailBlock = false
        var set: (AWSS3TransferManagerUploadRequest, AWSS3TransferManager)?
        var set1: (AWSS3TransferManagerUploadRequest, AWSS3TransferManager)?
        DispatchQueue.global(qos: .background).async {
            
            let resizedImage = /image.reduceSize(.high).jpeg(.high)
            
            set = S3BucketHelper.shared.uploadRequest(data:  resizedImage,
                                                          fileName: fileName,
                                                          mediaType: .image ,mimeType : nil) {(imageUrl) in
                                                            guard let url = imageUrl else { return completion("","")}
                                                            
                                                            isOriginalBlock = true
                                                            originalUrl = url.absoluteString
                                                            
                                                            if isOriginalBlock && isThumbnailBlock {
                                                                completion(/originalUrl , /thumbnailUrl)
                                                            }
                                                            debugPrint("orginal--------------------\(url)")
                                                            
            }
            
            let thumbImage = image.reduceSize(.lowest).jpeg(.low)
            
            set1 = S3BucketHelper.shared.uploadRequest(data: thumbImage,
                                                           fileName: fileNameThumb,
                                                           mediaType: .image ,mimeType : nil) {(imageUrl) in
                                                            guard let url = imageUrl else { return completion("","")}
                                                            
                                                            isThumbnailBlock = true
                                                            thumbnailUrl = url.absoluteString
                                                            
                                                            if isOriginalBlock && isThumbnailBlock {
                                                                completion(/originalUrl , /thumbnailUrl)
                                                            }
                                                            
                                                            debugPrint("thumb--------------------\(url)")
                                                            
            }
            
        }
        
        
        return (Uploading(name: fileName, uploadRequest: set?.0, transferManager: set?.1, isAlreadyUploaded: false) , Uploading(name: fileNameThumb, uploadRequest: set1?.0, transferManager: set1?.1, isAlreadyUploaded: false) )
    }
    
    
    
    
    private func uploadVideo(data: Data , image : UIImage , completion:@escaping()->())-> (Uploading , Uploading) {
        
        let fileName = "video_\(arc4random()).mp4"
        let fileNameThumb = "videoThumb\(arc4random()).jpeg"
        
        var isvideoBlock = false
        var isVideoThumbnailBlock = false
        
        
        let set = S3BucketHelper.shared.uploadRequest(data: data,
                                                      fileName: fileName,
                                                      mediaType: .video,mimeType : "mp4") { (videoUrl) in
                                                        guard let url = videoUrl else { return }
                                                        isvideoBlock = true
                                                        
                                                        if isvideoBlock && isVideoThumbnailBlock {
                                                            completion()
                                                        }
                                                        debugPrint("----videoIUpload\(url)")
        }
        
        
        let set1 =  S3BucketHelper.shared.uploadRequest(data:  /image.jpeg(.medium),
                                                        fileName: fileNameThumb,
                                                        mediaType: .image ,mimeType : nil) {(imageUrl) in
                                                            guard let url = imageUrl else { return }
                                                            
                                                            isVideoThumbnailBlock = true
                                                            
                                                            if isvideoBlock && isVideoThumbnailBlock {
                                                                completion()
                                                            }
                                                            
        }
        
        return (Uploading(name: fileName, uploadRequest: set.0, transferManager: set.1, isAlreadyUploaded: false) , Uploading(name: fileNameThumb, uploadRequest: set1.0, transferManager: set1.1, isAlreadyUploaded: false))
    }
    
    
    func abortUploadedImage(originalImage : Uploading? , thumbnail : Uploading?) {
        
        S3BucketHelper.shared.abortUpload(imageData: originalImage)
        S3BucketHelper.shared.abortUpload(imageData: thumbnail)
    }
    
    func setImage(indexPath:IndexPath? = nil,image:UIImage, dictImages : (Uploading , Uploading)? ,imageView:KnowmotoUIImageView? , completeion:@escaping(_ original :String , _ thumbnail : String,_ indexPath:IndexPath?)->()) -> (Uploading , Uploading) {//(original,thumbnail)
        
        if imageView?.image != nil {
            //            abortUploadedImage(originalImage: dictImages.0  , thumbnail: dictImages.1)
        }
        
        //        let activityIdicator = UIActivityIndicatorView(frame: imageView.frame)
        //        imageView.addSubview(activityIdicator)
        //        activityIdicator.activityIndicatorViewStyle = .gray
        //        activityIdicator.startAnimating()
    
        imageView?.image = image
        imageView?.addBlurLoadingEffect(with: nil)
        topMostVC?.dismiss(animated: true, completion: {
            
            //Note:-this code should be after dismiss call
         
            
        })
        
        
        
        return self.uploadImage(image: image, completion: { (original, thumbnail) in
            
            completeion(original , thumbnail,indexPath)
            if original.isEmpty || thumbnail.isEmpty{
                
                imageView?.setRetryLoadView()
                imageView?.didSelectPhoto = { [weak self] (button) in // retry upload on upload failed
                    
                    
                   _ = self?.setImage(image: image, dictImages: nil, imageView: imageView, completeion: completeion)
                }
                return
                
            }
            imageView?.removeLoadingBlurEffect()
            
            
        })
    }
    
    
}

