//
//  CarsCollectionViewCell.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/4/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit
import AWSS3

class CarsCollectionViewCell: UICollectionViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var imageViewBeaconConnected: UIImageView!
    @IBOutlet weak var viewTransparency: UIView!
    
    @IBOutlet weak var imageViewSelecteditem: UIImageView!
    @IBOutlet weak var imageViewCarOrBrand: KnowmotoUIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    //MARK:- Properties
    var vcType:ENUM_CAR_SELECTION_TYPE = .make
    var model:Any?{
        didSet{
            configureCell()
        }
    }
    var selectedModels:Any?
    var isMake:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        
        self.imageViewCarOrBrand.image = nil
        
    }
    
    private func configureCell(){
        
        var isSelected:Bool = false
        
        if let _model = model as? BrandOrCarModel {
            
            if let selectedModel = (selectedModels as? [BrandOrCarModel]){
                
                isSelected = selectedModel.contains(where: {$0.id == _model.id})
                
            }
            
            lblName.text = vcType == .model ? [/_model.name,/_model.year?.toString].joined(separator: " ") : /_model.name
            imageViewCarOrBrand.loadImage(key: /_model.image?.first?.original,cacheKey: _model.image?.first?.originalImageKey)
            
        }else if let _model = model as? FeaturesListModel {
            
            if let selectedModel = (selectedModels as? [FeaturesListModel]){
                
                isSelected = selectedModel.contains(where: {$0.id == _model.id})
            }
                lblName.text = /_model.name
                imageViewCarOrBrand.loadImage(key: /_model.image?.first?.thumb, cacheKey: _model.image?.first?.thumbImageKey)
            
        }else if let _model = model as? CarListDataModel{
            
            if let selectedModel = (selectedModels as? [BrandOrCarModel]){
                
                isSelected = selectedModel.contains(where: {$0.id == _model.id})
                
            }
            
            lblName.text = isMake ? /_model.name : /_model.displayAppName
            imageViewCarOrBrand.loadImage(key: /_model.image?.first?.thumb, cacheKey: _model.image?.first?.thumbImageKey)
            imageViewBeaconConnected.isHidden = isMake || /_model.beaconID?.isEmpty
            
        }
    
        viewTransparency.backgroundColor = /isSelected ? UIColor.black.withAlphaComponent(0.5) : UIColor.clear
        imageViewSelecteditem.isHidden = !isSelected
    }
    

    
}
