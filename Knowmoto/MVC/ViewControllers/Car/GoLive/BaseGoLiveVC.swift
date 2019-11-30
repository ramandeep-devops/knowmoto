//
//  BaseGoLiveVC.swift
//  Knowmoto
//
//  Created by Apple on 18/09/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit
import KontaktSDK

//var liveCarTimers:[String:Timer] = [:]

class BaseGoLiveVC: BaseKontaktVC {
    
    enum ENUM_TIME_FRAME:String{
        
        case hrs = "Hrs"
        case days = "Days"
        case min = "min"
        
        var timeFrame:[Int]{
            switch self {
                
            case .hrs,.days,.min:
                
                return Array(1...12)
                
            }
        }
        
        func getSeconds(timeFrame:Int) ->Int64{
            
            switch self {
                
            case .hrs:
                
                return Int64(timeFrame * 3600)

            case .min:

                return Int64(timeFrame * 60)
                
            case .days:
                
                return Int64(timeFrame * 86400)
                
            }
            
        }
        
    }
    
    //MARK:- Outlets
    
    @IBOutlet weak var textFieldTimeFrameType: UITextField!
    @IBOutlet weak var textFieldTimeFrame: UITextField!
    
    //picker views
    var dataSourcePickerViewTimeFrame:PickerViewCustomDataSource?
    var dataSourcePickerViewTimeFrameType:PickerViewCustomDataSource?
    
    let pickerViewTimeFrame = UIPickerView()
    let pickerViewTimeFrameType = UIPickerView()
    
    var arrayPickerViewTimeFrameType:[String] = [ENUM_TIME_FRAME.hrs.rawValue,ENUM_TIME_FRAME.days.rawValue]
    
    var selectedCar:CarListDataModel?
    var timeFrameType:ENUM_TIME_FRAME = .hrs{
        didSet{
            if oldValue != timeFrameType{
                self.changePickerViewTimeFrame()
            }
        }
    }

    //MARK:- View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        intialSetup()
    }
    
    
    func intialSetup(){
        
        configureTimeFramePickerView(textField: textFieldTimeFrame, pickerView: pickerViewTimeFrame, arrayItems: timeFrameType.timeFrame)
        configureTimeFrameTypePickerView(textField: textFieldTimeFrameType, pickerView: pickerViewTimeFrameType, arrayItems: arrayPickerViewTimeFrameType)
        
        askLocationPermission()
    }
    
    
    func askLocationPermission(){
        
        LocationManager.shared.askPermission(blockPermissionGranted: nil)
        
    }
    
    
    //MARK:- ACTIONS
    
    @IBAction func didTapGoLive(_ sender: Any) {
    
        LocationManager.shared.checkPermission { [weak self] (granted) in
            
            if granted{
                
                #if targetEnvironment(simulator)
                
                self?.goToLocationOfGoingLiveVC()
                
                #else
                
                if /self?.checkBeaconAndStartDiscovering(){
                    
                    self?.searchBeaconOf(id: /self?.selectedCar?.beaconID?.first?.beaconId, completion: { [weak self] (isFound) in
                        
                        
                        if isFound{
                            
                            self?.goToLocationOfGoingLiveVC()
                            
                        }
                        
                        
                    })
                    
                }
                
                #endif
                
                
            }
            
            
            
        }
        
    }
    
    func goToLocationOfGoingLiveVC(){
        
     
        let vc = ENUM_STORYBOARD<WhereToGoLiveMapVC>.map.instantiateVC()
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
        
    }
 
    
    //MARK:- Configuration of pickerview and collection View
    
    //Time frame
    func configureTimeFramePickerView(textField:UITextField,pickerView:UIPickerView,arrayItems:[Any]){
        
        textField.inputView = pickerView
        textField.tintColor = UIColor.clear
        pickerView.backgroundColor = UIColor.backGroundHeaderColor!
        
        dataSourcePickerViewTimeFrame = PickerViewCustomDataSource(textField: textField, picker: pickerView, items: arrayItems, columns: 1) { (selectedRow, item) in
            
            debugPrint(item)
            textField.text = String(/(item as? Int))
            
        }
        
        dataSourcePickerViewTimeFrame?.aSelectedBlock = { [weak self] (selectedRow,item) in
            
            self?.view.endEditing(true)
            textField.text = String(/(item as? Int))
        }
        
        dataSourcePickerViewTimeFrame?.titleForRowAt = { [weak self] (row,component)-> String in
            
            return (self?.dataSourcePickerViewTimeFrame?.pickerData[row] as? Int)?.toString ?? ""
            
        }
        
    }
    
    //Time frame type (Hrs,min)
    func configureTimeFrameTypePickerView(textField:UITextField,pickerView:UIPickerView,arrayItems:[Any]){
        
        textField.inputView = pickerView
        textField.tintColor = UIColor.clear
        pickerView.backgroundColor = UIColor.backGroundHeaderColor!
        
        dataSourcePickerViewTimeFrameType = PickerViewCustomDataSource(textField: textField, picker: pickerView, items: arrayItems, columns: 1) { (selectedRow, item) in
            
            debugPrint(item)
            textField.text = String(/(item as? String))
            
        }
        
        dataSourcePickerViewTimeFrameType?.aSelectedBlock = { [weak self] (selectedRow,item) in
            
            self?.view.endEditing(true)
            textField.text = String(/(item as? String))
            
            let selectedType = ENUM_TIME_FRAME.init(rawValue: /textField.text) ?? .hrs
            
            self?.timeFrameType = selectedType
        }
        
        dataSourcePickerViewTimeFrameType?.titleForRowAt = { (row,component)-> String in
            
            return arrayItems[row] as? String ?? ""
            
        }
        
    }
    
    //change array items of time frame according to type change
    func changePickerViewTimeFrame(){
        
        //setting new time frame (hrs,min)
        dataSourcePickerViewTimeFrame?.pickerData = self.timeFrameType.timeFrame
        
        textFieldTimeFrame.text = self.timeFrameType.timeFrame.first?.toString
        
        //reloading components (set to first index)
        pickerViewTimeFrame.reloadComponent(0)
        pickerViewTimeFrame.selectRow(0, inComponent: 0, animated: false)
        
    }
    
}

