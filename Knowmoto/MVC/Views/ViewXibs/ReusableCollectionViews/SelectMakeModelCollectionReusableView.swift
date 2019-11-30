//
//  SelectMakeModelCollectionReusableView.swift
//  Knowmoto
//
//  Created by Apple on 08/10/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class SelectMakeModelCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var containerViewSelectedTypes: UIView!
    @IBOutlet weak var containerViewSearchField: UIView!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnRemove: KnomotButton!
    @IBOutlet weak var imageViewBrand: KnowmotoUIImageView!
    @IBOutlet weak var btnSelected: UIButton!
    @IBOutlet weak var searchField: KnowmotoSearchTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
}
