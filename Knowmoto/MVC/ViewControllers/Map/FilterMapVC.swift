//
//  FilterMapVC.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 10/15/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

struct FilterMapModal{
    
    var selectedFilterMakes:[BrandOrCarModel] = []
    var selectedFilterModels:[BrandOrCarModel] = []
    var selectedFilterFeatures:[FeaturesListModel] = []
    var selectedFilterSponsors:[FeaturesListModel] = []
    var selectedFilterColors:[BrandOrCarModel] = []
  
}

protocol FilterMapVCDelegate:class{
    
    func didApplyFilter(filterModel:FilterMapModal)
    
}

class FilterMapVC: BaseVC {
    
    //MARK- Outlets
    @IBOutlet weak var btnSelectColors: UIButton!
    @IBOutlet weak var btnDropDown: UIButton!
    @IBOutlet weak var btnSelectMake: UIButton!
    @IBOutlet weak var btnSelectSponsors: UIButton!
    @IBOutlet weak var btnSelectFeatures: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblSelectedSponsors: UILabel!
    @IBOutlet weak var lblSelectedFeatures: UILabel!
    @IBOutlet weak var lblSelectedModels: UILabel!
    @IBOutlet weak var lblSelectedMakes: UILabel!
    
    weak var delegate:FilterMapVCDelegate?
    var filterModel = FilterMapModal()
    
