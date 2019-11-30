//
//  SearchTableViewCell.swift
//  Knowmoto
//
//  Created by Apple on 17/09/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    var searchModel:Any?{
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
        
        if let model = searchModel as? SearchDataModel{
            
            let searchType = ENUM_MAIN_SEARCH_TYPE(rawValue: /model.type)
            
            let (subtitle,title) = searchType?.getTitleSubtitle(model) ?? ("","")
            
            lblTitle.text = title
            lblSubtitle.text = subtitle
        }
        
    }
    

}
