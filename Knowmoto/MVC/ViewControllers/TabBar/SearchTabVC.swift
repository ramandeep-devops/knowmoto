//
//  SearchVC.swift
//  Knowmoto
//
//  Created by Apple on 30/07/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//


import UIKit

struct Headers {
    var image:UIImage?
    var headerName:String?
    var headerHieght:CGFloat? = 23
    
    init(image:UIImage?,headerName:String?,headerHieght:CGFloat?) {
        self.image = image
        self.headerName = headerName
        self.headerHieght = headerHieght
    }
}

struct SelectedFilter{
    var name:String
    var type:Int
}

class SearchTabVC: BaseVC {
    
    @IBOutlet weak var heightConstraintContainerViewTags: NSLayoutConstraint!
    @IBOutlet weak var containerViewTags: UIView!
    @IBOutlet weak var heightConstraintCollectionView: NSLayoutConstraint!
    @IBOutlet weak var collectionViewFilterTags: UICollectionView!
    @IBOutlet weak var widthConstraintCancelButton: NSLayoutConstraint!
    
    @IBOutlet weak var btnCancel: UIButton!
    
    //MARK:- OUTLETS
    
    @IBOutlet weak var tableViewMain: UITableView!
    @IBOutlet weak var tableview: UITableView!
    
    //MARK:- PROPERTIES
    
    
    var customMainTableViewDataSource: TableViewDataSourceWithMultipleTypeCells2?
    var arrayMainTableItems:[TableCellLayoutModel] = []
    var customCollectionViewFilterDataSource:CollectionViewDataSource?
    var customSearchTableViewDataSource: TableViewDataSource?
    var arraySearchItems:[Any] = []{
        didSet{
            
            arraySearchItems.isEmpty ? self.setTableViewBackgroundView(tableview: tableview) : (self.tableview.backgroundView = nil)
            
            
            customSearchTableViewDataSource?.items = arraySearchItems
            
            UIView.transition(with: self.tableview, duration: 0.2, options: .transitionCrossDissolve, animations: { [weak self] in
                
                self?.tableview.reloadData()
                
                }, completion: nil)
            
            
       
        }
    }
    
    var arrayFilters:[SelectedFilter] = [
        SelectedFilter(name: "Color", type: 3),
        SelectedFilter(name: "Feature", type: 4),
        SelectedFilter(name: "Sponsor", type: 6),
        SelectedFilter(name: "Vehicle", type: 5)]
    
    var searchText:String? = ""{
        didSet{
//            setUIOnSearchEmpty()
        }
    }
    var selectedFilters:[SelectedFilter] = []

