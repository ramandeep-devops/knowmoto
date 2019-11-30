//
//  ViewController.swift
//  Camera
//
//  Created by Rizwan on 16/06/17.
//  Copyright © 2017 Rizwan. All rights reserved.
//

import UIKit
import AVFoundation

//class DocumentImage{
//
//    var tempImage:UIImage?
//    var originalImage:UIImage?
//    var selectedFilter : Int = 0
//    var asset:DKAsset?
//
//    init(originalImage:UIImage?,asset:DKAsset?) {
//        self.originalImage = originalImage
//        self.tempImage = originalImage
//        self.asset = asset
//    }
//}

class CameraVC: BaseVC,PhotosVCDelegate {
    
    //MARK: - --------Oultes-------
 

    @IBOutlet weak var btnFlash: UIButton!
    @IBOutlet weak var btnFlipCamera: UIButton!
    @IBOutlet weak var lblImageCount: UILabel!
    @IBOutlet weak var imageViewCapturedImage: UIImageView!
    @IBOutlet weak var btnCapturedImages: UIButton!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    
     //MARK: - --------Properties-----------
    
    var captureSession: AVCaptureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    var qrCodeFrameView: UIView?
    var totalCapturedImages = 0
    var captureDevice:AVCaptureDevice?
    var sessionQueue: DispatchQueue!
    var isFlashOn:Bool = false{
        didSet{


        }
    }
    var isFrontCamera:Bool = false
    var maxNumberOfPhotos:Int = 5
    
    
    var arrayImages = [ImageUpload](){
        didSet{
            btnCapturedImages.isUserInteractionEnabled = arrayImages.count != 0
            self.lblImageCount?.isHidden = self.arrayImages.count == 0
            self.lblImageCount?.text = String(/self.arrayImages.count)
            self.btnNext.isHidden = /arrayImages.isEmpty
        }
    }

    deinit {
      
    }
     //MARK: - --------View controller lifecycle-----------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        checkPermission()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
       
    }

    func checkPermission(){
        
        CheckPermission.shared.permission(For: PermissionType.camera, completion: { [weak self] (isGranted) in
            
            if isGranted {
                
                DispatchQueue.main.async {
                    
                    self?.setupCaptureSession()
                    self?.setupDevice(position: .back)
                    self?.setupInputOutput()
                    self?.setupPreviewLayer()
                    self?.startRunningCaptureSession()
                    
                }
         
            } else {
                
                DispatchQueue.main.async {
                    
//                    self?.openAlertForSettings(for: .camera)
                    self?.stackViewPermission.isHidden = false
                    self?.btnFlash.isHidden = true
                    self?.btnCapturedImages.isHidden = true
                    self?.btnFlipCamera.isHidden = true
                    self?.lblImageCount.isHidden = true
                    self?.captureButton.isHidden = true
                    
                }
                
                return
            }
        })
        
    }
    
    func setupUI(){
        
        btnNext.isHidden = true
        
        captureButton.layer.cornerRadius = captureButton.frame.size.width / 2
        captureButton.clipsToBounds = true
        lblImageCount.isHidden = true
        
        captureButton.isExclusiveTouch = true
        
        
    }
    
     //MARK: - --------Button Action------------
    
    
    @IBAction func didTapFlash(_ sender: UIButton) {
        
        isFlashOn = !isFlashOn
        
        sender.setImage(isFlashOn ? #imageLiteral(resourceName: "ic_flash_on") : #imageLiteral(resourceName: "ic_flash_off") , for: .normal)
        
    }
    
    @IBAction func didTapNext() {
        
        let vc = ENUM_STORYBOARD<PostVC>.post.instantiateVC()
        vc.arrayPics = self.arrayImages
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction override func didTapDismiss(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func didTapRotateCamera(_ sender: UIButton) {
   
        toggleCamera()
        
    }
   
    @IBAction func onTapTakePhoto(_ sender: Any) {
        
        if arrayImages.count < maxNumberOfPhotos {
            takePhoto()
        }else{
            Toast.show(text: "Maximum limit reached".localized, type: .error)
        }
        
    }

    func addImage(image:UIImage){

        totalCapturedImages += 1
        imageViewCapturedImage.image = image

        arrayImages.append(ImageUpload(image: image))
    }
    
    func didRemovePic(newArray: Any?) {
        
        self.arrayImages = (newArray as? [ImageUpload]) ?? []
        totalCapturedImages = self.arrayImages.count
        imageViewCapturedImage.image = self.arrayImages.last?.image
        
    }
    
}

//MARK: ------- AVCapture delegates-----

extension CameraVC : AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput,didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,resolvedSettings: AVCaptureResolvedPhotoSettings,bracketSettings: AVCaptureBracketedStillImageSettings?,error: Error?) {
        
        // Make sure we get some photo sample buffer
        guard error == nil,
            let photoSampleBuffer = photoSampleBuffer else {
                debugPrint("Error capturing photo: \(String(describing: error))")
                return
        }
        
        // Convert photo same buffer to a jpeg image data by using AVCapturePhotoOutput
        guard let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
            return
        }
        
        // Initialise an UIImage with our image data
        let capturedImage = UIImage.init(data: imageData , scale: 1.0)
        if let image = capturedImage {
            
            self.addImage(image: image)
            captureButton.isUserInteractionEnabled = true
            // Save our captured image to photos album
//            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
}


