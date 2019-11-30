//
//  TextTableViewCell.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/4/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit
import MapboxGeocoder

class TextTableViewCell: UITableViewCell {

    @IBOutlet weak var btnAdd: UIButton!
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
        
        if let _item = model as? LocationAddress{
       
            lblTitle.text = ["\(/_item.name)","\(/_item.state)"].joined(separator: /_item.state?.isEmpty ? "" : ", ") //_item.address //[/_item.name,/_item.state].joined(separator: ",")
            
        }else if let _item = (model as? GeocodedPlacemark){
            
            let state = (_item.addressDictionary?["state"] as? String) ?? ""
            let address = ["\(/_item.name)","\(/state)"].joined(separator:  /state.isEmpty ? "" : ", ")
            ///_item.qualifiedName  //"\(/_item.name), \(/state)"
            
            lblTitle.text = address
            
        }
        
    }
    
}
