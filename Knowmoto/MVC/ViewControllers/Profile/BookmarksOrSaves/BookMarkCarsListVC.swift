//
//  BookMarkCarsListVC.swift
//  Knowmoto
//
//  Created by Apple on 30/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit
import KontaktSDK
import CoreBluetooth

protocol BookMarkCarsListVCDelegate:class {
    func didSelectCar(car:Any?)
}

class BookMarkCarsListVC: UIViewController {
    
    
    //MARK:- Outlets
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var stackViewSearchingBeacons: UIStackView!
    @IBOutlet weak var searchField: KnowmotoSearchTextField!
    @IBOutlet weak var searchHeaderView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Properties
    
    private var customDataSource:TableViewDataSource?
    var arrayCars:[CarListDataModel] = []{
        didSet{
            arrayCars.isEmpty ? self.setTableViewBackgroundView(tableview: tableView, noDataFoundText: vcType == .nearby ? "No nearby vehicles found!".localized : "No data found!".localized) : (tableView.backgroundView = nil)
        }
    }
    
    var vcType:ENUM_BOOKMARKED_VC_TYPE?
    weak var delegate:BookMarkCarsListVCDelegate?
    
    //common
    var limit:Int = 20
    var skip:Int = 0
    var isFirstTime:Bool = true
    var selectedCar:CarListDataModel?
    var isFromCreatePost:Bool = false
    
    //beacon
    private var devicesManager: KTKDevicesManager!
    private var bluetoothManager:CBCentralManager!
    
    private var tempArrayNearestDetectedBeaconsId:[String] = []
    private var arrayNearestDetectedBeaconsId:[String] = []
    
    //MARK:- View controller lifecycle
    var timer:Timer?
    
    deinit {
        timer?.invalidate()
        devicesManager?.stopDevicesDiscovery()
    }
    var ouserData:UserData?
    
    //MARK:- View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        apiClient()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if vcType != .nearby{
            self.apiGetAssociatedCarsList()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        //stop discovery
        devicesManager?.stopDevicesDiscovery()
        
    }
    
    func apiClient(){
        
        let apiClient3 = KTKCloudClient.sharedInstance()
        KTKCloudClient.sharedInstance().getObjects(KTKDeviceConfiguration.self, parameters: ["deviceType": "beacon"]) { (kontaktResponse, error) in
            
            debugPrint(kontaktResponse)
            
        }
        
    }
    
    private func initialSetup(){
        
        switch vcType ?? .alert {
            
        case .alert:
            
            //hide search
            tableView.tableHeaderView = nil
            
//            apiGetAssociatedCarsList()
            
        case .nearby:
            
            //hide search
            tableView.tableHeaderView = nil
            
            //beacon searching configuration
            beaconSearchConfiguration()
        
        default:
            
//            apiGetAssociatedCarsList()
            break
        }
    
        configureSearchField()
        configureTableView()
    }
    
    
    //beacon search configure
    func beaconSearchConfiguration(){
        
        devicesManager = KTKDevicesManager(delegate: self)
        bluetoothManager = CBCentralManager()
        bluetoothManager.delegate = self
        
        self.startNearbyVehiclesDiscovery()
        
    }
    
    func startNearbyVehiclesDiscovery(){
        
        if devicesManager.centralState == bluetoothManager.state {
            
            self.tableView.backgroundView = nil
            
            self.tableView.es.stopPullToRefresh()
            
            activityIndicator.startAnimating()
            
            self.stackViewSearchingBeacons.isHidden = false
            
            devicesManager.startDevicesDiscovery(withInterval: 1.0)
            
            //search timeframe 10 seconds
            Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] (_) in
                
                self?.stopLoaders()
                self?.devicesManager.stopDevicesDiscovery()
                
            }
            
        }
        
    }
    
    //pull to refresh and infinite paging
    func configureTableHeaderFooterRefresh(){
        
        
        self.tableView.es.addPullToRefresh { [weak self] in
            
            self?.skip = 0
            
            if self?.vcType == .nearby{
                
                self?.startNearbyVehiclesDiscovery()
                
            }else{
            
            self?.apiGetAssociatedCarsList()
                
            }
            
            
        }
        
        if self.vcType != .nearby{
            
            self.tableView.es.addInfiniteScrolling { [weak self] in
                
                self?.skip += /self?.limit
                self?.apiGetAssociatedCarsList()
                
            }
            
        }
        
    }
    
    //search handling
    func configureSearchField(){
        
        searchField.didChangeSearchField = { [weak self] (text) in
            
            self?.apiGetAssociatedCarsList(search: text == "" ? nil : text)
            
        }
        
    }
    
    func setTableContentInset(){
        
        tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 80.0, right: 0.0)
    }
    
    func configureTableView(){ // configuring tableview
        
        configureTableHeaderFooterRefresh()
        
        setTableContentInset()
        
        let identifier = String(describing: SelectedCarsListTableViewCell.self)
        tableView.registerNibTableCell(nibName: identifier)
        
        customDataSource = TableViewDataSource(items: arrayCars, tableView: tableView, cellIdentifier: identifier, cellHeight: 96, configureCellBlock: { [weak self] (cell, item, indexPath) in
            
            let _cell = cell as? SelectedCarsListTableViewCell
            _cell?.associatedCars = item
            _cell?.contentView.backgroundColor = /self?.selectedCar?.id == (item as? CarListDataModel)?.id ? UIColor.BackgroundLightRustColor! : UIColor.BackgroundRustColor!
            
            
        }, aRowSelectedListener: { [weak self] (indexPath, cell) in
            
            if /self?.isFromCreatePost{
               
                DispatchQueue.main.async {
                    
                    self?.topMostVC?.dismiss(animated: true, completion: {
                        
                        self?.delegate?.didSelectCar(car: self?.arrayCars[indexPath.row])
                    })
                    
                }
                
            }else{
               
                self?.handleRowSelection(indexPath: indexPath)
               
            }
         
        })
        
        tableView.delegate = customDataSource
        tableView.dataSource = customDataSource
        
    }
    
    func handleRowSelection(indexPath:IndexPath){
        
        switch vcType ?? .alert {
            
        case .followed,.liked,.myCars,.nearby:
            
            self.openCarDetail(vehicleId: /self.arrayCars[indexPath.row].id)
            
        case .alert: //will open make or models posts list
            
            self.openMakeModelListVC(item: SearchDataModel.init(data: self.arrayCars[indexPath.row], type:  /self.arrayCars[indexPath.row].type))
            
            
            break
      
        }
        
    }
    
    
}