    //MARK:- View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        lastSelectedTab = .search
        self.apiGetMostTrendings()
    }
    
    
    //MARK:- Initial setup
    func initialSetup(){
        
        apiGetMostTrendings()
        
        configureCollectionViewFilters()
        configureSearchField()
        configureMainTableView()
        configureSearchTableView()
        
    }
    
    func configureSearchField(){
        
        searchField.didChangeSearchField = { [weak self] (text) in
            
            self?.searchText = text
            
            if text.isBlank{
              
                self?.arraySearchItems = [] //clear all search items
                self?.stopLoaders()
                
            }else{
                
                //search text
                self?.apiSearch(search: text)
                
            }
            
        }
        
        searchField.didBeginEditingSearchField = { [weak self] in
            
            self?.setUIOnSearchEmpty(hideMainTable: true)
            
        }
        
        
        
    }
    
    func configureCollectionViewFilters(){
        
        let identifier = String(describing: TagCollectionViewCell.self)
        collectionViewFilterTags.registerNibCollectionCell(nibName: identifier)
        
        let cellHeight:CGFloat = 42.0
        
        customCollectionViewFilterDataSource = CollectionViewDataSource(items: arrayFilters, collectionView: collectionViewFilterTags, cellIdentifier: identifier, headerIdentifier: nil, cellHeight: cellHeight, cellWidth: 56.0, configureCellBlock: { [weak self] (cell, item, indexPath) in
            
            let _cell = cell as? TagCollectionViewCell
            _cell?.configureCellWithSelection(selectedTag: self?.selectedFilters.map({$0.name}), tagName: /(item as? SelectedFilter)?.name)
            
        }, aRowSelectedListener: { [weak self] (indexPath, item) in
            
            if /self?.selectedFilters.contains(where: {$0.type == (item as? SelectedFilter)?.type}){
                
                self?.selectedFilters.removeAll()
                self?.collectionViewFilterTags.reloadData()
                self?.reloadSearchType()
                
            }else{
                self?.selectedFilters.removeAll()
                self?.selectedFilters.append(item as! SelectedFilter)
                self?.collectionViewFilterTags.reloadData()
                self?.reloadSearchType()
            }
            
            
        }, willDisplayCell: nil, scrollViewDelegate: nil)
        
        
        customCollectionViewFilterDataSource?.didSizeForItemAt = { [weak self] (indexPath) ->CGSize in
            
            let cellWidth = (self?.arrayFilters[indexPath.item].name.widthOfString(font: ENUM_APP_FONT.bold.size(14)) ?? 0) + 56.0
            
            return CGSize(width: cellWidth, height: cellHeight)
        }
        
        collectionViewFilterTags.delegate = customCollectionViewFilterDataSource
        collectionViewFilterTags.dataSource = customCollectionViewFilterDataSource
        collectionViewFilterTags.reloadData()
        
    }
    
    
    func reloadSearchType(){
        
        self.searchField.placeholder = (ENUM_MAIN_SEARCH_TYPE(rawValue: /self.selectedFilters.first?.type) ?? .make).placeHolder
        self.searchField.placeHolderColor = UIColor.SubtitleLightGrayColor!
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//           self.toggleFilterView()
//        }
     
    }
    
    
    func configurePullToRefresh(){
        
        tableViewMain.es.addPullToRefresh {
            
            self.apiGetMostTrendings()
            
        }
        
    }
    
    //MARK: CONFIGURE Main tableview cell
    
    func configureMainTableView(){ // configuring tableview
        
        //        configurePullToRefresh()
        
        // register Xib's
        let identifierCollectionTableCell = String(describing: CarsListTableViewCell.self)
        let identifierTagTableCell = String(describing: TagTableViewCell.self)
        
        tableViewMain.registerNibTableCell(nibName: identifierCollectionTableCell)
        tableViewMain.registerNibTableCell(nibName: identifierTagTableCell)
        
        tableViewMain.contentInset = UIEdgeInsets(top: /(userData?.recentSearches ?? [])?.isEmpty ?  -32 : 16.0, left: 0.0, bottom: 24.0, right: 0.0)
        
        arrayMainTableItems = [
            
            TableCellLayoutModel.init(identifier: identifierTagTableCell, cellHeight: UITableView.automaticDimension, arrayItems: [""], headerName: .recentSearches, collectionCellItems: userData?.recentSearches ?? [],headerIcon:#imageLiteral(resourceName: "ic_history_white")),
            
            TableCellLayoutModel.init(identifier: identifierCollectionTableCell, cellHeight: 132, arrayItems: [""], headerName: .trendingMakes, collectionCellItems: [],headerIcon:#imageLiteral(resourceName: "ic_trending")),
            
            TableCellLayoutModel.init(identifier: identifierCollectionTableCell, cellHeight: 216, arrayItems: [""], headerName: .trendingCars, collectionCellItems: [],headerIcon:#imageLiteral(resourceName: "ic_trending"))
        ]
        
        customMainTableViewDataSource = TableViewDataSourceWithMultipleTypeCells2(arrayItemsLayoutModel: arrayMainTableItems, tableView: tableViewMain, headerHeight: 48.0, configureCellBlock: { [weak self] (_cell, item, indexPath) in
            
            //same cell for both types (trending makes and trending cars)
            if let cell = _cell as? CarsListTableViewCell{
                
                switch self?.arrayMainTableItems[indexPath.section].headerName ?? .trendingMakes{
                    
                case .trendingMakes: //trending makes
                    
                    cell.arrayMakeListItems = (self?.arrayMainTableItems[indexPath.section].collectionCellItems ?? [])
                    
                case .trendingCars: //trending cars
                    
                    cell.arrayCarListItems = (self?.arrayMainTableItems[indexPath.section].collectionCellItems ?? [])
                    
                    
                default:
                    break
                    
                }
                
            }else if let cell = _cell as? TagTableViewCell{ //recent searches tag
                
                cell.items = self?.arrayMainTableItems[indexPath.section].collectionCellItems ?? []
                
            }
            
            }, viewForHeader: { [weak self] (section) -> UIView? in
                
                let sectionHeader = SectionHeaderView.instanceFromNib()
                
                sectionHeader.imageViewOfName.isHidden = false
                sectionHeader.constraintCenterAlign.constant = 0.0
                
                sectionHeader.lblName.text = self?.arrayMainTableItems[section].headerName?.rawValue
                sectionHeader.imageViewOfName.image = self?.arrayMainTableItems[section].headerIcon
                return /self?.arrayMainTableItems[section].collectionCellItems?.isEmpty ? nil : sectionHeader
                
            }, viewForFooter: nil, aRowSelectedListener: nil)
        
        
        customMainTableViewDataSource?.heightForRowAt = { [weak self] (indexPath) ->CGFloat in
            
            let cellHeight = self?.arrayMainTableItems[indexPath.section].cellHeight
            let itemsInSection = self?.arrayMainTableItems[indexPath.section].collectionCellItems
            let newCellHeight = ((cellHeight != nil) && !(/itemsInSection?.isEmpty)) ? cellHeight : 0.0
            
            let height:CGFloat = newCellHeight ?? UITableView.automaticDimension
            
            return height
        }
        
        customMainTableViewDataSource?.heightForHeaderInSection = { [weak self] (section) -> CGFloat in
            
            let itemsInSection = self?.arrayMainTableItems[section].collectionCellItems
            
            return /itemsInSection?.isEmpty ? 0.0 : 48.0
        }
        
        tableViewMain.delegate = customMainTableViewDataSource
        tableViewMain.dataSource = customMainTableViewDataSource
    }
    
    
    func configureSearchTableView(){
        
        let identifier = String(describing: SearchTableViewCell.self)
        
        tableview.contentInset = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 24.0, right: 0.0)
        
        customSearchTableViewDataSource = TableViewDataSource(items: arraySearchItems, tableView: tableview, cellIdentifier: identifier, cellHeight: UITableView.automaticDimension, configureCellBlock: { (cell, item, indexPath) in
            
            let cell = cell as? SearchTableViewCell
            cell?.searchModel = item
            
            
        }, aRowSelectedListener: { [weak self] (indexPath, item) in
            
            guard let model = self?.arraySearchItems[indexPath.row] as? SearchDataModel else {return}
            
            //recent searches save
            self?.saveRecentSearches(modal: model)
            
            //reload recent searches
            self?.arrayMainTableItems[0].collectionCellItems = self?.userData?.recentSearches ?? []
            self?.tableViewMain.reloadData()
            
            let searchType = ENUM_MAIN_SEARCH_TYPE(rawValue: /model.type) ?? .make
            
            switch searchType{
                
            case .color:
        
                self?.redirectToCarsList(item: model)
                
                break
                
            case .feature: // as tag
                
                self?.redirectToCarsList(item: model)
                
                break
                
            case .make,.model:
                
                self?.redirectToMakeModelListVC(item: model)
                
                break
                
            case .vehicle:
                
                self?.redirectToVehicleDetail(item: model)
                break
                
            case .sponsors:
                
                self?.redirectToCarsList(item: model)
                break
                
            default:
                break
            }
            
            
        })
        
        tableview.delegate = customSearchTableViewDataSource
        tableview.dataSource = customSearchTableViewDataSource
        tableview.reloadData()
    }
    
    //MARK:- Button actions
    
    @IBAction func didTapCancelSearchView(_ sender: UIButton) {
        
        if !tableview.isHidden{ //cancel action
            
            self.searchField.activityIndicator?.stopAnimating()
            self.arraySearchItems = []
            self.searchField.text = ""
            self.searchText = ""
            self.setUIOnSearchEmpty(hideMainTable: false)
            self.view.endEditing(true)
            
        }else{ //filter action
            
            toggleFilterView()
        }
    }
    
    func toggleFilterView(){
        
        let isSelected = /self.containerViewTags.alpha == 1.0
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            
            self?.heightConstraintContainerViewTags.constant = isSelected ? 0.0 : 56.0
            self?.view.layoutIfNeeded()
            
        }) { [weak self] (_)  in
            
            self?.containerViewTags.isHidden = isSelected
            self?.collectionViewFilterTags.isHidden = isSelected
            self?.containerViewTags.alpha = isSelected ? 0.0 : 1.0
        }
        
    }
    
    func setUIOnSearchEmpty(hideMainTable:Bool){
        
        if !self.collectionViewFilterTags.isHidden{
            
            self.collectionViewFilterTags.isHidden = true
            self.containerViewTags.isHidden = true
            self.containerViewTags.alpha = 0.0
            self.heightConstraintContainerViewTags.constant = 0.0
            
        }
     
        UIView.animate(withDuration: 0.4) { [weak self] in
            
            self?.tableview.alpha = hideMainTable ? 1.0 : 0.0
            
            self?.tableview.isHidden = !hideMainTable
            self?.btnCancel.setTitle(hideMainTable ? "Cancel".localized : "Filter".localized, for: .normal)
            
            // self?.widthConstraintCancelButton.constant = hideMainTable ? 56.0 : 0.0
            //self?.btnCancel.alpha = hideMainTable ? 1.0 : 0.0
            
        }
        
    }
}

