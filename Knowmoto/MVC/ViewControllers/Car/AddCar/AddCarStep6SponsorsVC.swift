//
//  AddCarStep6SponsorsVC.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/14/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

enum SponsorListVCType{
    
    case addSponsors
    case editCar
    case selectBrandForModification
    case selectSponsorFilter
}

class AddCarStep6SponsorsVC: BaseAddCarVC {
    
    
    //MARK:- Outlets
 
    @IBOutlet weak var btnNoSponsorFound: KnomotButton!
    @IBOutlet weak var lblNoSponsorAddedText: UILabel!
    @IBOutlet weak var viewAddNotFoundData: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Properties
    
    private var dataSourceTableView:TableViewDataSourceWithMultipleTypeCells?
    
    private var arrayItemsDictionary:[String:Any] = [:]{
        didSet{
            debugPrint("sdf")
        }
    }
    var selectedSponsors:[Any] = []{
        didSet{
            
            (self.arrayItemsDictionary[/self.identifierSposorTableCell] as? [FeaturesListModel])?.first?.sponsors = selectedSponsors as? [FeaturesListModel] ?? []
            self.dataSourceTableView?.arrayItemsDictionary = self.arrayItemsDictionary

            checkSkip()
            btnNext?.enableButton = vcType == .editCar || vcType == .selectSponsorFilter || !(/selectedSponsors.isEmpty)
        }
    }
    private var identifiers:[String] = []
    private var identifierSposorTableCell = String(describing: SponsorTableViewCell.self)
    private var identfierTextTableCell = String(describing: TextTableViewCell.self)
    
    private let sectionHeader = SectionHeaderView.instanceFromNib()
    private var noSponserAddedText:String = ""
    private var isNoSponsorFound:Bool = false{
        didSet{
            
            noSponserAddedText = searchField.text ?? ""
            lblNoSponsorAddedText.text = "There's no \(vcType == .selectBrandForModification ? "brand" : "sponsor") named '\(noSponserAddedText)'"
            viewAddNotFoundData.isHidden = vcType == .selectSponsorFilter || !isNoSponsorFound
            
        }
    }
    private var isHideSkip:Bool = true{
        didSet{
            MainAddCarVC.headerView?.headerView.btnRight?.isHidden = isHideSkip
        }
    }
    
    var vcType:SponsorListVCType = .addSponsors{
        didSet{
            isFromEditCar = vcType == .editCar
        }
    }
    
    weak var delegate:SelectMakeOrBrandOrModelVCDelegate?
    
    
    
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
    
    func resetArray(){
        
        self.arrayItemsDictionary[/self.identfierTextTableCell] = []
        
        self.dataSourceTableView?.arrayItemsDictionary = self.arrayItemsDictionary
        
        self.tableView.reloadSections(IndexSet.init(integer: 0), with: .automatic)
    }
    
    func initialSetup(){
        
        
        actionSkip()
        
        viewAddNotFoundData.isHidden = true
        
        handleSearch()
        
        configureTableView()
        
        
        switch vcType{
            
        case .addSponsors:
            
            btnNext.enableButton = false
            
        case .editCar:
            
            self.setEditData()
            
        case .selectBrandForModification:
            
            headerView.type = "commonWithBackDismiss"
            headerView.title = ""
            
            headerView.isHidden = false
            containerViewNext.isHidden = true
//            btnNext.isHidden = true
            btnNext.setTitle("Done", for: .normal)
            lblTitle.text = "Search for a brand"
            lblSubtitle.text = "Find or add a brand for your modification"
            searchField.placeholder = "Enter a brand..."
            btnNoSponsorFound.setTitle("Add this as a brand", for: .normal)
            
            searchField.placeHolderColor = UIColor.SubtitleLightGrayColor!
            
            headerView.headerView.didTapLeftButton = { [weak self] (sender) in
                
                self?.delegate?.didSelectSponsor(model: self?.selectedSponsors)
                self?.dismiss(animated: false, completion: nil)
                
            }
            
            
        case .selectSponsorFilter:
            
            headerView.title = ""
            
            headerView.isHidden = false
            
            lblTitle.text = "Search for a Sponsors"
            lblSubtitle.text = "Find or add a sponsor for vehicle filters"
            btnNext.setTitle("Done", for: .normal)

            searchField.placeHolderColor = UIColor.SubtitleLightGrayColor!
            
            headerView.headerView.didTapLeftButton = { [weak self] (sender) in
                
//                self?.delegate?.didSelectSponsor(model: self?.selectedSponsors)
                self?.navigationController?.popViewController(animated: true)
                
            }
            
        }
        
        let tempSponosors = self.selectedSponsors
        self.selectedSponsors = tempSponosors
        
        tableView.reloadData()
 
    }
    
