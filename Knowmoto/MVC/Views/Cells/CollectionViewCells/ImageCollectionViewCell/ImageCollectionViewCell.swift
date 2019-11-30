//
//  ImageCollectionViewCell.swift
//  Knowmoto
//
//  Created by Apple on 13/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit
import Photos

class ImageCollectionViewCell: UICollectionViewCell {
    
    //MARK:- Outlets
    
    @IBOutlet weak var highlightedView: UIView!
    @IBOutlet weak var btnAddItemView: UIButton!
    @IBOutlet weak var imageViewPhoto: KnowmotoUIImageView!
    @IBOutlet weak var btnRemove: UIButton!
    
    var galleryData:Any?{
        didSet{
            configureGalleryCell(isSelected: isSelected)
        }
    }
    
    override var isSelected: Bool{
        didSet{
            
            if galleryData != nil{
                
                self.highlightedView.isHidden = false
                
                self.highlightedView.alpha = /isSelected ? 1.0 : 0.0
                
                self.btnRemove.isHidden = false
                
                self.btnRemove.alpha = /isSelected ? 1.0 : 0.0
                
            }
            
        }
    }
    
    var selectedGalleryPics:Any?
    
    //MARK:- View controller lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.btnAddItemView.addDottedBorder(cornerRadius: 8, color: UIColor.HighlightSkyBlueColor!)
        }
        
    }
    
    func configureForAddPicCell(indexPath:IndexPath,model:Any?){
        
        let modelData = (model as? ImageUpload)
        let isAddButton = /modelData?.isAddButton
        let isImageUploaded = modelData?.isImageUploaded
        let image = modelData?.image
        
        if /modelData?.isLoadFromUrl{
            
            imageViewPhoto.loadImage(key: /modelData?.thumbnail, isLoadWithSignedUrl: true)
    
        }else{
            
            imageViewPhoto.image = image
        }
        
        btnRemove.isHidden = isImageUploaded == false || isAddButton
        
        btnRemove.tag = indexPath.item
        
        imageViewPhoto.isHidden = isAddButton
        btnAddItemView.isHidden = !isAddButton
        
    }
    
    func configureGalleryCell(isSelected:Bool){
        
        if let galleryData = galleryData as? PHAsset{
            DispatchQueue.main.async {
                
                let image = galleryData.getAssetThumbnail(size: CGSize(width: self.frame.width * 3, height: self.frame.height * 3))
                
                self.imageViewPhoto.layer.cornerRadius = 4
                
                

                self.btnRemove.setImage(#imageLiteral(resourceName: "ic_selected"), for: .normal)
                
                self.imageViewPhoto.image = image
                
            }
        }
        
    }
    
    func setImage(_ asset: PHAsset) {
        
        DispatchQueue.main.async {
            
            let image = asset.getAssetThumbnail(size: CGSize(width: self.frame.width * 3, height: self.frame.height * 3))
            self.imageViewPhoto.image = image
            
        }
        
    }
    
    func setImage(_ image: UIImage) {
        self.imageViewPhoto.image = image
    }
    
}

extension PHAsset {
    
    // MARK: - Public methods
    
    func getAssetThumbnail(size: CGSize) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: self, targetSize: size, contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
            if let image = result{
            thumbnail = image
            }
        })
        
        return thumbnail
    }
    
    func getOrginalImage(complition:@escaping (UIImage) -> Void) {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        var image = UIImage()
        manager.requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: option, resultHandler: {(result, info)->Void in
            
            if let result = result{
                image = result
                complition(image)
            }
           
        })
    }
    
    func getImageFromPHAsset() -> UIImage {
        var image = UIImage()
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        requestOptions.isSynchronous = true
        
        if (self.mediaType == PHAssetMediaType.image) {
            PHImageManager.default().requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: requestOptions, resultHandler: { (pickedImage, info) in
                image = pickedImage!
            })
        }
        return image
    }
    
}
