//
//  PlacePickerVC.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/3/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit
import MapboxGeocoder
import CoreLocation

class PlacePickerVC: BaseVC {
    
    
    //MARK:- Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: KnowmotoSearchTextField!
    
    //MARK:- Properties
    
    var customDataSource:TableViewDataSourceWithHeader?
    let locationManager = CLLocationManager()
    var items = [Array<Any>?]()
    let geocode = Geocoder.shared
    var didGetLocation:((LocationAddress)->())? = nil
    var selectedAddress:String?
    var searchType:MBPlacemarkScope = [.all]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        initialSetup()
        
    }
    
    deinit {
        
        debugPrint("deintialized",String(describing: self))
        
    }
    
    
    func initialSetup(){
        
        //7889171506
        LocationManager.shared.askPermission(blockPermissionGranted: nil)
        
        setupSearchField()
        searchTextField.text = selectedAddress
        
        searchTextField.getResultfor = searchTextField.text //hit api on previous selected address
        configureTableView()
    }
    
    func setupSearchField(){
        
        items.append([])
        items.append(UserDefaultsManager.shared.location?.recentSavedLocations?.reversed() ?? [])
        
        searchTextField.allowedScopes = searchType
        searchTextField.searchType = .location
        searchTextField.blockSearchResult = { [weak self] (searchItems,ofType) in
            
            self?.setSearchData(searchItems: searchItems ?? [])
            
            
            debugPrint(searchItems)
            
        }
        
    }
    
    func setSearchData(searchItems:Array<Any>){
        
        self.items[0] = searchItems
        self.customDataSource?.items = self.items
        
        UIView.transition(with: (self.tableView)!, duration: 0.2, options: .transitionCrossDissolve, animations: { [weak self] in
            
            self?.tableView.reloadData()
            
            }, completion: nil)
        
    }
    
    
    //MARK:- Button actions
    @IBAction func didTapDetectMyLocation(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        CheckPermission.shared.permission(For: .locationAlwaysInUse) { [weak self] (permission) in
            
            
            if !permission{
                
                self?.openAlertForSettings(for: .locationAlwaysInUse)
                
            }else{
                
                MapBoxGeocodingCustom.reverseGeocode(allowedScoped:self?.searchType ?? [.all], lat: /self?.locationManager.location?.coordinate.latitude, long: /self?.locationManager.location?.coordinate.longitude, address: { (placeMarker) in
                
                    let locationAddress = self?.getLocationAddressObject(data: placeMarker)
                    
                    self?.saveToRecentSearches(location: locationAddress ?? LocationAddress())
                    
                    self?.didGetLocation?(locationAddress ?? LocationAddress())
                    
                    self?.dismiss(animated: true ,completion: nil)
                    
                })
                
            }
            
        }
        
    }
    
    
    func configureTableView(){
        
        let identifier = String(describing: TextTableViewCell.self)
        tableView.registerNibTableCell(nibName: identifier)
        let headerHeight:CGFloat = 36
        let cellHeight:CGFloat = 40
        
        customDataSource = TableViewDataSourceWithHeader(items: items, tableView: tableView, cellIdentifier: identifier, cellHeight: cellHeight, headerHeight: headerHeight, configureCellBlock: { (cell, item, indexPath) in
            
            let _cell = cell as? TextTableViewCell
            
            _cell?.model = (item as? [Any])?[indexPath.row]
            
            
        }, viewForHeader: { (section) -> UIView? in
            
            return SectionHeaderView.instanceFromNib()
            
        }, viewForFooter: nil, aRowSelectedListener: { [weak self] (indexPath, item) in
            
            self?.handleTableDidSelectCellListener(indexPath: indexPath)
            
            }, willDisplayCell: nil)
        
        customDataSource?.heightForHeaderInSection = { (section)-> CGFloat in
            
            if section == 0 || (section == 1 && /self.items[section]?.isEmpty){
                
                return 0.0
                
            }else{
                
                return CGFloat(headerHeight)
                
            }
        }
        
        tableView.delegate = customDataSource
        tableView.dataSource = customDataSource
        tableView.reloadData()
    }
    
    func handleTableDidSelectCellListener(indexPath:IndexPath){
        
        DispatchQueue.main.async(execute: { [weak self] in
            
            self?.view.endEditing(true)
            
        })
        
        var coordinate:CLLocationCoordinate2D?
        var locationAddress:LocationAddress?
        
        if let placeData = ((self.items)[/indexPath.section] as? [GeocodedPlacemark])?[/indexPath.row]{ //from geoplace mapbox
            
            locationAddress = self.getLocationAddressObject(data: placeData)
            
        }else if let placeData = ((self.items)[/indexPath.section] as? [LocationAddress])?[/indexPath.row]{ //from saving recent search local
            
            coordinate = CLLocationCoordinate2D(latitude: /placeData.latitude, longitude: /placeData.longitude)
            locationAddress = placeData
            
        }
        
        //save to recent search
        self.saveToRecentSearches(location: locationAddress!)
        
        //block for did select listener
        self.didGetLocation?(locationAddress!)//callback for get location
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    //MARK:- Recent search saving
    
    func saveToRecentSearches(location:LocationAddress){
        
        let maximumSaveLimit = 5
        
        var previousSavedLocations = UserDefaultsManager.shared.location?.recentSavedLocations ?? []
        
        //set maximum 5 recent location
        if previousSavedLocations.count > maximumSaveLimit - 1{
            
            previousSavedLocations.removeFirst()
        }
        
        previousSavedLocations.append(location)
        
        
        //removing duplicacy
        for (index, element) in previousSavedLocations.enumerated().reversed() {
            if previousSavedLocations.filter({ /$0.address == /element.address}).count > 1 {
                previousSavedLocations.remove(at: index)
            }
        }
        
        //saving to userdata -> this userdata location for both guest and logged in user
        var locationData = UserDefaultsManager.shared.location ?? SavedLocations()
        
        locationData.recentSavedLocations = previousSavedLocations
        locationData.selectedLocation = location
        
        UserDefaultsManager.shared.location = locationData // current location to userdefault
        
        if /self.items.count > 1{
            
            self.items[1] = previousSavedLocations
            
        }
        
    }
    
}


