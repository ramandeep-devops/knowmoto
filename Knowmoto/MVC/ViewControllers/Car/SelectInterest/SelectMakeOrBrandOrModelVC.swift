//
//  SelectMakeOrBrandVC.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/4/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

enum ENUM_SELECTION_TYPE{
    case single
    case multiple
}


protocol SelectMakeOrBrandOrModelVCDelegate:class {
    
    func didSelectFeatures(model:Any?)
    func didSelectSponsor(model:Any?)
    func didSelectMyCar(model:Any?)
}

//making optional
extension SelectMakeOrBrandOrModelVCDelegate{
    func didSelectSponsor(model:Any?){}
    func didSelectMyCar(model:Any?){}
}

class SelectMakeOrBrandOrModelVC: BaseVC {
    
    //MARK:- Outlets
    @IBOutlet weak var btnRemove: KnomotButton!
    @IBOutlet weak var imageViewBrand: KnowmotoUIImageView!
    @IBOutlet weak var containerViewSelectedTypes: UIView!
    @IBOutlet weak var btnSelected: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerViewSearchField: UIView!
    
    
    //MARK:- Properties
    
    var dataSourceCollections:CollectionViewDataSource?
    var vcType:ENUM_CAR_SELECTION_TYPE = .make
    var arrayCarsOrBrands:[Any] = []{ // this is from api that we are showing in list
        didSet{
            
            /arrayCarsOrBrands.isEmpty ? self.setCollectionViewBackgroundView(collectionView: collectionView,noDataFoundText: vcType.noDataFoundText) : (self.collectionView.backgroundView = nil)
            
        }
    }
    
    var selectedCarOrBrands:[Any] = []{ // user for assign selectedData:Any? to this array to selected previous selected data (just only for selected data)
        didSet{
            
            self.setSelectedCount()
        }
    }
    var carData:CarListDataModel? //from edit make
    var selectedData:Any?
    
    var arrayRemoveFromList:[BrandOrCarModel]?
    
    var makeDataOfEditInterest:BrandOrCarModel?

    var isFromEditInterest:Bool = false
    var isFromSignupProcess:Bool = true
    var isFromEditCar:Bool = false
    var isFromFilter:Bool = false
    
    var delegate:SelectMakeOrBrandOrModelVCDelegate?
    
    var limit:Int = 20
    var skip:Int = 0
    
    //using this to prevent looping
    
    //MARK:- View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
    private func initialSetup(){
        
        setupUI()
        configureCollectionView()
        
        switch vcType {
            
        case .make,.model:
          
            self.apiGetList(of: vcType, brandId: makeDataOfEditInterest?.id ?? (selectedData as? BrandOrCarModel)?.id)
            
        case .brandOrSponsor:
            
            self.apiGetList(of: vcType, brandId:nil)
            
        case .myCars:
            
            self.apiGetList(of: vcType)
            
        default:
            break
        }
        
        
    }
    
    
    func setupUI(){
        
        func setData(){ //setting data
            
            switch vcType{
                
            case .make:
                
                self.selectedCarOrBrands = (self.selectedData as? [BrandOrCarModel]) ?? []
                
                break
                
            case .model: // setting previous selected data for models
                
                if isFromEditInterest{
                    
                    self.selectedCarOrBrands = (self.selectedData as? [BrandOrCarModel]) ?? []
                    
                }else{
                    
                    self.selectedCarOrBrands = (self.selectedData as? BrandOrCarModel)?.arraySelectedModels ?? []
                    
                }
                
            case .brandOrSponsor: // setting previous selected data for sponsors
                
                self.selectedCarOrBrands = (self.selectedData as? [FeaturesListModel] ?? [])
                
            default:
                break
            }
            
            
        }
        
        //UI components setup
        switch vcType{
            
        case .myCars:
            
            headerView.title = vcType.title
            headerView.isHidden = false
            containerViewSearchField?.isHidden = true
            containerViewSelectedTypes.isHidden = true
            
        case .brandOrSponsor:
            
            lblTitle.text = vcType.title
            searchField.placeholder = "Search for a brands".localized
            searchField.placeHolderColor = UIColor.SubtitleLightGrayColor!
            
        case .make:
            
            lblTitle?.text = isFromSignupProcess ? vcType.title : "Make of your vehicle".localized
            lblSubtitle?.attributedText =  vcType.subTitle.getAttributedText(linSpacing: 8.0)
            imageViewBrand?.isHidden = true
            headerView.isHidden = !(self.isFromEditCar || isFromSignupProcess || isFromEditInterest || self.isFromFilter)
            
            
            headerView?.type = (self.isFromEditCar || self.isFromFilter) ? ENUM_VIEWCONTROLLER_TYPE.commonWithBackPop.rawValue :
                isFromEditInterest ? ENUM_VIEWCONTROLLER_TYPE.commonCenterAppIconAndBack.rawValue
                : ENUM_VIEWCONTROLLER_TYPE.commonCenterAppIcon.rawValue
            
            headerView.title = isFromEditCar ? "Edit a vehicle" : ""
            
            
            
        case .model:
            
            searchField.placeholder = "Search for a models".localized
            searchField.placeHolderColor = UIColor.SubtitleLightGrayColor!
            
            btnNext.setTitle(isFromEditInterest ? "Update" : isFromFilter ? "Done" : "Next", for: .normal)
            btnRemove.isHidden = !isFromEditInterest
            
            lblTitle?.text = makeDataOfEditInterest?.name ?? /(selectedData as? BrandOrCarModel)?.name
            
            lblSubtitle?.attributedText =  isFromFilter ? "Select models to filter live cars".getAttributedText() : vcType.subTitle.getAttributedText(linSpacing: 8.0)
            
            let makeImage = makeDataOfEditInterest?.image?.first?.thumb ?? /(selectedData as? BrandOrCarModel)?.image?.first?.thumb
            
            imageViewBrand?.loadImage(key: /makeImage)
            
            containerViewSearchField?.isHidden = false
            containerViewSelectedTypes?.isHidden = true
            imageViewBrand?.isHidden = false
            
            
            headerView?.type = ENUM_VIEWCONTROLLER_TYPE.commonWithBackPop.rawValue
            
        default:
            break
        }
        
        setData() //for previous selcted items or cars
        
        setupSearchField()
    }
    
