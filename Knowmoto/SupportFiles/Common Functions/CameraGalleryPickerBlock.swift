//
//  ImagePicker.swift
//  Grintafy
//
//  Created by Sierra 4 on 16/08/17.
//  Copyright © 2017 com.example. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVKit
import AVFoundation
import AVFoundation
import Photos
import PhotosUI

typealias onPicked = (UIImage , Data , ENUM_MEDIA_TPE) -> ()

class CameraGalleryPickerBlock: NSObject , UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    typealias videoThumbnailBlock = (_ thumbnail: UIImage?) -> ()
    typealias onCanceled = () -> ()
    
    
    var pickedListner : onPicked?
    var canceledListner : onCanceled?
    var isRectangularCropingEnable = false

    
    static let sharedInstance = CameraGalleryPickerBlock()
    
    override init() {
        super.init()
    }
    
    deinit{
        debugPrint("Deinitialized:-",String(describing:CameraGalleryPickerBlock.self))
    }
    
    
    func pickerImage(pickedListner : @escaping onPicked , canceledListner : @escaping onCanceled) {
        
        UtilityFunctions.showActionSheetWithStringButtons(cancelButtonTextColor: UIColor.BlueColor, backgroundColor:UIColor.white,buttons: [ENUM_MEDIA_PICKER_TYPE.camera.get() ,  ENUM_MEDIA_PICKER_TYPE.photoLibrary.get()], success: {[unowned self] (str) in
       
            if str ==  ENUM_MEDIA_PICKER_TYPE.camera.get().localized {
                
                
                CheckPermission.shared.permission(For: PermissionType.camera, completion: { [weak self] (isGranted) in
                    
                    if isGranted {
                        
                            self?.pickedListner   = pickedListner
                            self?.canceledListner = canceledListner
                        
                            self?.showCameraOrGallery(type: str)
                        
                    } else {
                        
                        self?.openAlertForSettings(for: .camera)
                        
                        return
                    }
                })
                
                
            } else {
                
                
                CheckPermission.shared.permission(For: PermissionType.photos, completion: { [weak self] (isGranted) in
                    
                    if isGranted {
                        
                        self?.pickedListner   = pickedListner
                        self?.canceledListner = canceledListner
                        
                        self?.showCameraOrGallery(type: str)
                        
                    } else {
                        
                        self?.openAlertForSettings(for: .photos)
                    }
                })
            }

        })
    }
    
  
    
    //Open camera or gallery
    func showCameraOrGallery(type : String){
        
        let picker : UIImagePickerController = UIImagePickerController()
        
        switch /type {
            
        case ENUM_MEDIA_PICKER_TYPE.camera.get():
            
            picker.sourceType = UIImagePickerController.SourceType.camera
            picker.mediaTypes = [kUTTypeImage as String]
            picker.cameraCaptureMode = .photo
            picker.allowsEditing = false
            

            
        case ENUM_MEDIA_PICKER_TYPE.takeAPhoto.get():
            
            picker.sourceType = UIImagePickerController.SourceType.camera
            picker.mediaTypes = [kUTTypeMovie as String , kUTTypeImage as String]
            picker.cameraCaptureMode = .video
            picker.videoQuality = UIImagePickerController.QualityType(rawValue: 1)!
            picker.videoMaximumDuration = 60
            picker.allowsEditing = false

            
        case ENUM_MEDIA_PICKER_TYPE.photoLibrary.get():
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            picker.allowsEditing = false

            
        case ENUM_MEDIA_PICKER_TYPE.videoGallery.get():
            
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            picker.mediaTypes = [kUTTypeMovie as String , kUTTypeMPEG4 as String , kUTTypeVideo as String , kUTTypeAVIMovie as String]
            picker.videoQuality = UIImagePickerController.QualityType(rawValue: 4)!
            picker.videoMaximumDuration = 60
            picker.allowsEditing = true

            
        default:
            break
        }
        
        picker.delegate = self
        DispatchQueue.main.async { [weak self] in
            
            self?.topMostVC?.present(picker, animated: true, completion: nil)
        }
    
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
        if let listener = canceledListner {
            listener()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
     
        if let edittedImage = info[.editedImage] as? UIImage {
            
            
            if let listener = self.pickedListner {
                
                if let imageData = edittedImage.jpegData(compressionQuality: 1){
                    
                    listener(edittedImage , imageData , .image)
                    
                }
                
            }
        }
        else if let fullImage = info[.originalImage] as? UIImage{
                        
            if let listener = self.pickedListner {
                
                if let imageData = fullImage.jpegData(compressionQuality: 1){
                    
                    listener(fullImage , imageData , .image)
                    
                }
            }
            
        }else if let  videoUrl = info[.mediaURL] as? URL {
            
            var thumbnail = UIImage()
            getVideoThumbanil(video: videoUrl.absoluteURL, responseBlock: { (img) in
                
                guard let thumb = img else {return}
                thumbnail = thumb
                
                do{
                    let videoData = try Data(contentsOf: videoUrl)
                    if let listener = self.pickedListner {
                        
                        listener(thumbnail , videoData , .video)
                    }
                }
                catch let error {
                    debugPrint("*** Error generating thumbnail: \(error.localizedDescription)")
                }
            })
        }
        
        DispatchQueue.main.async {
            
            picker.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    //Mark: - Generate thumbnail of video
    
    func getVideoThumbanil(video : URL , responseBlock : @escaping videoThumbnailBlock) {
        
        var thumbnail : UIImage?
        DispatchQueue.main.async(execute: { () in
            
            let asset = AVAsset.init(url: video)
            let assetImageGenerator = AVAssetImageGenerator(asset: asset)
            assetImageGenerator.appliesPreferredTrackTransform = true
            
            var time = asset.duration
            time.value = min(time.value, 2)
            
            do {
                let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
                thumbnail =  UIImage(cgImage: imageRef)
                
            } catch {
                debugPrint("error")
            }
            responseBlock(thumbnail)
        })
    }
    
}
