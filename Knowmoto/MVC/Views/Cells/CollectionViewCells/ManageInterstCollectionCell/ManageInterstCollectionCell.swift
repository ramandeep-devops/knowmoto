//
//  ManageInterstCollectionCell.swift
//  Knowmoto
//
//  Created by cbl16 on 10/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class ManageInterstCollectionCell: UICollectionViewCell {
    
    //MARK:- Properties
    
    @IBOutlet weak var imageViewMake: KnowmotoUIImageView!
    @IBOutlet weak var lblMakeName: UILabel!
    @IBOutlet weak var lblNoOfModelSelected: UILabel!
    
    var manageInterestData:Any?{
        didSet{
            configureManageInterestDataCell()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func prepareForReuse() {
        
        self.imageViewMake.image = nil
        
    }
    
    
    func configureManageInterestDataCell(){
        
        if let data = (manageInterestData as? ModelSelectedInterestedMakes){
            
            lblMakeName.text = /data.makeId?.name
            
            let models = data.modelIds
            lblNoOfModelSelected.text = "\((/models?.isEmpty ? "No" : /models?.count.toString)) Models selected"
            imageViewMake.loadImage(key: /data.makeId?.image?.first?.thumb, cacheKey: /data.makeId?.image?.first?.thumbImageKey)
        }
        
    }

}
