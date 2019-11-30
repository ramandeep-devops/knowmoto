//
//  SelectedCarsListTableViewCell.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/4/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class SelectedCarsListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblModelsSelected: UILabel!
    @IBOutlet weak var imageViewBrand: KnowmotoUIImageView!
    @IBOutlet weak var btnSelectModel: UIButton!
    @IBOutlet weak var lblBrandName: UILabel!
    
    var selectedBrands:Any?{
        didSet{
            configureCell()
        }
    }
    
    var associatedCars:Any?{
        didSet{
            configureAssociatedOrBookMarkCarCell()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func configureCell(){
        
        guard let _model = selectedBrands as? BrandOrCarModel else {return}
        lblBrandName.text = /_model.name
        
        imageViewBrand.loadImage(nameInitial: lblBrandName.text,key: /_model.image?.first?.original)
        
        lblModelsSelected.isHidden = /_model.arraySelectedModels?.isEmpty || _model.arraySelectedModels == nil
        let modelsPluralString = /_model.arraySelectedModels?.count == 1 ? "Model" : "Models"
        lblModelsSelected.text = "\(/_model.arraySelectedModels?.count) \(modelsPluralString) Selected"
        btnSelectModel.setTitle(/_model.arraySelectedModels?.isEmpty || _model.arraySelectedModels == nil ? "Select Models" : "Edit Selection", for: .normal)
        
    }
    
    private func configureAssociatedOrBookMarkCarCell(){
        
        guard let _model = associatedCars as? CarListDataModel else {return}
        
        let image = /_model.image?.first?.thumb
        let cacheKey = /_model.image?.first?.thumbImageKey
        
        btnSelectModel.isHidden = true
        lblModelsSelected.isHidden = true
        let name = _model.type == 1 ? /_model.name : _model.type == 2 ? /_model.make?.first?.name + " " + /_model.name :  /_model.displayAppName
        lblBrandName.text = name
        imageViewBrand.loadImage(nameInitial: name,key: image,cacheKey: cacheKey)
       
        
    }
    
    
}
