//
//  ManageBeaconTableViewCell.swift
//  Knowmoto
//
//  Created by cbl16 on 10/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class ManageBeaconTableViewCell: UITableViewCell {
    
    //MARK:- OUTLETS
    
    @IBOutlet weak var imageViewBattery: UIImageView!
    @IBOutlet weak var lblBattery: UILabel!
    @IBOutlet weak var imgBeacon: UIImageView!
    @IBOutlet weak var lblBeaconName: UILabel!
    @IBOutlet weak var lblBeaconID: UILabel!
    @IBOutlet weak var lblLinkedTo: UILabel!
    
    //MARK:- PROPERTIES
    let beaconMangerDataSource = KontaktBeaconDataSource()
    
    var model:Any?{
        didSet{
            configureCell()
        }
    }
    var batteryLevel:UInt?{
        didSet{
            
            imageViewBattery.isHidden = self.batteryLevel == nil
            lblBattery.isHidden = self.batteryLevel == nil
            lblBattery.text = String(self.batteryLevel ?? 0) + "%"
            
        }
    }
    
    private func configureCell(){
        
        guard let  _model = model as? BeaconlistModel else {return}
        lblBeaconName.text = /_model.beaconCompany!
        lblBeaconID.text =  "Beacon ID : \(/_model.beaconId!)"
        
        
        lblLinkedTo.attributedText = _model.vehicle?.id == nil ? NSAttributedString(string: "Not Linked to any Vehicle yet".localized) :
        "Linked to '\(/_model.vehicle?.nickName)'".setAttributedTextColorOf(stringToChange: /_model.vehicle?.nickName, color: UIColor.lightGray, font: ENUM_APP_FONT.bold.size(14))
     
        
        
        beaconMangerDataSource.getBatteryStatusOfId(OfId: /_model.beaconId) { [weak self] (battery) -> Bool in
            
            self?.batteryLevel = battery
            debugPrint("battery:-",battery)
            return true
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
 
}
