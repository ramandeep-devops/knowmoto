//
//  AddCarStep4VC.swift
//  Knowmoto
//
//  Created by Apple on 12/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class AddCarStep4ModificationVC: BaseAddCarVC {
    
    //MARK:- Outlets
    @IBOutlet weak var btnAddModificationPart: KnomotButton!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Properties
    var customDataSource:TableViewDataSource?
    
    //modification popup current selected models
    
    var selectedModificationModel:ModificationType?
    var selectedAddModificationPopup:AddModificationPopUp?
    
    var isHideSkip:Bool = true{
        didSet{
            MainAddCarVC.headerView?.headerView.btnRight?.isHidden = isHideSkip
        }
    }
    
    //all array of added modifications
    
    var arrayModificationModels = [ModificationType](){
        didSet{
            
            checkSkip()
            
            btnNext.enableButton = isFromEditCar || !arrayModificationModels.isEmpty
            
        }
    }
    
    //MARK:- View contreller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
  
        actionSkip()
        checkSkip()

    }
    
    //hiding skip on disapper view
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
   
            isHideSkip = true //skip button
    }
    
    func initialSetup(){
       
        configureTableView()
        
        if isFromEditCar{
            
            setEditData()
            
        }
    }
   
    func setEditData(){
        
        self.viewModel = AddEditCarViewModel()
        
        self.viewModel?.modificationType = carData?.modificationType ?? []
        
        self.customDataSource?.items = carData?.modificationType ?? []
        
        self.arrayModificationModels = carData?.modificationType ?? []
        
        self.tableView.reloadData()
        
    }
    
    
    func configureTableView(){ // configuring tableview
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80.0, right: 0)
        
        let identifier = String(describing: ModificationTableViewCell.self)
        tableView.registerNibTableCell(nibName: identifier)
        
        customDataSource = TableViewDataSource(items: arrayModificationModels, tableView: tableView, cellIdentifier: identifier, cellHeight: 100, configureCellBlock: { (cell, item, indexPath) in
            
            let _cell = cell as? ModificationTableViewCell
            _cell?.btnRemove.tag = indexPath.row
            _cell?.btnRemove.addTarget(self, action: #selector(self.actionRemoveModification(sender:)), for: .touchUpInside)
            _cell?.model = item
            
        }, aRowSelectedListener: { (indexPath, cell) in
            
            
        })
        
        tableView.delegate = customDataSource
        tableView.dataSource = customDataSource
        tableView.reloadData()
    }
    
    func checkSkip(){
        
        isHideSkip = !arrayModificationModels.isEmpty //skip button
    }
    
    func actionSkip(){
        
        //skip button action
        if !isFromEditCar{
            
            MainAddCarVC.headerView?.headerView.didTapRightButton = { [weak self] (sender) in
                
                self?.didTapAddNext(UIButton())
            }
            
        }
    }
    
    //remove modification popup
    @objc func actionRemoveModification(sender:UIButton){
        
        self.arrayModificationModels.remove(at: sender.tag)
        self.customDataSource?.items = self.arrayModificationModels
        
        self.tableView.deleteRows(at: [IndexPath.init(item: sender.tag, section: 0)], with: .automatic)
        self.tableView.reloadRows(at: self.tableView.indexPathsForVisibleRows ?? [], with: .automatic)
        
    }
    
    //add modification action
    @IBAction func didTapAddModification(_ sender: UIButton) {
        
        let view = AddModificationPopUp(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 48, height: 444))
        selectedAddModificationPopup = view
        view.delegate = self
        view.openPopUp()
        
    }
    
    //next actions
    @IBAction func didTapAddNext(_ sender: UIButton) {
        
        setApiViewModel()
        
        if isFromEditCar{
            
            self.apiAddAndEditCar()
            
        }else{
            
            let vc = ENUM_STORYBOARD<AddCarStep5SelectFeatureVC>.car.instantiateVC()
            vc.viewModel = self.viewModel
            self.navigationController?.pushViewController(vc, animated: true)
            
            NotificationCenter.default.post(name: .UPDATE_LOADING, object: nil)
            
        }
    }
    
    func setApiViewModel(){
        
        viewModel?.modificationType = self.arrayModificationModels
    }
}

//MARK:- Modification popup delegate and select brand delegate
extension AddCarStep4ModificationVC:AddModificationPopUpDelegate,SelectMakeOrBrandOrModelVCDelegate{
    
    func didSelectFeatures(model: Any?) {}
    
    
    //done with modification and reload data
    func didDoneWithModificationModel(model: Any?) {
        
        self.arrayModificationModels.append(model as! ModificationType)
        self.customDataSource?.items = self.arrayModificationModels
        self.tableView.reloadData()
        
    }
    
    //go for selection brands to list vc
    func didSelectForBrand(model: Any?) {
        
        selectedModificationModel = model as? ModificationType
        
        let vc = ENUM_STORYBOARD<AddCarStep6SponsorsVC>.car.instantiateVC()
        vc.vcType = .selectBrandForModification
        vc.selectedSponsors = [self.selectedModificationModel?.brandData]
//        vc.isFromSelectBrand = true
        vc.delegate = self
        //            vc.blockDidSelectBrand = { [weak self] in
        //
        //                topMostVC?.dismiss(animated: true, completion: nil)
        //
        //            }
        self.present(vc, animated: false, completion: nil)
        
//        let vc = ENUM_STORYBOARD<AddCarStep1SelectMakeVC>.car.instantiateVC()
//        vc.vcType = .brandOrSponsor
//        vc.selectedData = [selectedModificationModel?.brandData]
//        vc.delegate = self
//
//
//        self.present(vc, animated: true, completion: nil)
        
    }
    
    //after selection brand opening same instance of modification pop
    func didSelectSponsor(model: Any?) {
        
        selectedModificationModel?.brandData = nil
        selectedModificationModel?.brandData = (model as? [FeaturesListModel])?.first
        
        selectedAddModificationPopup?.model = selectedModificationModel
        selectedAddModificationPopup?.textFieldBrand.text = selectedModificationModel?.brandData?.name ?? "Select Brand".localized
        selectedAddModificationPopup?.openPopUp(animation: false)
        
    }
    
    //reset all current selected modification popup data
    func resetData(){
        
        self.selectedAddModificationPopup = nil
        self.selectedModificationModel = nil
    }
    
}
