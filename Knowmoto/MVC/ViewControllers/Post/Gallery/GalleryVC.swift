//
//  GalleryVC.swift
//  Knowmoto
//
//  Created by Apple on 03/09/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

enum ENUM_SELECTED_GALLERY_TYPE:Int{
    
    case gallery = 0
    case camera
}

class GalleryVC: BaseVC {
    
    @IBOutlet weak var btnPhotos: UIButton!
    @IBOutlet weak var btnCamera: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        select(gallery: .gallery)
    }
    
    @IBAction func didTapPhotos(_ sender: UIButton) {
        
        select(gallery: .gallery)
        (topMostVC?.children.first as? GalleryPageViewController)?.setViewController(ofIndex: 0)
        
    }
    
    @IBAction func didTapCamera(_ sender: UIButton) {
        
       select(gallery: .camera)
        (topMostVC?.children.first as? GalleryPageViewController)?.setViewController(ofIndex: 1)
        
    }
    
    func select(gallery:ENUM_SELECTED_GALLERY_TYPE){
        
        switch gallery {
            
        case .camera:
            
            btnCamera.titleLabel?.font = ENUM_APP_FONT.xbold.size(16.0)
            btnPhotos.titleLabel?.font = ENUM_APP_FONT.book.size(16.0)
            
        case .gallery:
     
            btnPhotos.titleLabel?.font = ENUM_APP_FONT.xbold.size(16.0)
            btnCamera.titleLabel?.font = ENUM_APP_FONT.book.size(16.0)
            
        }
        
    }
    
    
    
    
}
