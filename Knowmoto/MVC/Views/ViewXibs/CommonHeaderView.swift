//
//  CommonHeaderView.swift
//  Knowmoto
//
//  Created by Apple on 29/07/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation
import UIKit


class CommonHeaderView:UIView{
    
    //MARK:- Properties
    @IBOutlet weak var btnRight2: UIButton!
    @IBOutlet weak var viewPercentage: UIView!
    @IBOutlet weak var widthConstraintPercentageView: NSLayoutConstraint!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var imageViewTitle: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnLeft: UIButton!
    
    var didTapLeftButton:((UIButton)->())?
    var didTapRightButton:((UIButton)->())?
    var didTapRightButton2:((UIButton)->())?
    
    //Instanstiate nib
    class func instanceFromNib() -> CommonHeaderView {
        
        return UINib(nibName: "CommonHeaderView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView as! CommonHeaderView
    }
    

    
    @IBAction func didTapLeftButton(_ sender: UIButton) {
        
        didTapLeftButton?(sender)
        
    }
    
    @IBAction func didTapRightButton(_ sender: UIButton) {
        
        didTapRightButton?(sender)
    }
    
    @IBAction func didTapRight2Button(_ sender: UIButton) {
        
        didTapRightButton2?(sender)
    }
}
