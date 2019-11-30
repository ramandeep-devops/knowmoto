//
//  CheckPermission.swift
//  Kabootz
//
//  Created by Sierra 4 on 13/06/17.
//  Copyright © 2017 Sierra 4. All rights reserved.
//


import Photos
import Contacts
import Foundation
import AddressBook

enum PermissionType {
    
    case camera
    case photos
    case locationAlwaysInUse
    case contacts
    case microphone
    
}


class CheckPermission {
    
    static let shared = CheckPermission()
    
    
    //MARK: - Check Permission
    func permission(For : PermissionType , completion: @escaping (Bool) -> () ) {
        
        switch status(For: For) {
            
        case 0 :
            switch For {
            case .camera:
                AVCaptureDevice.requestAccess(for: AVMediaType.video , completionHandler: { (value) in
                    completion(value)
                })
                
            default:
                completion(true)
            }
            
        case 1,2:
            completion(false)
            
        case 3:
            
            switch For {
                
            case .camera:
                
                AVCaptureDevice.requestAccess(for: AVMediaType.video , completionHandler: { (value) in
                    completion(value)
                })
                
            case .photos:
                
                PHPhotoLibrary.requestAuthorization() { (value) -> Void in
                    
                    switch value {
                        
                    case .authorized :
                        completion(true)
                        
                    case  .denied, .restricted:
                        return completion(false)
                    // as above
                    case .notDetermined:
                        return completion(false)
                        // won't happen but still
                    }
                }
                
            default:
                completion(true)
            }
            
           
            
        default:
            completion(true)
        }
    }
    
    
    //MARK: - Check Status
    private func status(For: PermissionType) -> Int {
        
        switch For {
            
        case .camera:
            return AVCaptureDevice.authorizationStatus(for: AVMediaType.video).rawValue
            
        case .contacts:
            if #available(iOS 9.0, *) {
                return CNContactStore.authorizationStatus(for: .contacts).rawValue
            } else {
                return PHPhotoLibrary.authorizationStatus().rawValue
            }
            
        case .locationAlwaysInUse:
            guard CLLocationManager.locationServicesEnabled() else { return 2 }
            return Int(CLLocationManager.authorizationStatus().rawValue)
            
        case .photos:
            let status =  PHPhotoLibrary.authorizationStatus()
            switch status {
                
            case .authorized ,.denied, .restricted :
                return status.rawValue
                
            //handle denied status
            case .notDetermined:
                return 3
                
            }
            
        case .microphone:
            let recordPermission = AVAudioSession.sharedInstance().recordPermission
            return Int(recordPermission.rawValue)
            
        }
        
    }
    
}
