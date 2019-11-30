
//  ManageBeaconVC.swift
//  Knowmoto

//  Created by cbl16 on 10/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.

import UIKit

class ManageBeaconVC: BaseVC {
    
    //MARK:- OUTLETS
    @IBOutlet weak var bottomSeparationLineView: UIView!

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var btnAddAnotherBacon: KnomotButton!
    
    //MARK:- PROPERTIES
    
    var customDataSource:TableViewDataSource?
    var arrayBeaconList = [BeaconlistModel](){
        didSet{
            
            bottomSeparationLineView?.isHidden = arrayBeaconList.isEmpty
            setUserRole()
            btnAddAnotherBacon.setTitle(arrayBeaconList.isEmpty ? "+ Add beacon".localized : "+ Add another beacon".localized, for: .normal)
        }
    }
    
    deinit {
        debugPrint("deinit called of \(self)")
    }
    
    //MARK:- LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configuring table
        self.configureTableView()
        
        // add beacon action
        self.btnAddAnotherBacon.addTarget(self, action: #selector(self.didTapAddAnotherBeacon), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // fetch beacon data
        self.customDataSource?.items = self.arrayBeaconList
        self.tableview.reloadData()
        self.getBeacons()
    }
    
    //MARK:- API's
    func getBeacons(){
        
        EP_Profile.get_beacons(search:nil, id:nil, beaconId:nil, userId:userData?.id , isActive:nil , limit: 100, skip: 0).request(loaderNeeded: isFirstTime,success:{ [weak self] (response) in
            
            self?.isFirstTime = false
            
            let _response = (response as? BeaconsModel)?.list ?? []
            
            self?.arrayBeaconList = _response
            self?.customDataSource?.items = self?.arrayBeaconList
            self?.tableview.reloadData()
            
        })
        
    }
    
    func setUserRole(){
        
        userData?.role = /arrayBeaconList.isEmpty ? 1 : 2
        UserDefaultsManager.shared.loggedInUser = userData
    }
    
    @objc func didTapAddAnotherBeacon(){
        
        let view = AddBeaconPopup(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 48, height: 271))
        
        view.delegates = self
        view.openPopUp()
    }
    

    func configureTableView(){ // configuring tableview
        
        let identifier = String(describing: ManageBeaconTableViewCell.self)
        tableview.registerNibTableCell(nibName: identifier)
        
        customDataSource = TableViewDataSource(items: arrayBeaconList, tableView: tableview, cellIdentifier: identifier, cellHeight: 100, configureCellBlock: { (cell, item, indexPath) in
                        
            let cell = cell as? ManageBeaconTableViewCell
            cell?.model = item
            
        }, aRowSelectedListener: { [weak self] (indexPath, cell) in
            
            let vc = ENUM_STORYBOARD<BeaconLinkDetailVC>.car.instantiateVC()
            vc.beaconData = self?.arrayBeaconList[indexPath.row]
            vc.arrayBeaconList = self?.arrayBeaconList ?? []
            vc.indexPath = indexPath
            self?.navigationController?.pushViewController(vc, animated: true)
    
        })
        
        tableview.delegate = customDataSource
        tableview.dataSource = customDataSource
        
    }
}

//MARK:- CUSTOM POPUP DELEGATE 
extension ManageBeaconVC: AddBeaconDelegate {
  
    func didBeaconAdded(model: Any) {
        
        self.arrayBeaconList.append(model as! BeaconlistModel)
        self.customDataSource?.items = self.arrayBeaconList
        self.tableview.insertRows(at: [IndexPath.init(row: self.arrayBeaconList.count - 1, section: 0)], with: .automatic)
        
    }
   
}
