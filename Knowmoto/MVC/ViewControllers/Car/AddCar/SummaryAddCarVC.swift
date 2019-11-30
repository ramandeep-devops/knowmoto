//
//  SummaryAddCarVC.swift
//  Knowmoto
//
//  Created by cbl16 on 14/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.

import UIKit

struct BasicInfoModel{
    
    var title:String?
    var name:String?
}

enum ENUM_EDIT_CAR_DETAIL_TYPE:Int{
    case basicDetails = 0
    case otherDetails = 1
    case specialAttributesOrFeatures = 3
    case modifications = 4
    case sponsors = 5
}


class SummaryAddCarVC: BaseAddCarVC {
    
    //MARK:- Outlets
    
    @IBOutlet weak var headerViewSummary: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Properties
    
    // Identifiers
    let identifierBasicInfo = String(describing: BasicInfoAndDetailCell.self)
    let identifierSpecialAttributes = String(describing: SpecialAttributeCell.self)
    let IdentifierModification = String(describing: ModificationTableViewCell.self)
    let identifierImageList = String(describing: CarsListTableViewCell.self)
    let identifierSponsorTableViewCell = String(describing: SponsorTableViewCell.self)
    
    
    var arrayItems:[TableCellLayoutModel] = []
    var dataSourceTableView:TableViewDataSourceWithMultipleTypeCells2?
    var delegate:BaseAddCarDelegate?
    
    var isFromCarDetail:Bool = false
    var isFromMyProfile:Bool = false
    
    //MARK:- View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        intialSetup()
        
        if isFromEditCar{
            
            //            DispatchQueue.global(qos: .background).async { [weak self] in
            
            self.apiGetCar()
            //            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
    }
    
    func intialSetup(){
        
        self.containerViewNext.isHidden = carData != nil
        
        setDataAndReload()
        configureTableView()
    }
    
    func setDataAndReload(){
        
        if carData == nil{
            
            setBasicData()
            setSummaryListData()
            
        }else{
            
            setViewModelFromCarDetail()
        }
        
        self.dataSourceTableView?.dataItems = self.arrayItems
        
        DispatchQueue.main.async { [weak self] in
            
            self?.tableView.reloadData {
                
                self?.view.layoutIfNeeded()
                
            }
//            self?.tableView.scrollToRow(at: IndexPath.init(item: 0, section: 0), at: .bottom, animated: true)
            
        }
      
    }
    
    
    func setBasicData(){
        
        viewModel?.makeName = /viewModel?.makeId?.name
        viewModel?.modelName = /viewModel?.makeId?.modelId?.name
        viewModel?.typeOrSubmodel = /viewModel?.makeId?.modelId?.subModel?.subModelName
        viewModel?.color = /viewModel?.makeId?.modelId?.subModel?.color
    }
    