    func setEditData(){
        
        self.viewModel = AddEditCarViewModel()
        
        self.viewModel?.arraySponsors = carData?.sponsorID ?? []
        
        self.selectedSponsors = carData?.sponsorID ?? []
        
//        (self.arrayItemsDictionary[identifierSposorTableCell] as? [FeaturesListModel])?.first?.sponsors = carData?.sponsorID ?? []
        
//        self.dataSourceTableView?.arrayItemsDictionary = self.arrayItemsDictionary
        
        self.tableView.reloadData()
        
    }
    
    
    //MARK:- handle search field
    
    func handleSearch(){
       
        searchField.didChangeSearchField = { [weak self] (text) in // getting user search text
            
//            self?.view.isUserInteractionEnabled = false
            
            if /text.trimmed().isEmpty{
                
                self?.searchField.activityIndicator?.stopAnimating()
                
                self?.resetArray()
                
                self?.isNoSponsorFound = false
                
                self?.view.isUserInteractionEnabled = true
                
                return
                
            }
            
            //get sponsors list
            
            EP_Car.get_sponsor_list(search: text == "" ? nil : text, limit: 5, skip: 0).request(loaderNeeded: false, successMessage: nil, success: { [weak self] (response) in
                
                self?.searchField.activityIndicator?.stopAnimating()
                
                let _response = (response as? [FeaturesListModel]) ?? []
                
                
                self?.arrayItemsDictionary[/self?.identfierTextTableCell] = _response
                
                self?.dataSourceTableView?.arrayItemsDictionary = self?.arrayItemsDictionary
                
                self?.tableView.reloadSections(IndexSet.init(integer: 0), with: .automatic)
                
                
                let isContainedInList = _response.contains(where: {$0.name?.lowercased() == /self?.searchField.text?.lowercased()})
                
                self?.isNoSponsorFound = !(isContainedInList)
                self?.view.isUserInteractionEnabled = true
                
                }, error: { (_) in
                    
                    self?.view.isUserInteractionEnabled = true
                    self?.searchField.activityIndicator?.stopAnimating()
                    
            })
            
            
        }
    }
    
    //MARK:- Button actions
    
    //did tap no data found
    @IBAction func didTapAddNotFoundData(_ sender: Any) {
        
        viewAddNotFoundData.isHidden = true
        
        if !noSponserAddedText.trimmed().isEmpty{
            
            let featureData = FeaturesListModel.init(name: noSponserAddedText)
            
            switch vcType{
                
            case .selectBrandForModification:
                
                self.delegate?.didSelectSponsor(model: [featureData])
                
                self.topMostVC?.dismiss(animated: false, completion: nil)
                
            default:
                
                  self.actionAddSponsor(sponsorModel:featureData)
                
            }
            
            
        }
        self.searchField.text = ""
        resetArray()
    }
    
    @IBAction func didTapAddNext(_ sender: UIButton) {
        
        setApiViewModel()
        
        switch vcType{
            
        case .editCar:
            
            self.apiAddAndEditCar()
            
        case .selectSponsorFilter:
            
            self.delegate?.didSelectSponsor(model: self.selectedSponsors)
            self.navigationController?.popViewController(animated: true)
            
            
        default:
            
            let vc = ENUM_STORYBOARD<SummaryAddCarVC>.car.instantiateVC()
            vc.viewModel = self.viewModel
            self.navigationController?.pushViewController(vc, animated: true)
            
            NotificationCenter.default.post(name: .UPDATE_LOADING, object: nil)
        }

    }
    
    
    //MARK- Table view configuration
    
    func configureTableView(){
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80.0, right: 0)
        
        tableView.registerNibTableCell(nibName: identfierTextTableCell)
        tableView.registerNibTableCell(nibName: identifierSposorTableCell)
        
        let sponsorListModel = FeaturesListModel()
        arrayItemsDictionary = [identfierTextTableCell:[],identifierSposorTableCell :[sponsorListModel]]
        
        identifiers = [identfierTextTableCell,identifierSposorTableCell]
        
