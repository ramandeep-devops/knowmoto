//
//  MakeListingVC.swift
//  Knowmoto
//
//  Created by Apple on 19/10/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

protocol MakeListingVCDelegate:class {
    
    func didSelectMakes(items:[BrandOrCarModel],vcType:ENUM_CAR_SELECTION_TYPE)
    
}

class MakeListingVC: BaseVC {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSourceCollectionView:CollectionViewDataSource?
    var arrayItems:[BrandOrCarModel] = []
    var selectedItems:[BrandOrCarModel] = []
    
    var limit:Int = 20
    var skip:Int = 0
    
    weak var delegate:MakeListingVCDelegate?
    
    var vcType:ENUM_CAR_SELECTION_TYPE = .make
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        apiGetMakesList(of: vcType)
      
        setupUI()
        
    }
    
    func setupUI(){
        
        searchField.placeholder =  vcType.placeHolder
        searchField.placeHolderColor = UIColor.SubtitleLightGrayColor!
        
        setupSearchField()
        configureCollectionView()
        blockDoneButtonAction()
    }
    
    //right done button aciton
    func blockDoneButtonAction(){
        
        headerView.headerView.didTapRightButton = { [weak self] (sender) in
            
            self?.delegate?.didSelectMakes(items: self?.selectedItems ?? [], vcType: self?.vcType ?? .make)
            self?.navigationController?.popViewController(animated: true)
            
        }
        
    }
   
    //setup search feild block
    private func setupSearchField(){
        
        searchField?.didChangeSearchField = { [weak self] (text) in // getting user search text
            
            debugPrint(text)
            
            self?.skip = 0
            
            self?.apiGetMakesList(of: .make, search: text == "" ? nil : text, brandId: nil, loaderNeeded: false)
            
        }
        
    }
    
    //MARK:- configure collection view
    
    func configureCollectionView(){
        
        //set content insets
        func setTableContentInset(){
            
            collectionView.contentInset = UIEdgeInsets(top: 16.0, left: 0, bottom: 24.0, right: 0.0)
        }
        
        //configure header footer refresh
        func configureCollectionHeaderFooterRefresh(){
            
            
            self.collectionView.es.addPullToRefresh { [weak self] in
                
                self?.skip = 0
                
                self?.apiGetMakesList(of: .make, search: self?.searchField.text == "" ? nil : self?.searchField.text,brandId:nil,loaderNeeded:false)
                
            }
            
            self.collectionView.es.addInfiniteScrolling { [weak self] in
                
                self?.skip += /self?.limit
                
                self?.apiGetMakesList(of: .make, search: self?.searchField.text == "" ? nil : self?.searchField.text,brandId:nil,loaderNeeded:false)
                
            }
            
        }
        
        
        let identifier = String(describing: CarsCollectionViewCell.self)
        collectionView?.registerNibCollectionCell(nibName: identifier)
        
        let identifierTextTableViewCell = String(describing: TextCollectionViewCell.self)
        collectionView?.registerNibCollectionCell(nibName: identifierTextTableViewCell)
        
        configureCollectionHeaderFooterRefresh()
        setTableContentInset()
        
        let cellSpacing:CGFloat = 16
        let noOfCellInRow:Int = 2
        
        let cellWidth:CGFloat = vcType == .model ? UIScreen.main.bounds.width - 32 : (UIScreen.main.bounds.width - ((cellSpacing * CGFloat(/noOfCellInRow + 1))))/CGFloat(noOfCellInRow)
        
        let cellHeight:CGFloat = vcType == .model ? 48 : cellWidth/1.3
        
        dataSourceCollectionView = CollectionViewDataSource(items: arrayItems, collectionView: collectionView, cellIdentifier: vcType == .model ? identifierTextTableViewCell : identifier, headerIdentifier: nil, cellHeight: cellHeight, canMoveItem: false, cellWidth: cellWidth, configureCellBlock: {  [weak self] (_cell, item, indexPath) in
            
            if let cell = _cell as? CarsCollectionViewCell {
                
                cell.selectedModels = self?.selectedItems
                cell.vcType = .make
                cell.model = item
                
            }else if let cell = _cell as? TextCollectionViewCell{
                
                cell.selectedModels = self?.selectedItems
                cell.model = item
                
            }
            
        }, aRowSelectedListener: { [unowned self] (indexPath, item) in
            
            if let index = (self.selectedItems).firstIndex(where: {$0.id == /(self.arrayItems)[indexPath.item].id}){ //already contains
                
                self.selectedItems.remove(at: index)
                
            }else{ //new selection
                
                debugPrint(/self.arrayItems.count)
                self.selectedItems.append(self.arrayItems[indexPath.item])
                
            }
            
             self.collectionView.reloadItems(at: [IndexPath.init(item: indexPath.item, section: 0)])
         
        }, willDisplayCell: nil, scrollViewDelegate: nil)
        
        collectionView.delegate = dataSourceCollectionView
        collectionView.dataSource = dataSourceCollectionView
        collectionView.reloadData()
        
    }
    
    //MARK:- api get makes list
    
    func apiGetMakesList(of type:ENUM_CAR_SELECTION_TYPE,search:String? = nil,brandId:String? = nil,loaderNeeded:Bool = true,idsToSort:Any? = nil){
        
        let makesRequestEndPoint = EP_Profile.get_make_model_list(search: search, id: nil, parentId: brandId, type: type.rawValue, limit: limit, skip: skip, year: nil, idsToSort: idsToSort)
        
        let modelRequestEndpoint = EP_Profile.get_model_listing(parentId: brandId, limit: limit, skip: skip, search: search, idsToSort: nil)
        
        let endPoint = type == .model ? modelRequestEndpoint : makesRequestEndPoint
        
        endPoint.request(loaderNeeded:loaderNeeded,success:{ [weak self] (response) in
            
            self?.stopLoaders()
            
            let _response = (response as? CarBrandsModel)?.list ?? []
            
            self?.handleResponse(response: _response)
            
        })
        
    }
    
    
    
    func handleResponse(response:Any?){
        
        if skip == 0{ // reload from first page
            
            self.arrayItems = response as! [BrandOrCarModel]
            
            dataSourceCollectionView?.items = arrayItems
            
            UIView.transition(with: (self.collectionView), duration: 0.2, options: .transitionCrossDissolve, animations: { [weak self] in
                
                self?.collectionView?.reloadData()
                
                }, completion: nil)
            
        }else{ //paging
            
            self.arrayItems += response as? [BrandOrCarModel] ?? []
            
            self.dataSourceCollectionView?.items = self.arrayItems
            self.collectionView.reloadData()
            
        }
        
    }
    
    //stop all loaders
    func stopLoaders(){
        
        self.searchField.activityIndicator?.stopAnimating()
        self.collectionView.es.stopLoadingMore()
        self.collectionView.es.stopPullToRefresh()
    }
 
}
