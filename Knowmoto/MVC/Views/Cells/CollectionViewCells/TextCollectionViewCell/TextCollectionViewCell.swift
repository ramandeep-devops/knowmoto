//
//  TextCollectionViewCell.swift
//  Knowmoto
//
//  Created by Apple on 14/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class TextCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var imageViewSelected: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    var model:Any?{
        didSet{
            configureModelListCell()
        }
    }
    var selectedModels:Any?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureModelListCell(){
        
        if let _model = model as? BrandOrCarModel {
            
            var isSelected:Bool = false
            if let selectedModel = (selectedModels as? [BrandOrCarModel]){
                
                isSelected = selectedModel.contains(where: {$0.id == _model.id})
                
            }
            lblName.text = /_model.name
            imageViewSelected.isHidden = !isSelected
            
        }
        
    }

}
