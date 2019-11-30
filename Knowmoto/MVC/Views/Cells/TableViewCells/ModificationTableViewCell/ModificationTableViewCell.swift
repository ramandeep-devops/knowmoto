//
//  ModificationCell.swift
//  Knowmoto
//
//  Created by cbl16 on 14/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class ModificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblPartNoAndPart: UILabel!
    @IBOutlet weak var lblBrandName: UILabel!
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var btnRemove: KnomotButton!
    
    var model:Any?{
        didSet{
            configureCell()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    private func configureCell(){
        
        guard let _data = model as? ModificationType else {
            return
        }
        
        lblBrandName.text = _data.brandData?.name ?? /_data.brandData?.customBrandName
        lblCategoryName.text = /_data.modificationData?.category
        lblPartNoAndPart.text = /_data.partNumber?.isEmpty || _data.partNumber == nil ? "\(/_data.part)" : "\(/_data.partNumber) · \(/_data.part)"
        
    }
    
    
}
