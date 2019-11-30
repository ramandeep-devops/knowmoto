//
//  SponsorCollectionViewCell.swift
//  Knowmoto
//
//  Created by Apple on 14/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class SponsorCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var imageViewLiveTag: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnRemove: UIButton!
    @IBOutlet weak var imageViewSponsor: KnowmotoUIImageView!
    
    var isFromCarDetail:Bool = false
    var initialsImage:UIImage?
    var collectionView:UICollectionView?

    let highlightLayer = CALayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {

        self.imageViewSponsor.image = nil
    }

    func configureSponsorCell(indexPath:IndexPath,item:Any?){
        
        btnRemove.tag = indexPath.item
        
        let modelData = item as? FeaturesListModel
   
        DispatchQueue.main.async {
            
            self.imageViewSponsor.loadImage(nameInitial:/modelData?.name,key: /(modelData)?.image?.first?.thumb,isLoadWithSignedUrl: self.isFromCarDetail,cacheKey:/(modelData)?.image?.first?.thumbImageKey)
            
        }
     
        self.layoutIfNeeded()
        
        lblName.text = (item as? FeaturesListModel)?.name
        
    }
    
    func configureGoLiveCell(model:Any?,selectedItem:Any?){
        
        if let carData = model as? CarListDataModel{
            
            if let selectedCar = selectedItem as? CarListDataModel{
                
                let isSelected = carData.id == selectedCar.id
                
                btnRemove.isHidden = !isSelected //btn remove as selected tick icon
                self.contentView.alpha = isSelected ? 1.0 : 0.5
                
                //highlight layer
                
                highlightLayer.backgroundColor = UIColor.black.withAlphaComponent(0.2).cgColor
                highlightLayer.frame = imageViewSponsor.bounds

                if isSelected{

                    highlightLayer.removeFromSuperlayer()
                    imageViewSponsor.layer.insertSublayer(highlightLayer, at: 1)

                }else{

                    highlightLayer.removeFromSuperlayer()

                }
                
                btnLike.isUserInteractionEnabled = isSelected
                
            }else{
                
                btnLike.isUserInteractionEnabled = false
                highlightLayer.removeFromSuperlayer()
                self.contentView.alpha = 0.5
            }
            
            btnLike.isSelected = /carData.likeByMe
            imageViewSponsor.loadImage(key: /carData.image?.first?.original,cacheKey: /carData.image?.first?._id)
            lblName.text = /carData.displayAppName
            btnRemove.setImage(#imageLiteral(resourceName: "ic_check_white"), for: .normal)
           
      
        }
    
    }
    
    
    func configureActiveLiveCars(model:Any?){
        
        if let carData = model as? CarListDataModel{
        
            imageViewLiveTag.isHidden = false
            imageViewSponsor.loadImage(key: /carData.image?.first?.original,cacheKey: /carData.image?.first?.originalImageKey)
            lblName.text = /carData.displayAppName
            btnRemove.isHidden = true
            
            //highlight layer
            let highlightLayer = CALayer()
            highlightLayer.backgroundColor = UIColor.black.withAlphaComponent(0.2).cgColor
            highlightLayer.frame = imageViewSponsor.bounds
            imageViewSponsor.layer.insertSublayer(highlightLayer, at: 1)
            
        }
        
    }
    
}
