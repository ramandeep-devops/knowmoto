//
//  AddCarSelectModelReusableView.swift
//  Knowmoto
//
//  Created by Apple on 16/09/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class AddCarSelectModelReusableView: UICollectionReusableView {
    
    @IBOutlet weak var textFieldSelectYear: KnowMotoTextField!
    @IBOutlet weak var lblMakeName: UILabel!
    @IBOutlet weak var imageViewMake: KnowmotoUIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    func configureView(model:AddEditCarViewModel?){
        
        self.imageViewMake?.loadImage(key: /model?.makeId?.image?.first?.thumb, isLoadWithSignedUrl: false)
        self.lblMakeName?.text = /model?.makeId?.name
        
    }
    
}
