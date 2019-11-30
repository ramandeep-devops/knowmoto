//
//  BasicInfoAndDetailCell.swift
//  Knowmoto
//
//  Created by cbl16 on 14/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class BasicInfoAndDetailCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    var model:Any?{
        didSet{
            configureCell()
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
    
    func configureCell(){
        
        if let _model = model as? BasicInfoModel{
            
            lblName.text = /_model.name
            lblTitle.text = /_model.title
            
        }
    }
    
}
