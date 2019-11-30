//
//  SpecialAttributeCell.swift
//  Knowmoto
//
//  Created by cbl16 on 14/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.


import UIKit

class SpecialAttributeCell: UITableViewCell {

    //MARK:- PROPERTIES
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(model:Any?){
        
        if let _model = model as? FeaturesListModel{
            
            lblTitle.text = /_model.feature
            
        }
        
    }
    
}
