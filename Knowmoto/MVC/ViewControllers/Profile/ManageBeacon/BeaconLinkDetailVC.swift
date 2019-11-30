
//  BeaconDetailVC.swift
//  Knowmoto

//  Created by cbl16 on 12/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.


import UIKit


class BeaconLinkDetailVC: BaseVC {
    
    //MARK:- OUTLETS
    
    @IBOutlet weak var viewLinked: UIView!
    @IBOutlet weak var viewUnlinked: UIView!
    @IBOutlet weak var lblBeaconId: UILabel!
    @IBOutlet weak var lblBeaconCompany: UILabel!
    @IBOutlet weak var imgBeacon: KnowmotoUIImageView!
    @IBOutlet weak var lblCarModelName: UILabel!
    
    //MARK:- PROPERTIES
    
    var beaconData:BeaconlistModel?
    var isBeaconLinked:Bool?
    var arrayBeaconList = [BeaconlistModel]()
    var indexPath:IndexPath?
    //MARK:- LIFE CYCLE METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initialSetup()
        
    }
    
    func initialSetup(){
        
        setData()
        
        isBeaconLinked = beaconData?.vehicle?.id != nil
        
        checkBeaconlinkedOrNot()
        
        actionRemoveBeacon()
        
    }
    
    func setData(){ //set data
        
        lblBeaconId.text = "Beacon ID : \(/beaconData?.beaconId)"
        lblBeaconCompany.text = /beaconData?.beaconCompany
        
        imgBeacon.loadImage(key: /beaconData?.vehicle?.image?.first?.original,cacheKey:/beaconData?.vehicle?.image?.first?.originalImageKey)
        
        lblCarModelName.text = /beaconData?.vehicle?.nickName
    }
    
    //MARK:- EXTRA FUNCTION
    func checkBeaconlinkedOrNot(){
        // checked for beacin is linked or not
        
        self.viewUnlinked.isHidden = /isBeaconLinked
        self.viewLinked.isHidden = !(/isBeaconLinked)
        
    }
    
    func actionRemoveBeacon(){ //action remove beacon
        
        headerView?.headerView.didTapRightButton = { [weak self] (sender) in
            
            self?.alertBox(message: /self?.isBeaconLinked ? "Do you really want to remove this beacon, attached vehicle to this beacon will automatically unlinked".localized : "Do you really want to remove this beacon?".localized, title:/self?.isBeaconLinked ? "Remove Beacon?".localized : "Unlink vehicle?".localized) { [weak self] in
                
                self?.apiRemoveBeacon()
                
            }
            
        }
        
    }
    
    //MARK:- Actions
    
    // unlike action
    @IBAction func didTapUnlike(_ sender: Any) {
        
        self.alertBox(message: "Do you really want to unlink vehicle from this beacon?".localized, title: "Unlink vehicle?".localized) { [weak self] in
            
            self?.apiLinkDlinkCar(ofType: 2)
            
        }
        
    }
    
    // link car action
    @IBAction func didTapLinkCar(_ sender: Any) {
        
        
        let vc = ENUM_STORYBOARD<AddCarStep1SelectMakeVC>.car.instantiateVC()
        vc.vcType = .myCars
        vc.selectedData = []
        vc.delegate = self
        self.navigationController?.present(vc, animated: true, completion: nil)
        
    }
    
    
    func apiLinkDlinkCar(ofType:Int,linkVehicleId:String? = nil){ //type 1 for link 2 for dlink
        
        EP_Profile.link_with_vehicle(id: beaconData?.id, vehicleId:linkVehicleId ?? beaconData?.vehicle?.id, type: ofType).request(loaderNeeded: true, successMessage: nil, success: { (response) in
            
            Toast.show(text: ofType == 1 ? "Vehicle linked successfully".localized : "Vehicle unlinked successfully".localized, type: .success)
            
            NotificationCenter.default.post(name: .PROFILE_UPDATE, object: nil)
            
            self.navigationController?.popViewController(animated: true)
            
        }) { (error) in
            
        }
        
    }
    
    func apiRemoveBeacon(){ //api remove beacon
        
        EP_Profile.remove_beacon(id: beaconData?.id).request(success:{ [weak self] (response) in
            
            NotificationCenter.default.post(name: .PROFILE_UPDATE, object: nil)
            
            Toast.show(text: "Beacon removed successfully.".localized, type: .success)
            self?.arrayBeaconList.remove(at: /self?.indexPath?.item)
            self?.navigationController?.popViewController(animated: true)
            
        })
        
    }
    
}


extension BeaconLinkDetailVC:SelectMakeOrBrandOrModelVCDelegate{
    
    func didSelectFeatures(model: Any?) {}
    
    
    func didSelectMyCar(model: Any?) {
        
        apiLinkDlinkCar(ofType: 1, linkVehicleId: (model as? CarListDataModel)?.id)
        
    }
    
}