    private func setupSearchField(){
        
        searchField?.didChangeSearchField = { [weak self] (text) in // getting user search text
            
            debugPrint(text)
            
            self?.skip = 0
            
            self?.apiGetList(of: self?.vcType ?? .make, search: text == "" ? nil : text, brandId: self?.makeDataOfEditInterest?.id ?? (self?.selectedData as? BrandOrCarModel)?.id, loaderNeeded: false)
            
//            self?.apiGetList(of: self?.vcType ?? .make, search: text == "" ? nil : text,loaderNeeded:false)
//
            
            
        }
        
    }
    
    func setTableContentInset(){
        
        collectionView?.contentInset = UIEdgeInsets(top: 16.0, left: 0, bottom: 92.0, right: 0.0)
    }
    
    func configureCollectionHeaderFooterRefresh(){
        
        let editMakeId = self.makeDataOfEditInterest?.id
        let addInterestMakeId = (self.selectedData as? BrandOrCarModel)?.id
        
        self.collectionView.es.addPullToRefresh { [weak self] in
            
            self?.skip = 0
            self?.apiGetList(of: self?.vcType ?? .make, search: self?.searchField.text == "" ? nil : self?.searchField.text,brandId:editMakeId ?? /addInterestMakeId,loaderNeeded:false)
            
        }
        
        self.collectionView.es.addInfiniteScrolling { [weak self] in
            
            self?.skip += /self?.limit
            
            self?.apiGetList(of: self?.vcType ?? .make, search: self?.searchField.text == "" ? nil : self?.searchField.text,brandId:editMakeId ?? /addInterestMakeId,loaderNeeded:false)
            
        }
        
    }
    
    //MARK: Configure collection view
    
    private func configureCollectionView(){ //Configuring collection View cell
        
        configureCollectionHeaderFooterRefresh()
        setTableContentInset()
        
        let cellSpacing:CGFloat = 16
        let cellWidth:CGFloat = (UIScreen.main.bounds.width - ((cellSpacing * CGFloat(/vcType.noOfCellInRow + 1))))/CGFloat(vcType.noOfCellInRow)
        
        let cellHeight:CGFloat = vcType.squareCell ? cellWidth + 32 : cellWidth/1.3
        
        
        let identifier = String(describing: CarsCollectionViewCell.self)
        collectionView?.registerNibCollectionCell(nibName: identifier)
        
        let identifierTextTableViewCell = String(describing: TextCollectionViewCell.self)
        collectionView?.registerNibCollectionCell(nibName: identifierTextTableViewCell)
        
     
        dataSourceCollections = CollectionViewDataSource(items: arrayCarsOrBrands, collectionView: collectionView, cellIdentifier: vcType == .model ? identifierTextTableViewCell : identifier, headerIdentifier: nil, cellHeight: vcType == .model ? 48 : cellHeight, cellWidth:vcType == .model ? UIScreen.main.bounds.width - 32 : cellWidth, configureCellBlock: { (_cell, item, indexPath) in
            
            if let cell = _cell as? CarsCollectionViewCell {
                
                cell.selectedModels = self.selectedCarOrBrands
                cell.vcType = self.vcType
                cell.model = item
                
            }else if let cell = _cell as? TextCollectionViewCell{
                
                cell.selectedModels = self.selectedCarOrBrands
                cell.model = item
    
            }
            
        }, aRowSelectedListener: { [unowned self] (indexPath, item) in
            
            self.actionRowSelectorCollectionView(indexPath: indexPath)
            
            }, willDisplayCell: nil, scrollViewDelegate: nil)
        
        collectionView.dataSource = dataSourceCollections
        collectionView.delegate = dataSourceCollections
        collectionView.reloadData()
        
    }
    
