//
//  ExtensionCameraReportVC.swift
//  SpocH
//
//  Created by Apple on 26/09/18.
//  Copyright © 2018 CodeBrewLabs. All rights reserved.
//

import Foundation
import AVKit

extension CameraVC{
    
    
    func setupCaptureSession(){
        
        captureSession.sessionPreset = AVCaptureSession.Preset.medium // Why exclamation point?
        sessionQueue = DispatchQueue(label: "session queue")
    }
    
    func setupDevice(position: AVCaptureDevice.Position){
        let availableDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: .video, position: position)
        let devices = availableDevice.devices //back or front
        
        for device in devices {
            if position == .front && device.position == .front{
                self.captureDevice = device
            } else if device.position == .back {
                self.captureDevice = device
            }
        }
     
    }
    
    
    func setupInputOutput(){
      
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice!)
           
            if captureSession.canAddInput(captureDeviceInput){
                captureSession.addInput(captureDeviceInput)
            }
            
            capturePhotoOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddOutput(capturePhotoOutput!){
                
                capturePhotoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format:[AVVideoCodecKey:AVVideoCodecType.jpeg])], completionHandler: nil)
                captureSession.addOutput(capturePhotoOutput!)
                
            }
        }
        catch{
            print(error)
            
        }
    }
    
    func setupPreviewLayer(){
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        videoPreviewLayer?.frame = self.view.layer.bounds
        self.view.layer.insertSublayer(videoPreviewLayer!, at: 0)
    }
    
    func startRunningCaptureSession(){
        captureSession.startRunning()
    }

    func toggleCamera(){
        
        captureSession.stopRunning()
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                captureSession.removeInput(input)
            }
        }
        
        captureSession.beginConfiguration()
        setupCaptureSession()
        setupDevice(position: isFrontCamera ? .back : .front)
        setupInputOutput()
        isFrontCamera = !isFrontCamera
        captureSession.commitConfiguration()
        startRunningCaptureSession()
        
    }
    
    func takePhoto(){
        
        
        // Make sure capturePhotoOutput is valid
        
        let photoSettings = AVCapturePhotoSettings()
        
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        
        captureButton.isUserInteractionEnabled = false
        
        // Get an instance of AVCapturePhotoSettings class
        
        
        // Set photo settings for our need
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = false
        photoSettings.flashMode = isFlashOn ? .on : .off
        
        
        // Call capturePhoto method by passing our photo settings and a delegate implementing AVCapturePhotoCaptureDelegate
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        
    }
    
}

extension CameraVC : AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
//            messageLabel.isHidden = true
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
//                messageLabel.isHidden = false
//                messageLabel.text = metadataObj.stringValue
            }
        }
    }
}

extension UIInterfaceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeRight: return .landscapeRight
        case .landscapeLeft: return .landscapeLeft
        case .portrait: return .portrait
        default: return nil
        }
    }
}
