//
//  CustomPopUpView.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/17/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.


import Foundation
import KontaktSDK

protocol AddBeaconDelegate:class{
    func didBeaconAdded(model:Any)
}

class AddBeaconPopup:CustomPopUp{
    
    @IBOutlet weak var textFeldBeaconId: KnowMotoTextField!
    @IBOutlet weak var textFieldBeaconCompany: KnowMotoTextField!
    
    var userData = UserDefaultsManager.shared.loggedInUser
    
    weak var delegates: AddBeaconDelegate?
    var devicesManager: KTKDevicesManager!
    var bluetoothManager:CBCentralManager!
    
    var arrayNearestDetectedBeaconsId:[String] = []
    
    func instanceFromNib() -> UIView {
        
        return UINib(nibName: "AddBeaconPopUp", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.popUpView = self.instanceFromNib()
        self.popUpView.frame = frame
        
        devicesManager = KTKDevicesManager(delegate: self)
        bluetoothManager = CBCentralManager()
        bluetoothManager.delegate = self
        
        if devicesManager.centralState == bluetoothManager.state {
            devicesManager.startDevicesDiscovery(withInterval: 1.0)
            //  devicesManager.startDevicesDiscovery()
        }
        
        
        
        super.initialSetup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func validate()-> Bool{
        
        let valid = Validations.sharedInstance.validateAddbeaconPopup(beaconId:textFeldBeaconId.text!, beaconName:textFieldBeaconCompany.text!)
        
        switch valid{
            
        case .success:
            
            return true
            
        case .failure(let message):
            
            Toast.show(text: message, type: .error)
            return false
            
        }
    }
    
    @IBAction func didTapInfo(_ sender: UIButton) {
        
        self.alertBox(message: "Learn more and get a beacon at knowmoto.com".localized, okButtonTitle: "knowmoto.com", title: "Info") { [weak self] in
            
            self?.topMostVC?.openHyperLink(link: "http://knowmoto.com/")
            
        }
        
    }
    
    @IBAction func didTapDone(_ sender: UIButton) {
        
        self.endEditing(true)
        //delegates?.BeaconAdded()
        if validate(){
            
            let addBeaconModel = BeaconlistModel(beaconId:/textFeldBeaconId.text, beaconCompany:/textFieldBeaconCompany.text)
            
            if bluetoothManager.state != .poweredOn{
                
                self.alertBoxOk(message: "Please on your bluetooth connection, need to detect your beacon is available.".localized, title: "Bluetooth powered off".localized) {
                }
                
                return
            }
            
            if /arrayNearestDetectedBeaconsId.contains(/textFeldBeaconId.text){
                
                EP_Profile.add_beacons(id: nil, beaconId:addBeaconModel.beaconId, beaconCompany:addBeaconModel.beaconCompany , userId:userData?.id , isActive:nil).request(success:{ [weak self] (response) in
                    
                    let _response = (response as? BeaconlistModel)
                    
                    self?.delegates?.didBeaconAdded(model: _response)
                    self?.dismissPopUp()
                    
                })
                
            }else{
                
                self.alertBoxOk(message: "No beacon found with '\(/textFeldBeaconId.text)' id. Please make sure beacon is within range.", title: "Not found".localized) {
                }
                
            }
            
        }
    }
    
}

extension AddBeaconPopup:KTKDevicesManagerDelegate,CBCentralManagerDelegate{
    
    
    func devicesManager(_ manager: KTKDevicesManager, didDiscover devices: [KTKNearbyDevice]) {
        
        arrayNearestDetectedBeaconsId = devices.map({/$0.uniqueID})
        
        for device in devices {
            
            if let uniqueId = device.uniqueID {
         
//                let batteryLevel = device.batteryLevel
                
                print("Detected a beacon \(uniqueId)")
                
            } else {
                
                print("Detected a beacon with an unknown Unique ID")
                
            }
            
        }
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .poweredOn:
            devicesManager.startDevicesDiscovery(withInterval: 1.0)
            print("Bluetooth is on")
            break
        case .poweredOff:
            print("Bluetooth is Off.")
            break
        case .resetting:
            break
        case .unauthorized:
            print("Bluetooth is on")
            break
        case .unsupported:
            print("Bluetooth is on")
            break
        case .unknown:
            print("Bluetooth is on")
            break
        default:
            break
        }
    }
    
}