    func actionRowSelectorCollectionView(indexPath:IndexPath,selectionType:ENUM_SELECTION_TYPE = .multiple){
        
        if selectionType == .multiple{
            
            debugPrint(self.arrayCarsOrBrands)
            if let index = (self.selectedCarOrBrands as? [BrandOrCarModel])?.firstIndex(where: {$0.id == /(self.arrayCarsOrBrands as? [BrandOrCarModel])?[indexPath.item].id}){
                
                self.selectedCarOrBrands.remove(at: index)
                
            }else{
                
                debugPrint(/self.arrayCarsOrBrands.count)
                self.selectedCarOrBrands.append(self.arrayCarsOrBrands[indexPath.item])
                
            }
            
        }else{
            
            self.selectedCarOrBrands = [self.arrayCarsOrBrands[indexPath.item]]
            self.collectionView.reloadData()
            
        }
        
        
        switch self.vcType{
            
        case .make:
            
            (self.arrayCarsOrBrands as? [BrandOrCarModel])? [indexPath.item].arraySelectedModels = []
            
        case .model:
            
            (self.selectedData as? BrandOrCarModel)?.arraySelectedModels = self.selectedCarOrBrands as? [BrandOrCarModel]
            
        default:
            break
        }
        
        self.collectionView.reloadItems(at: [IndexPath.init(item: indexPath.item, section: 0)])
        
    }
    
    //MARK:- Button actions
    
    @IBAction func didTapRemove(_ sender: UIButton) {
        
        //for removeing using update profile api
        
        let isRemainOneInterest = /userData?.interestedMakes?.count == 1
        let title = /userData?.interestedMakes?.count == 1 ? "Alert!" : "Remove Interest?"
        let message = /userData?.interestedMakes?.count == 1 ? "You must have one interest for your better feed experience." : "Selected models corresponding to this make will also be removed from your interest.Are you sure you want to remove?"
        
        if isRemainOneInterest{
            
            self.alertBoxOk(message: message, title: title) {}
            
        }else{
           
            self.alertBox(message: message, title: title) { [weak self] in
                
                self?.apiUpdateInterestFromEditInterest(isRemoveInterest: true)
    
            }
            
        }
    
    }
    
    @IBAction func didTapNext(_ sender: UIButton) {
        
        switch vcType {
            
        case .make:
            
            let vc = ENUM_STORYBOARD<SelectedMakeOrBrandVC>.car.instantiateVC()
            
            vc.arraySelectedBrands = self.selectedCarOrBrands as! [BrandOrCarModel]
            vc.isFromSignupProcess = !isFromEditInterest
            vc.isFromEditInterest = isFromEditInterest
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .model:
            
            if isFromEditInterest{
            
                self.apiUpdateInterestFromEditInterest(isRemoveInterest: false)
                
            }else{
                
                self.navigationController?.popViewController(animated: true)
                
            }
            
        default:
            break
        }
        
        
        
    }
    
    
    //MARK:- Functions
   
    
    private func setSelectedCount(){
        
        let selectedString = "\(selectedCarOrBrands.count) vehicle makes selected"
        
        btnSelected?.setTitle(selectedCarOrBrands.isEmpty ? "" : selectedString, for: .normal)
        btnNext?.enableButton = vcType == .make ? !selectedCarOrBrands.isEmpty : true
        
    }
}


//MARK:- API

extension SelectMakeOrBrandOrModelVC{
    