    private var isCollapse:Bool = true{
        didSet{
            
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.btnDropDown.setImage(self?.btnDropDown.imageView?.image?.imageRotatedByDegrees(degrees: 180.0), for: .normal)
                
            }
            
            self.customDataSource?.items = isCollapse ? [] : selectedMakes
            self.tableView.reloadData()
        }
    }
    
    private var customDataSource:TableViewDataSource?

    //Properties
    
    public var selectedMakes:[BrandOrCarModel] = []{
        didSet{
            
            self.btnSelectMake.setTitle(self.selectedMakes.isEmpty ? "Select Makes" : "\(/selectedMakes.count) \(/selectedMakes.count == 1 ? "make" : "makes") selected", for: .normal)
            
            lblSelectedMakes.isHidden = self.selectedMakes.isEmpty
            btnDropDown.isHidden = self.selectedMakes.isEmpty
            
            self.filterModel.selectedFilterMakes = self.selectedMakes
            lblSelectedMakes?.text = "Select Models"//selectedMakes.isEmpty ? "No makes selected".localized : "\(/selectedMakes.count) makes selected".localized
            
            self.customDataSource?.items = isCollapse ? [] : selectedMakes
            self.tableView.reloadData()
        }
    }
    public var selectedModels:[BrandOrCarModel] = []{
        didSet{

            
            self.filterModel.selectedFilterModels = self.selectedModels
            lblSelectedModels?.text = selectedModels.isEmpty ? "No models selected".localized : "\(/selectedModels.count) models selected".localized
            
        }
    }
    public var selectedFeatures:[FeaturesListModel] = []{
        didSet{
            
//            lblSelectedFeatures.isHidden = self.selectedFeatures.isEmpty
            self.btnSelectFeatures.setTitle(self.selectedFeatures.isEmpty ? "Select Keyword" : "\(/selectedFeatures.count) \(/selectedFeatures.count == 1 ? "keyword" : "keywords") selected", for: .normal)
            self.filterModel.selectedFilterFeatures = self.selectedFeatures
            lblSelectedFeatures?.text = selectedFeatures.isEmpty ? "No features selected".localized : "\(/selectedFeatures.count) features selected".localized
            
        }
    }
    public var selectedSponsors:[FeaturesListModel] = []{
        didSet{
            
//            self.lblSelectedSponsors.isHidden = selectedSponsors.isEmpty
            self.btnSelectSponsors.setTitle(self.selectedSponsors.isEmpty ? "Select Sponsors" : "\(/selectedSponsors.count) \(/selectedSponsors.count == 1 ? "sponsor" : "sponsors") selected", for: .normal)
            self.filterModel.selectedFilterSponsors = self.selectedSponsors
            lblSelectedSponsors?.text = selectedSponsors.isEmpty ? "No sponsors selected".localized : "\(/selectedSponsors.count) sponsors selected".localized
        }
    }
    
    public var selectedColors:[BrandOrCarModel] = []{
        didSet{
            
            //            self.lblSelectedSponsors.isHidden = selectedSponsors.isEmpty
            self.btnSelectColors.setTitle(self.selectedColors.isEmpty ? "Select Colors" : "\(/selectedColors.count) \(/selectedColors.count == 1 ? "color" : "colors") selected", for: .normal)
            
            self.filterModel.selectedFilterColors = self.selectedColors
        }
    }
    
    //MARK:- View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blockClearButtonAction()
        configureTableView()
        setEditData()
        lblSelectedMakes.addTapGesture(target: self, action: #selector(self.didTapCollapseMakesList(_:)))
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.tableView.reloadData()
        
    }
    
    func setEditData(){
        
        self.selectedMakes = self.filterModel.selectedFilterMakes
        self.selectedModels = self.filterModel.selectedFilterModels
        self.selectedSponsors = self.filterModel.selectedFilterSponsors
        self.selectedFeatures = self.filterModel.selectedFilterFeatures
        self.selectedColors = self.filterModel.selectedFilterColors
        
     
    }

    //right done button aciton
    func blockClearButtonAction(){
        
        headerView.headerView.didTapRightButton = { [weak self] (sender) in
            
            self?.selectedModels = []
            self?.selectedMakes = []
            self?.selectedSponsors = []
            self?.selectedFeatures = []
            self?.selectedColors = []
            
        }
        
    }
    
    //MARK:- Table view configuration
    
    func configureTableView(){
        
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 100.0, right: 0)
        
        let identifier = String(describing: SelectedCarsListTableViewCell.self)
        tableView.registerNibTableCell(nibName: identifier)
        
        customDataSource = TableViewDataSource(items: selectedMakes, tableView: tableView, cellIdentifier: identifier, cellHeight: 80, configureCellBlock: { (_cell, item, indexPath) in
            
            let cell = _cell as? SelectedCarsListTableViewCell
            cell?.selectedBrands = item
            cell?.btnSelectModel.tag = indexPath.row
            cell?.btnSelectModel.addTarget(self, action: #selector(self.actionSelectModels(sender:)), for: .touchUpInside)
            
        }, aRowSelectedListener: { (indexPath, item) in
            
            
            
        })
        
        tableView.delegate = customDataSource
        tableView.dataSource = customDataSource
        tableView.reloadData()
        
    }
    
    //MARK:- Button actions
    
    @objc func actionSelectModels(sender:UIButton){
        
        let vc = ENUM_STORYBOARD<SelectMakeOrBrandOrModelVC>.car.instantiateVC()
        vc.vcType = .model
        vc.isFromFilter = true
        vc.selectedData = selectedMakes[sender.tag]
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func didTapSelectMakes(_ sender: Any) {
        
        let vc = ENUM_STORYBOARD<MakeListingVC>.map.instantiateVC()
        vc.selectedItems = selectedMakes
        vc.vcType = .make
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func didTapSelectColors(_ sender: UIButton) {
        
        let view = ColorSelectionPopUp(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 48, height: 444))
        view.preselectedColors = self.selectedColors
        view.delegate = self
        view.openPopUp()
        
    }
    
    @IBAction func didTapCollapseMakesList(_ sender: UIButton) {
        
        isCollapse = !isCollapse
        
    }
    
    @IBAction func didTapSelectModels(_ sender: Any) {
        
        let vc = ENUM_STORYBOARD<MakeListingVC>.map.instantiateVC()
        vc.vcType = ENUM_CAR_SELECTION_TYPE.model
        vc.selectedItems = selectedModels
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func didTapSelectSponsors(_ sender: UIButton) {
        
        let vc = ENUM_STORYBOARD<AddCarStep6SponsorsVC>.car.instantiateVC()
        vc.vcType = .selectSponsorFilter
        vc.selectedSponsors = self.selectedSponsors
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapSelectFeatures(_ sender: UIButton) {
        
        let vc = ENUM_STORYBOARD<AddCarStep5SelectFeatureVC>.car.instantiateVC()
        vc.delegate = self
        vc.vcType = .selectForfilter
        vc.selectedFeatures = self.selectedFeatures
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func didTapApply(_ sender: UIButton) {
        
        delegate?.didApplyFilter(filterModel: self.filterModel)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func didTapSelectColor(_ sender: Any) {
        
        let view = ColorSelectionPopUp(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 48, height: 444))
        view.preselectedColors = self.selectedColors
        view.delegate = self
        view.openPopUp()
        
    }
    
}

extension FilterMapVC:MakeListingVCDelegate,SelectMakeOrBrandOrModelVCDelegate,ColorSelectionPopUpDelegate{
    
    func didSelectColors(colors: [BrandOrCarModel]) {
        
        self.selectedColors = colors
        
    }
    
    func didSelectFeatures(model: Any?) {
        
        self.selectedFeatures = model as! [FeaturesListModel]
        
    }
    
    
    func didSelectMakes(items: [BrandOrCarModel], vcType: ENUM_CAR_SELECTION_TYPE) {
        
        switch vcType {
            
        case .make:
            
            self.selectedMakes = items
            
        case .model:
            
            self.selectedModels = items
            
        default:
            break
            
        }
        
    }
    
    
    func didSelectSponsor(model: Any?) {
        
        self.selectedSponsors = model as! [FeaturesListModel]
        
    }
    
}