//MARK:- API
extension BookMarkCarsListVC{
    
    func apiGetAssociatedCarsList(search:String? = nil){
        
        EP_Profile.get_user_associated_cars(type: vcType?.rawValue, search: search, limit: limit, skip: skip, userId: ouserData?.id, loggedInUserId: UserDefaultsManager.shared.loggedInUser?.id).request(loaderNeeded: isFirstTime, successMessage: nil, success: { [weak self] (response) in
            
            self?.stopLoaders()
            
            self?.isFirstTime = false
            
            let _response = (response as? AssociatedOrBookMarkCarsModel)
            
            var tempArray:[CarListDataModel] = []
            
            switch self?.vcType ?? .myCars{
                
            case .followed:
                
                tempArray = _response?.followedCars ?? []
                
            case .alert:
                
                tempArray = _response?.alertList ?? []
                
            case .liked:
                
                tempArray = _response?.likedCars ?? []
                
            case .myCars:
                
                tempArray = _response?.myCars ?? []
                
            default:
                
                break
                
            }
            
            if /self?.skip == 0{
                
                self?.arrayCars = tempArray
                self?.customDataSource?.items = self?.arrayCars
                self?.tableView.reloadData()
                
            }else{
                
                if tempArray.isEmpty{
                    return
                }
                
                self?.arrayCars += tempArray
                tempArray.forEach({ (data) in
                    
                    self?.customDataSource?.items?.append(data)
                    self?.tableView.insertRows(at: [IndexPath.init(row: /self?.customDataSource?.items?.count - 1, section: 0)], with: .automatic)
                    
                })
                
            }
            
            
            
        }) { [weak self] (error) in
            
            self?.stopLoaders()
            
        }
        
    }
    
    //api nearby cars
    func apiGetNearbyVehicles(){
        
        let set1 = Set(tempArrayNearestDetectedBeaconsId)
        let set2 = Set(arrayNearestDetectedBeaconsId)
        
        let isAnyNewChangesInDiscoveredBeacons = !(set1.count == set2.count && set1 == set2)

        tempArrayNearestDetectedBeaconsId = self.arrayNearestDetectedBeaconsId
        
        if !isAnyNewChangesInDiscoveredBeacons{
            return
        }
        
        let beaconIds = self.tempArrayNearestDetectedBeaconsId.toJsonString()
        
        EP_Car.get_beacon_vehicles(beaconIds: beaconIds, limit: 100, skip: skip).request(loaderNeeded: false, successMessage: nil, success: { [weak self] (response) in
            
            let response = (response as? [CarListDataModel]) ?? []
            self?.arrayCars = response
            self?.customDataSource?.items = self?.arrayCars
            self?.tableView.reloadData()
            
            self?.devicesManager.stopDevicesDiscovery()
            
            self?.stopLoaders()
            
        }) { [weak self] (error) in
            
            self?.devicesManager.stopDevicesDiscovery()
            self?.stopLoaders()
            
        }
        
    }
    
    
    func stopLoaders(){
        
        self.tableView.es.stopLoadingMore()
        self.tableView.es.stopPullToRefresh()
        self.searchField?.activityIndicator?.stopAnimating()
        
        //for nearby vehicles
        
        if vcType == .nearby{
            
            let tempArray = self.arrayCars
            self.arrayCars = tempArray
        }
        
        self.activityIndicator?.stopAnimating()
        stackViewSearchingBeacons?.isHidden = true
        
    }
    
}

//MARK:- Discover beacon and bluetooth delegates
extension BookMarkCarsListVC:KTKDevicesManagerDelegate,CBCentralManagerDelegate{
    
    
    func devicesManager(_ manager: KTKDevicesManager, didDiscover devices: [KTKNearbyDevice]) {
        
        arrayNearestDetectedBeaconsId = devices.map({/$0.uniqueID})
        
        for device in devices {
            
            if let uniqueId = device.uniqueID {
                
                print("Detected a beacon \(uniqueId)")
                //                timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true, block: { [weak self] (_) in
                
                self.apiGetNearbyVehicles()
                
                //                })
                
            } else {
                
                print("Detected a beacon with an unknown Unique ID")
                
            }
            
        }
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .poweredOn:
            self.startNearbyVehiclesDiscovery()
            print("Bluetooth is on")
            break
        case .poweredOff:
            stopDiscovering()
            print("Bluetooth is Off.")
            break
        case .resetting:
            stopDiscovering()
            break
        case .unauthorized:
            stopDiscovering()
            print("Bluetooth is on")
            break
        case .unsupported:
            stopDiscovering()
            print("Bluetooth is on")
            break
        case .unknown:
            stopDiscovering()
            print("Bluetooth is on")
            break
        default:
            break
        }
    }
    
    func stopDiscovering(){
        
        timer?.invalidate()
        devicesManager.stopDevicesDiscovery()
    }
    
}
