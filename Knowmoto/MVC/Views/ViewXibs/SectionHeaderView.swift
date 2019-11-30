//
//  SectionHeaderView.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/4/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation
import UIKit

class SectionHeaderView:UIView{
    
    @IBOutlet weak var constraintCenterAlign: NSLayoutConstraint!
    @IBOutlet weak var btnEdit: UIButton!
    
    @IBOutlet weak var imageViewOfName: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    
    //Instanstiate nib
    class func instanceFromNib() -> SectionHeaderView {
        
        return UINib(nibName: "SectionHeaderView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView as! SectionHeaderView
    }
    
    func setViewAll(array:Array<Any>,showOnCountAfter:Int = 5){
        
        btnEdit.setTitle("View All".localized, for: .normal)
        btnEdit.setImage(nil, for: .normal)
        btnEdit.setTitleColor(UIColor.HighlightSkyBlueColor!, for: .normal)
        
        btnEdit.isHidden = array.count < showOnCountAfter
    }

}
