//
//  HeadingCollectionCell.swift
//  Knowmoto
//
//  Created by cbl16 on 02/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class WalkthroughCollectionViewCell: UICollectionViewCell {
        
    //MARK:- OUTLETS
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var imageViewScreens: UIImageView!
    
    var model:Any?{
        didSet{
            configureCell()
        }
    }
    
    
    func configureCell(){
        
        guard let _model = model as? WalkThroughScreenModel else {return}
        
        imageViewScreens?.image = _model.image
        lblTitle?.text = _model.title
        lblSubtitle?.text = _model.subtitle
        
    }
}
