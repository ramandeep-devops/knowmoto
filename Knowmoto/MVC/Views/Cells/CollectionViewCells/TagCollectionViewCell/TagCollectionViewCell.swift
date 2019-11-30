//
//  TagCollectionViewCell.swift
//  Knowmoto
//
//  Created by Apple on 12/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageViewHistoryIcon: UIImageView!
    @IBOutlet weak var lblTagName: UILabel!
    @IBOutlet weak var btnSelectedTag: UIButton!
    @IBOutlet weak var viewContainer: UIView!
    
    var model:Any?{
        didSet{
            configureCell()
        }
    }
    var tagString:String?{
        didSet{
            configureTagCollectionCell()
        }
    }
    
    var recentTag:Any?{
        didSet{
            self.configureRecentTagCollectionCell()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        
    }

    
    func configureCellWithSelection(selectedTag:[String]?,tagName:String){
        
        //UI setup
        
        let isSelected = selectedTag?.contains(tagName)
        
        viewContainer.backgroundColor = /isSelected ? UIColor.white.withAlphaComponent(0.15) : UIColor.clear
        lblTagName.textColor = /isSelected ? UIColor.white : UIColor.white.withAlphaComponent(0.5)
        btnSelectedTag.setImage(#imageLiteral(resourceName: "ic_selected_white"), for: .normal)
        viewContainer.layer.borderColor = /isSelected ? UIColor.white.cgColor : UIColor.white.withAlphaComponent(0.5).cgColor
        //data set
        btnSelectedTag.isHidden = true
        lblTagName.text = /tagName
    }
    
    private func configureCell(){
        
        guard let _model = model as? BrandOrCarModel else{return}
        
        //UI setup
        viewContainer.backgroundColor = /_model.isSelected ? UIColor.BackgroundLightSky2BlueColor : UIColor.clear
        btnSelectedTag.isHidden = !(/_model.isSelected)
        lblTagName.textColor = /_model.isSelected ? UIColor.white : UIColor.HighlightSkyBlueColor!
        btnSelectedTag.setImage(#imageLiteral(resourceName: "ic_selected_white"), for: .normal)
        
        //data set
        lblTagName.text = /_model.name
//        lblTagName.sizeToFit()
        
    }
    
    private func configureTagCollectionCell(){

        //UI setup
        viewContainer.layer.cornerRadius = viewContainer.frame.height/2
        viewContainer.clipsToBounds = true
        viewContainer.backgroundColor = UIColor.BackgroundLightSky2BlueColor
        lblTagName.textColor = UIColor.white
        
        //data set
        lblTagName.text = /tagString
        //        lblTagName.sizeToFit()
        
    }
    
    private func configureRecentTagCollectionCell(){
        
        //UI setup
        viewContainer.layer.cornerRadius = 4
        viewContainer.clipsToBounds = true
        viewContainer.backgroundColor = UIColor.clear
        lblTagName.textColor = UIColor.white
        imageViewHistoryIcon.isHidden = false
        btnSelectedTag.isHidden = true
                //data set
        lblTagName.font = ENUM_APP_FONT.bold.size(14.0)
        lblTagName.textColor = UIColor.HighlightSkyBlueColor
        lblTagName.text = /(recentTag as? SearchDataModel)?.tagName
        //        lblTagName.sizeToFit()
        
    }
    
}
