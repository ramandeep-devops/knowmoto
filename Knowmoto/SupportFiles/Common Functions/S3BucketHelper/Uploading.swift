//
//  uploading.swift
//  Kabootz
//
//  Created by Sierra 4 on 13/07/17.
//  Copyright © 2017 Sierra 4. All rights reserved.
//


import UIKit
import Foundation
import AWSS3

class Uploading: NSObject {
  
    var fileName:String?
    var fullUrlPath : String?
    
    var uploadRequest:AWSS3TransferManagerUploadRequest?
    var transferManager:AWSS3TransferManager?
    
    var isAlreadyUploaded : Bool = false
    
    var imageThumb : UIImage?
    var isVideo = false
  
    init(name:String?,uploadRequest:AWSS3TransferManagerUploadRequest?, transferManager:AWSS3TransferManager?,isAlreadyUploaded : Bool) {
        
        self.fileName = /name
//        self.fullUrlPath = APIBasePath.BhiveUserBucket + /name
        self.uploadRequest = uploadRequest
        self.transferManager = transferManager
        self.isAlreadyUploaded = isAlreadyUploaded
    }
    
    override init() {
        super.init()
    }
}