    func setSummaryListData(){
        
        //setting basic info array
//        identifiers = [identifierBasicInfo,identifierImageList,identifierSpecialAttributes,IdentifierModification,identifierSponsorTableViewCell]
        
        
        viewModel?.arrayBasicInfo = []
        
        viewModel?.arrayBasicInfo?.append(BasicInfoModel(title: "Make", name: viewModel?.makeName))
        viewModel?.arrayBasicInfo?.append(BasicInfoModel(title: "Model", name: viewModel?.modelName))
        viewModel?.arrayBasicInfo?.append(BasicInfoModel(title: "Type", name: viewModel?.typeOrSubmodel))
        viewModel?.arrayBasicInfo?.append(BasicInfoModel(title: "Color", name: viewModel?.color))
        viewModel?.arrayBasicInfo?.append(BasicInfoModel(title: "Year", name: viewModel?.year?.toString))
        viewModel?.arrayBasicInfo?.append(BasicInfoModel(title: "Country", name: /viewModel?.country))
        
        viewModel?.arrayBasicInfo?.removeAll(where: {/$0.name?.trimmed().isBlank})
        
        self.arrayItems = [
            
            TableCellLayoutModel(identifier: identifierBasicInfo, cellHeight: 48.0, cellHeaderheight: 48.0, arrayItems: viewModel?.arrayBasicInfo, headerName: .basicInfoAndDetail),
            
            TableCellLayoutModel(identifier: identifierBasicInfo, cellHeight: 48.0,arrayItems: [BasicInfoModel(title: "Vehicle nickname", name: /viewModel?.nickName)],headerName:.otherDetails),
            
            TableCellLayoutModel(identifier: identifierImageList, cellHeight: 100,cellHeaderheight:nil, arrayItems: /self.viewModel?.image?.isEmpty ? [] : [""],headerName:.otherDetails,collectionCellItems:self.viewModel?.image),
            
            TableCellLayoutModel(identifier: identifierSpecialAttributes, cellHeight: 48.0, arrayItems: viewModel?.arrayFeatures,headerName:.specialAttributes),
            
            TableCellLayoutModel(identifier: IdentifierModification, cellHeight: 100, arrayItems: viewModel?.modificationType,headerName:.modifications),
            
            TableCellLayoutModel(identifier: identifierSponsorTableViewCell, cellHeight: 156.0, arrayItems: viewModel?.arraySponsors == nil || /viewModel?.arraySponsors?.isEmpty ? [] : [""],headerName:.sponsors,collectionCellItems:viewModel?.arraySponsors)
        ]
        
        
        if isFromCarDetail || isFromMyProfile{
            
            self.arrayItems.removeAll(where: {$0.identifier == identifierSponsorTableViewCell})
        }
        
    }
    
    func setViewModelFromCarDetail(){
        
        viewModel = AddEditCarViewModel(carData: carData)
        
        headerView.isHidden = !isFromEditCar
        
        tableView.tableHeaderView =  nil
        
        self.setSummaryListData()
        
    }
    
   
    func configureTableView(){ // configuring tableview
        
        // register Xib's
        tableView.registerNibTableCell(nibName: identifierBasicInfo)
        tableView.registerNibTableCell(nibName: identifierSpecialAttributes)
        tableView.registerNibTableCell(nibName: IdentifierModification)
        tableView.registerNibTableCell(nibName: identifierImageList)
        tableView.registerNibTableCell(nibName: identifierSponsorTableViewCell)
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: isFromEditCar ? 24.0 : 124.0, right: 0)
        let loadImageFromSignedUrl = !(/self.isFromCarDetail || /self.isFromMyProfile || /self.isFromEditCar)
        
        dataSourceTableView = TableViewDataSourceWithMultipleTypeCells2(arrayItemsLayoutModel: arrayItems, tableView: tableView, headerHeight: 48, configureCellBlock: { [weak self] (_cell, item, indexPath) in
            
            if let cell = _cell as? CarsListTableViewCell{
                
                cell.isLoadWithSignedUrl = loadImageFromSignedUrl
                cell.numberOfcellInRow = 4
                cell.arrayPicsListItems = (self?.arrayItems[indexPath.section].collectionCellItems ?? [])
                
            }else if let cell = _cell as? SponsorTableViewCell{
                
                cell.isFromCarDetail = loadImageFromSignedUrl
                cell.isHideRemoveButton = true
                cell.items = (self?.arrayItems[indexPath.section].collectionCellItems as! [FeaturesListModel])
                
            }else if let cell = _cell as? SpecialAttributeCell{
                
                cell.configureCell(model: self?.arrayItems[indexPath.section].arrayItems?[indexPath.row])
                
            }else if let cell = _cell as? ModificationTableViewCell{
                
                cell.model = self?.arrayItems[indexPath.section].arrayItems?[indexPath.row]
                cell.btnRemove.isHidden = true
                
            }else if let cell = _cell as? BasicInfoAndDetailCell{
                
                cell.model = self?.arrayItems[indexPath.section].arrayItems?[indexPath.row]
                
            }
            
            }, viewForHeader: { [weak self] (section) -> UIView? in
                
                let sectionHeader = SectionHeaderView.instanceFromNib()
                sectionHeader.lblName.text = self?.arrayItems[section].headerName?.rawValue
                
                sectionHeader.btnEdit.tag = section
                sectionHeader.btnEdit.isHidden = !(/self?.isFromEditCar)
                sectionHeader.btnEdit.addTarget(self, action: #selector(self?.didTapEditCar(sender:)), for: .touchUpInside)
                
                return sectionHeader
                
            }, viewForFooter: nil, aRowSelectedListener: nil)
        
        
        dataSourceTableView?.heightForRowAt = { [weak self] (indexPath) ->CGFloat in
            
            let height:CGFloat = self?.arrayItems[indexPath.section].cellHeight ?? 48.0
            
            return height
        }
        
        dataSourceTableView?.heightForHeaderInSection = { [weak self] (section) ->CGFloat in
            
            let items = (self?.arrayItems[section].arrayItems)
            
            let height:CGFloat = (/items?.isEmpty || items == nil || self?.arrayItems[section].cellHeaderheight == nil) && (!(/self?.isFromEditCar) || self?.arrayItems[section].cellHeaderheight == nil) ? 0.0 : 56.0
            
            return height
            
        }
        
        
        tableView.delegate = dataSourceTableView
        tableView.dataSource = dataSourceTableView
        tableView.reloadData()
    }
    