extension SearchTabVC{
    
    //get search home data
    func apiGetMostTrendings(){
    
        EP_Home.get_most_trending(type: 8, limit: 10, skip: 0).request(loaderNeeded: false, successMessage: nil, success: { [weak self] (response) in
            
            let response = (response as? TrendingData)
            self?.arrayMainTableItems[1].collectionCellItems = response?.mostTrendingMake ?? []
            self?.arrayMainTableItems[2].collectionCellItems = response?.mostLikedCars ?? []
            
            self?.customMainTableViewDataSource?.dataItems = self?.arrayMainTableItems
            
            self?.tableViewMain.reloadData {
                
                self?.view.layoutIfNeeded()
                
            }
           
        }) { (error) in
            
            
        }
        
    }
    
    
    
    //search make,modal,color and feature(tag)
    func apiSearch(search:String?){
        
        EP_Home.search(search: search, id: nil, limit: nil, skip: nil, loggedInUserId: userData?.id, type: selectedFilters.first?.type).request(loaderNeeded: false, successMessage: nil, success: { [weak self] (response) in
            
            self?.stopLoaders()
            self?.arraySearchItems = (response as? [SearchDataModel]) ?? []
            
        }) { [weak self] (error) in
            
            self?.stopLoaders()
            
        }
        
    }
}

