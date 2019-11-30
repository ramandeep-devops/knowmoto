//
//  ImagePickerDataSource.swift
//  Grintafy
//
//  Created by Sierra 4 on 17/07/17.
//  Copyright © 2017 com.example. All rights reserved.
//

import Foundation
import UIKit

typealias  SelectedImageBlock = (_ selectedImage: UIImage) -> ()

class ImagePickerDataSource:NSObject{
    
    var picker:UIImagePickerController?
    var aSelectedImageBlock: SelectedImageBlock?
    
    init(picker: UIImagePickerController? ,allowEditing: Bool, sourceType: UIImagePickerController.SourceType  ,  aSelectedImageBlock:SelectedImageBlock?){
        super.init()
        self.picker = picker
        self.picker?.delegate = self
        guard let safeMediaType = UIImagePickerController.availableMediaTypes(for: .photoLibrary) else{return}
         picker?.allowsEditing = allowEditing
        picker?.mediaTypes = safeMediaType
        picker?.sourceType = sourceType
        self.aSelectedImageBlock = aSelectedImageBlock
    }
    
    override init() {
        super.init()
    }
}

extension ImagePickerDataSource:UINavigationControllerDelegate , UIImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let chosenImage = info[.originalImage] as? UIImage else{return}
        if let block = self.aSelectedImageBlock , let image =  chosenImage as UIImage?{
            block(image)
        }
        
    }

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