    func apiUpdateInterestFromEditInterest(isRemoveInterest:Bool = false){ // for only models update
        
        //removing-> removing current selected make from userdefault and update
        
        var selectedInterests:[SelectedInterestedModel] = []
    
        
        userData?.interestedMakes?.forEach({ (data) in
            
            if isRemoveInterest{ // removing current make
                
                if data.makeId?.id != makeDataOfEditInterest?.id{
                    
                    let model = SelectedInterestedModel.init(makeId: /data.makeId?.id, modelIds: data.modelIds?.map({/$0.id}))
                    
                    selectedInterests.append(model)
                    
                }
          
            }else{
                
                let currentSelectedModelIds = (selectedCarOrBrands as? [BrandOrCarModel])?.map({/$0.id})
                let isCurrentSelectedMake = data.makeId?.id == makeDataOfEditInterest?.id
                
                let modelIds = isCurrentSelectedMake ? currentSelectedModelIds : data.modelIds?.map({/$0.id})
                
                let model = SelectedInterestedModel.init(makeId: /data.makeId?.id, modelIds: modelIds)
                
                selectedInterests.append(model)
                
            }
            
        })
        
        
        
        let jsonOfInterestBrands = JSONHelper<[SelectedInterestedModel]>().toDictionary(model: selectedInterests)
        let loginSignUpModel = LoginSignupViewModal()
        loginSignUpModel.interestedMakes = jsonOfInterestBrands
        
        
        EP_Profile.updateProfile(model: loginSignUpModel).request(success:{ [weak self] (response) in
            
            let userData = (response as? UserData)
            UserDefaultsManager.shared.loggedInUser = userData
            
            self?.navigationController?.viewControllers.forEach({ (vc) in
                
                if vc.isKind(of: ManageInterestVC.self){
                    
                    self?.navigationController?.popViewController(viewController: vc, animated: true, completion: {
                        
                    })
                }
                
            })
      
        })
        
    }
    
    func apiGetList(of type:ENUM_CAR_SELECTION_TYPE,search:String? = nil,brandId:String? = nil,loaderNeeded:Bool = true,idsToSort:Any? = nil){
        
        switch type{
            
        case .make,.model,.submodel:
            
            let jsonOFSortIds = (self.selectedCarOrBrands as? [BrandOrCarModel])?.map({/$0.id}).toJsonString()
            
            let makeRequestEndpoint = EP_Profile.get_make_model_list(search: search, id: nil, parentId: brandId, type: type.rawValue, limit: limit, skip: skip, year: nil, idsToSort: jsonOFSortIds)
                
            let modelRequestEndpoint = EP_Profile.get_model_listing(parentId: brandId, limit: limit, skip: skip, search: search, idsToSort: jsonOFSortIds)
                
            let endPoint = type == .model ? modelRequestEndpoint : makeRequestEndpoint
            
            endPoint.request(loaderNeeded: loaderNeeded, success: { [weak self] (response) in
                
                self?.searchField.activityIndicator?.stopAnimating()
                
                var _response = (response as? CarBrandsModel)?.list ?? []
                
                self?.arrayRemoveFromList?.forEach({ (data) in
                    
                    _response.removeAll(where: {/$0.id == data.id})
                    
                })
                
                self?.reloadData(response: _response)
                
                self?.searchField.activityIndicator?.stopAnimating()
                self?.collectionView.es.stopLoadingMore()
                self?.collectionView.es.stopPullToRefresh()
                
            }) { [weak self] (error) in
                
                self?.searchField.activityIndicator?.stopAnimating()
                self?.collectionView.es.stopLoadingMore()
                self?.collectionView.es.stopPullToRefresh()
            }
            
            
        case .brandOrSponsor:
            
            EP_Car.get_sponsor_list(search: search, limit: limit, skip: skip).request(loaderNeeded:loaderNeeded,success: { [weak self] (response) in
                
                let _response = (response as? [FeaturesListModel])
                self?.reloadData(response: _response)
                
                self?.searchField.activityIndicator?.stopAnimating()
                self?.collectionView.es.stopLoadingMore()
                self?.collectionView.es.stopPullToRefresh()
                
            }) { [weak self] (error) in
                
                self?.searchField.activityIndicator?.stopAnimating()
                self?.collectionView.es.stopLoadingMore()
                self?.collectionView.es.stopPullToRefresh()
            }
            
            
        case .myCars:
            
            EP_Car.get_car_feeds(id: nil, userId: userData?.id, loggedInUserId: userData?.id).request(success:{ [weak self] (response) in
                
                let _response = (response as? [CarListDataModel]) ?? []
                
                let filteredData = _response.filter({$0.beaconID == []})
                self?.reloadData(response: filteredData)
                self?.collectionView.es.stopLoadingMore()
                self?.collectionView.es.stopPullToRefresh()
                
            }) { [weak self] (error) in
                
                self?.searchField.activityIndicator?.stopAnimating()
                self?.collectionView.es.stopLoadingMore()
                self?.collectionView.es.stopPullToRefresh()
            }
            
        default:
            break
            
        }
    }
    
    
    func reloadData(response:Any?){
        
        if skip == 0{
            
            self.arrayCarsOrBrands = response as! [Any]
            
            dataSourceCollections?.items = arrayCarsOrBrands
            
            UIView.transition(with: (self.collectionView), duration: 0.2, options: .transitionCrossDissolve, animations: { [weak self] in
                
                self?.collectionView?.reloadData()
                
                }, completion: nil)
            
        }else{
            
            self.arrayCarsOrBrands += response as? [Any] ?? []
            
            self.dataSourceCollections?.items = self.arrayCarsOrBrands
            self.collectionView.reloadData()
            
            
        }
        
    }
    
    
}