extension BaseGoLiveVC:MBMapVCDelegate{
    
    func didEndLiveSessionOf(vehicle: CarListDataModel) {
        
        (topMostVC?.presentingViewController as? GoLiveVC)?.reloadDataOf(vehicle: vehicle)
        
    }
    
    
    func didSelectLocationForGoLive(location: CLLocationCoordinate2D?) {
        
        let selectedTimeFrame = Int(/self.textFieldTimeFrame.text)
        let totalSeconds = self.timeFrameType.getSeconds(timeFrame: (selectedTimeFrame ?? 0))
        
        if location != nil{
            
            self.apiGoLive(seconds: totalSeconds, toLocation: location!)
            
        }else{
            
            self.alertBoxOk(message: "Location not detected".localized, title: "Alert!".localized, ok: {})
            
        }
        
    }
    
    func apiGoLive(seconds:Int64,toLocation:CLLocationCoordinate2D){
        
        //go live

        let jsonLocation = [toLocation.longitude,toLocation.latitude].toJsonString()
        
        EP_Car.add_edit_car(id: selectedCar?.id, name: nil, makeId: nil, year: nil, country: nil, nickName: nil, beaconId: nil, modificationType: nil, image: nil, featureId: nil, sponsorId: nil, sponsors: nil, location: jsonLocation, features: nil, isLiveExpiry: seconds).request(loaderNeeded: true, successMessage: nil, success: { [weak self] (response) in
            
            //adding timestamp to live car to check when should end session
            self?.selectedCar?.liveExpiryTimeStamp = Date().millisecondsSince1970 + Double((seconds * 1000))
            self?.selectedCar?.location?.coordinates = [toLocation.longitude,toLocation.latitude]
            
            //saving this for check any car is live right now
            var liveVehicles = UserDefaultsManager.shared.liveCar
            if liveVehicles == nil{
                liveVehicles = LiveVehicleModal()
            }
            
            liveVehicles?.liveCars?.append((self?.selectedCar)!)
            UserDefaultsManager.shared.liveCar = liveVehicles
            
            //starting updating user location for tracking other following users to find location
            LocationManager.shared.startUpdateLocation()
            
            //start timer
            Timer.scheduledTimer(withTimeInterval: TimeInterval(seconds), repeats: false, block: { (timer) in
                
                self?.apiEndLiveCar(liveCar: self?.selectedCar)
                
            })
            
            
            //redirect to map
            
            self?.dismiss(animated: true, completion: { [weak self] in
                
                let vc = ENUM_STORYBOARD<MBMapVC>.map.instantiateVC()
                vc.isFromMyLive = true
                vc.selectedFromPreviousScreen = self?.selectedCar
                vc.presentWithNavigationController()
//                self?.topMostVC?.present(vc, animated: true, completion: nil)
                
            })
            
            
        }) { (error) in
            
        }
        
    }
  
}