//MARK:- Common functions
extension SearchTabVC{

    //savving searches to user defaults
    func saveRecentSearches(modal:SearchDataModel){
        
        let maxSaveLimit = 5
        
        var savedRecentSearches = userData?.recentSearches ?? []
        
        //set maximum 5 recent location
        
        if !(savedRecentSearches.contains(where: {$0.id == modal.id})){ //checking duplicacy
            
            if savedRecentSearches.count > maxSaveLimit - 1{
                
                savedRecentSearches.removeFirst()
            }
            
            savedRecentSearches.append(modal)
            
        }
        
        
        userData?.recentSearches = savedRecentSearches
        
        UserDefaultsManager.shared.loggedInUser = userData
    }
    
    
    //stop loaders
    func stopLoaders(){
        
        self.searchField.activityIndicator?.stopAnimating()
        
    }
    
    
    func redirectToVehicleDetail(item:SearchDataModel){
        
        let vc = ENUM_STORYBOARD<CarDetailSegmentedVC>.car.instantiateVC()
        
        vc.vehicleId = item.id
        vc.isFromCarDetail = true
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    //redirect to custom layout cars list
    func redirectToCarsList(item:SearchDataModel){
        
        let vc = ENUM_STORYBOARD<VehiclesCollectionLayoutListVC>.car.instantiateVC()
        vc.searchData = item
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    //redirect to make modal list
    func redirectToMakeModelListVC(item:SearchDataModel){
        
        let vc = ENUM_STORYBOARD<MakeModelPostListsSegmentedVC>.car.instantiateVC()
        vc.searchData = item
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

   
    
}
