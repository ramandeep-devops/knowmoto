//
//  PostCarsCollectionViewCell.swift
//  Knowmoto
//
//  Created by Apple on 31/07/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class PostCarsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var btnRemove: UIButton!
    @IBOutlet weak var highlightedView: UIView!
    @IBOutlet weak var imageViewSelected: UIImageView!
    @IBOutlet weak var imageViewCar: KnowmotoUIImageView!
    
    var model:Any?{
        didSet{
            configureCell()
        }
    }
    var isLoadThumb:Bool = true
    var isLoadWithSignedUrl:Bool = false
    
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(){
        
       
        if let _model = model as? ImageUrlModel{
            
            imageViewCar.loadImage(key: isLoadThumb ? /_model.thumb : /_model.original, isLoadWithSignedUrl: isLoadWithSignedUrl, cacheKey: isLoadThumb ? /_model.thumbImageKey : /_model.originalImageKey)
            
        }else if let image = model as? UIImage{
            
            imageViewCar.image = image
            
        }
        
    }
    
  
    
    
}