    //action edit car
    @objc func didTapEditCar(sender:UIButton){
        
        let editType = ENUM_EDIT_CAR_DETAIL_TYPE.init(rawValue: sender.tag) ?? .basicDetails
        
        switch editType{
            
        case .basicDetails:
            
            let vc = ENUM_STORYBOARD<AddCarStep1SelectMakeVC>.car.instantiateVC()
            vc.carData = self.carData
            vc.selectedData = self.carData?.make ?? []
            vc.isFromEditCar = self.isFromEditCar
            self.navigationController?.pushViewController(vc, animated: true)
            
            break
            
        case .otherDetails:
            
            let vc = ENUM_STORYBOARD<AddCarStep3AddPicsVC>.car.instantiateVC()
            vc.carData = self.carData
            vc.isFromEditCar = self.isFromEditCar
            self.navigationController?.pushViewController(vc, animated: true)
            
            break
            
        case .modifications:
            
            let vc = ENUM_STORYBOARD<AddCarStep4ModificationVC>.car.instantiateVC()
            vc.carData = self.carData
            vc.isFromEditCar = self.isFromEditCar
            self.navigationController?.pushViewController(vc, animated: true)
            
            break
            
        case .specialAttributesOrFeatures:
            
            let vc = ENUM_STORYBOARD<AddCarStep5SelectFeatureVC>.car.instantiateVC()
            vc.vcType = .editFeatures
            vc.carData = self.carData
            vc.isFromEditCar = self.isFromEditCar
            self.navigationController?.pushViewController(vc, animated: true)
            
            break
        case .sponsors:
            
            let vc = ENUM_STORYBOARD<AddCarStep6SponsorsVC>.car.instantiateVC()
            
            vc.vcType = .editCar
            vc.carData = self.carData
            
//            vc.isFromEditCar = self.isFromEditCar
            self.navigationController?.pushViewController(vc, animated: true)
            
            break
            
        }
        
    }
    
    //action add car
    @IBAction func didTapAddCar(_ sender: UIButton) {
        
        self.apiAddAndEditCar()
        
    }
    
    //MARK:- API
    func apiGetCar(isReloadCardetail:Bool = false){
        
        EP_Car.get_car_feeds(id: /carData?.id, userId: userData?.id, loggedInUserId: userData?.id).request(loaderNeeded: false, successMessage: nil, success: { [weak self] (response) in
            
            let _response = (response as? [CarListDataModel]) ?? []
            self?.carData = _response.first
            self?.setDataAndReload()
            
            if isReloadCardetail{
            self?.delegate?.reloadCarDetail(data:self?.carData)
            }
            
            self?.isFirstTime = false
            
        }) { (error) in
            
            debugPrint(error)
        }
    }
    
}


extension SummaryAddCarVC:SJSegmentedViewControllerViewSource{
    
    func viewForSegmentControllerToObserveContentOffsetChange() -> UIView {
        return tableView
    }
    
}

