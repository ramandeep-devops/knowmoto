//
//  CarsListCollectionViewCell.swift
//  Knowmoto
//
//  Created by Apple on 31/07/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class CarsListCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var btnLive: UIButton!
    @IBOutlet weak var lblLikesSubtitle: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imageViewCar: KnowmotoUIImageView!
    
    var isMake:Bool = false
    var model:Any?{
        didSet{
            configureCell()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell() {
        
        if let _model = model as? CarListDataModel{
            
            imageViewCar.loadImage(key: /_model.image?.first?.original, isLoadWithSignedUrl: false, cacheKey: /_model.image?.first?.originalImageKey, placeholder: nil)
       
            lblTitle.text = isMake ? /_model.name : /_model.displayAppName
            lblLikesSubtitle.text = [/_model.totalLikes?.toString,"Trophy Points"].joined(separator: " ")//  "0K Likes"
            btnLive.isHidden = !(/_model.isLive)
        }
        
    }

    
    
}
