//
//  SelectedMakeOrBrandVC.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/4/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class SelectedMakeOrBrandVC: BaseVC {

    //MARK:- Outlets
    
    @IBOutlet weak var btnDone: KnomotButton!
    @IBOutlet weak var tableView: UITableView!
    
    var customDataSource:TableViewDataSource?
    
    //MARK:- View controller lifecycle
    
    var isFromEditInterest:Bool = false
    var arraySelectedBrands:[BrandOrCarModel] = []
    var isFromSignupProcess:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.customDataSource?.items = arraySelectedBrands
        
        self.tableView.reloadRows(at: self.tableView.indexPathsForVisibleRows ?? [], with: .automatic)
    }
    
    
    private func initialSetup(){
        
        
        configureTableView()
        
    }
    
    func setTableContentInset(){
        
       tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 80.0, right: 0.0)
    }
    
    func configureTableView(){ // configuring tableview
        
        setTableContentInset()
        
        let identifier = String(describing: SelectedCarsListTableViewCell.self)
        tableView.registerNibTableCell(nibName: identifier)
        
        customDataSource = TableViewDataSource(items: arraySelectedBrands, tableView: tableView, cellIdentifier: identifier, cellHeight: 84, configureCellBlock: { (cell, item, indexPath) in
            
            let _cell = cell as? SelectedCarsListTableViewCell
            _cell?.selectedBrands = item
            _cell?.btnSelectModel.tag = indexPath.row
            _cell?.btnSelectModel.addTarget(self, action: #selector(self.actionSelectModels(sender:)), for: .touchUpInside)
            
            
        }, aRowSelectedListener: { (indexPath, cell) in
            
            
        })
        
        tableView.delegate = customDataSource
        tableView.dataSource = customDataSource
        
    }
    
    
    
    @objc func actionSelectModels(sender:UIButton){
        
        let vc = ENUM_STORYBOARD<SelectMakeOrBrandOrModelVC>.car.instantiateVC()
        vc.vcType = .model
        vc.selectedData = arraySelectedBrands[sender.tag]
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    //MARK:- Button actions
    
    @IBAction func didTapDone(_ sender: UIButton) {
        
        apiUpdateProfile()
        
    }
    
    //MARK:- API
    
    func apiUpdateProfile(){
 
        var selectedInterests:[SelectedInterestedModel] = []
       
        self.arraySelectedBrands.forEach { (data) in

            let model = SelectedInterestedModel.init(makeId: data.id, modelIds: data.arraySelectedModels?.map({/$0.id}))
            selectedInterests.append(model)
        }
        
        if isFromEditInterest{
            
            userData?.interestedMakes?.forEach({ (data) in
                
                let model = SelectedInterestedModel.init(makeId: /data.makeId?.id, modelIds: data.modelIds?.filter({$0.id != nil}).map({/$0.id}))
                selectedInterests.append(model)
                
            })
    
        }
            
        let jsonOfInterestBrands = JSONHelper<[SelectedInterestedModel]>().toDictionary(model: selectedInterests)
        
        let loginSignUpModel = LoginSignupViewModal()
        loginSignUpModel.interestedMakes = jsonOfInterestBrands
    
         //adding-> sending all data from userdefault and new selected for edit interest
        
        //api
        EP_Profile.updateProfile(model: loginSignUpModel).request(success:{ [weak self] (response) in

            let userData = (response as? UserData)
            UserDefaultsManager.shared.loggedInUser = userData
            
            if /self?.isFromSignupProcess{ //from signup
                
                self?.reInstantiateWindow()
                
            }else{
                
                if /self?.isFromEditInterest{ //from edit profile
                    
                    self?.navigationController?.viewControllers.forEach({ (vc) in
                        
                        if vc.isKind(of: ManageInterestVC.self){
                            
                            self?.navigationController?.popToViewController(vc, animated: true)
                            
                        }
                        
                    })
                    
                }else{ //from home if no interest selected
                    
                    
                    self?.navigationController?.popToRootViewController(animated: true)
                    
                }
                
            }
    
        })
        
    }
    
    

}