        dataSourceTableView = TableViewDataSourceWithMultipleTypeCells(arrayItemsDictionary: arrayItemsDictionary, identifiers: identifiers, tableView: tableView, headerHeight: nil, configureCellBlock: { (cell, item, indexPath) in
            
            if let _cell = cell as? SponsorTableViewCell{
                
                _cell.items = (item as? [FeaturesListModel] ?? []).first?.sponsors ?? []
                
                _cell.delegate = self
                
            }else if let _cell = cell as? TextTableViewCell{
                
                _cell.btnAdd.isHidden = false
                _cell.btnAdd.tag = indexPath.item
                _cell.btnAdd.addTarget(self, action: #selector(self.didTapAddTag(sender:)), for: .touchUpInside)
                
                _cell.lblTitle.text = (item as? [FeaturesListModel])?[indexPath.row].name
            }
            
            
        }, viewForHeader: { [weak self] (section) -> UIView? in
            
            switch self?.vcType ?? .addSponsors{
                
            case .selectBrandForModification:
                
                self?.sectionHeader.lblName.text = "Brand selected".localized
                
            default:
                
                self?.sectionHeader.lblName.text = "Vehicle sponsers added".localized

            }
            
            return self?.sectionHeader
            
            }, viewForFooter: nil, aRowSelectedListener: { [weak self] (indexPath, item) in
                
                
        })
        
        
        dataSourceTableView?.heightForRowAt = { [weak self] (indexPath) ->CGFloat in
            
            return indexPath.section == 0 ? 40.0 : 156.0
            
        }
        
        dataSourceTableView?.heightForHeaderInSection = { [weak self] (section) ->CGFloat in
            
            let sponsorList = (self?.arrayItemsDictionary[/self?.identifierSposorTableCell] as? [FeaturesListModel])?.first?.sponsors ?? []
            
            return section == 0 || sponsorList.isEmpty ? 0.0 : 40.0
            
        }
        
        tableView.delegate = dataSourceTableView
        tableView.dataSource = dataSourceTableView
        tableView.reloadData()
        
    }
    
    @objc func didTapAddTag(sender:UIButton){
        
        if let sponsorModel = (self.arrayItemsDictionary[/self.identfierTextTableCell] as? [FeaturesListModel])?[sender.tag] {
            
            switch vcType{
                
            case .selectBrandForModification:
                
                self.delegate?.didSelectSponsor(model: [sponsorModel])
                self.topMostVC?.dismiss(animated: false, completion: nil)
                
            default:
                
               self.actionAddSponsor(sponsorModel: sponsorModel)
            }
            
            
        }
        
    }
    
    
    
    //MARK:- skip handling
    
    func checkSkip(){
        
        isHideSkip = !(/selectedSponsors.isEmpty) //skip button
    }
    
    func actionSkip(){
        
        //skip button action
        
        switch vcType {
            
        case .addSponsors:
            
            MainAddCarVC.headerView?.headerView.didTapRightButton = { [weak self] (sender) in
                
                self?.didTapAddNext(UIButton())
            }
            
        default:
            break
        }
        
    }
    
    //MARK:- Actions
    
    //add sponsor
    func actionAddSponsor(sponsorModel:FeaturesListModel){
        
        self.view.endEditing(true)
        
        var addedSponsors = (self.arrayItemsDictionary[/self.identifierSposorTableCell] as? [FeaturesListModel])?.first?.sponsors ?? []
        
        if addedSponsors.contains(where: {/$0.name?.trimmed() == /sponsorModel.name?.trimmed()}){
            
            Toast.show(text: "Sponsor already added in list".localized, type: .error)
            return
        }
        
        addedSponsors.insert(sponsorModel, at: 0)
        
        self.selectedSponsors = addedSponsors// (self.arrayItemsDictionary[/self.identifierSposorTableCell] as? [FeaturesListModel])?.first?.sponsors ?? []

        self.dataSourceTableView?.arrayItemsDictionary = self.arrayItemsDictionary
        
        self.tableView.reloadSections(IndexSet.init(integer: 1), with: .none)
        self.sectionHeader.isHidden = false
        
        if self.tableView.numberOfSections == 2{
            
            if self.tableView.numberOfRows(inSection: 1) > 0{
                
                self.tableView.scrollToBottom(animated: true)
                
            }
            
        }
    
    }
    

    
    func setApiViewModel(){
        
        viewModel?.arraySponsors = (self.selectedSponsors as? [FeaturesListModel])
        viewModel?.sponsorId = (self.selectedSponsors as? [FeaturesListModel])?.map({/$0.id})
    }
    
}

extension AddCarStep6SponsorsVC:SponsorTableViewCellDelegate{
    
    func didRemoveSponsor(index: Int) {
        
        (self.arrayItemsDictionary[/identifierSposorTableCell] as? [FeaturesListModel])?.first?.sponsors?.remove(at: index)

        selectedSponsors = (self.arrayItemsDictionary[/identifierSposorTableCell] as? [FeaturesListModel])?.first?.sponsors ?? []
        
        sectionHeader.isHidden = (self.arrayItemsDictionary[/identifierSposorTableCell] as? [FeaturesListModel])?.first?.sponsors?.isEmpty ?? false
        
        
    }
    
}
