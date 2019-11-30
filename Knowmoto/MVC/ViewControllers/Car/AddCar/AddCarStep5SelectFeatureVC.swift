//
//  AddCarStep5VC.swift
//  Knowmoto
//
//  Created by Apple on 12/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

enum FeaturesListVCType{
    case editFeatures
    case addFeatures
    case selectForfilter
}

class AddCarStep5SelectFeatureVC: BaseAddCarVC {
    
    //MARK:- Outlets
    
    @IBOutlet weak var heightConstraintNoDataFound: NSLayoutConstraint!
    @IBOutlet weak var lblNoFeatureFoundText: UILabel!
    @IBOutlet weak var viewAddNotFoundData: UIView!
    @IBOutlet weak var flowLayout: CollectionViewLeftAlignedFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //Properties
    public var selectedFeatures:[Any] = []{
        didSet{
            checkSkip()
            btnNext?.enableButton = vcType == .editFeatures || vcType == .selectForfilter || !(/selectedFeatures.isEmpty)
        }
    }
    private var arrayItems:[String:[FeaturesListModel]] = [:]{
        didSet{
            debugPrint("sdf")
        }
    }
    
    //tableview
    private var dataSourceCollections:CollectionViewDataSourceWithMultipleTypeCells? = nil
    private var arrayIdentifiers = [String]()
    private let headerIdentifer = String(describing: TextCollectionViewReusableView.self)
    private let tagCellIdentifier = String(describing: TagCollectionViewCell.self)
    private let textCellIdentifier = String(describing: TextCollectionViewCell.self)
    
    //no data found
    
    var noFeatureAddedText:String = ""
    var isNoFeatureFound:Bool = false{
        didSet{
            
            noFeatureAddedText = searchField.text ?? ""
            lblNoFeatureFoundText.text = "There's no feature named '\(noFeatureAddedText)'"
            viewAddNotFoundData.isHidden = vcType == .selectForfilter || !isNoFeatureFound
            
        }
    }
    
    //vc type
    var vcType:FeaturesListVCType = .addFeatures{
        didSet{
            self.isFromEditCar = vcType == .editFeatures
        }
    }
    
    //flag of hide skip
    var isHideSkip:Bool = true{
        didSet{
            MainAddCarVC.headerView?.headerView.btnRight?.isHidden = isHideSkip
        }
    }
    
    
    
    weak var delegate:SelectMakeOrBrandOrModelVCDelegate?
    
    //MARK:-View controller lifecycle
    
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
    
    
    
    
    //MARK:- initial view controller setup
    func initialSetup(){
        
        
        
        //skip action handle
        actionSkip()
        
        //bydefault hide nodatafound
        viewAddNotFoundData.isHidden = true
        
        handleSearch()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in

            
            self?.configureCollectionViewDataSource()
            
            switch self?.vcType ?? .addFeatures {
                
            case .addFeatures:
                
                self?.actionSkip()
                self?.btnNext.enableButton = false
                
            case .editFeatures:
                
                self?.setEditData()
                
            case .selectForfilter:
                
                //unhide header view
                self?.headerView.isHidden = false
                
                //set labels
                self?.headerView.title = ""
                self?.lblTitle.text = "Search Keyword"
                self?.lblSubtitle.text = "Find or add a keywords for vehicle filters"
                self?.btnNext.setTitle("Done", for: .normal)
                
                //set selected features
                self?.arrayItems[/self?.tagCellIdentifier] = self?.selectedFeatures as? [FeaturesListModel]
                
                //reload data
                self?.dataSourceCollections?.arrayItemsDictionary = self?.arrayItems ?? [:]
                self?.collectionView.reloadData()
                
                //back button custom action
                self?.headerView.headerView.didTapLeftButton = { [weak self] (sender) in
                    
//                    self?.delegate?.didSelectFeatures(model: self?.selectedFeatures)
                    self?.navigationController?.popViewController(animated: true)
                    
                }
                
                break
                
            }
            
            
        }
        
        
    }
    
    
    func setEditData(){
        
        self.viewModel = AddEditCarViewModel()
        
        self.viewModel?.arrayFeatures = carData?.featureID ?? []
        
        self.selectedFeatures = carData?.featureID ?? []
        
        self.arrayItems[tagCellIdentifier] = carData?.featureID ?? []
        
        self.dataSourceCollections?.arrayItemsDictionary = self.arrayItems
        
        self.collectionView.reloadData()
        
    }
    
    //MARK:- Search handling
    
    func handleSearch(){
        
        searchField.didChangeSearchField = { [weak self] (text) in // getting user search text
            
            
//            self?.view.isUserInteractionEnabled = false
            
            if /text.trimmed().isEmpty{
                
                self?.searchField.activityIndicator?.stopAnimating()
                
                self?.resetArray()
                
                self?.view.isUserInteractionEnabled = true
                
                return
                
            }
            
            //            self?.searchField.becomeFirstResponder()
            
            let endPoint = self?.vcType == .selectForfilter ?
                EP_Car.get_available_fm(search: text, limit: nil, skip: nil) :
                EP_Car.get_features(search: text, limit: 5, skip: 0, isModification: nil)
                
            
            endPoint.request(loaderNeeded:false,success: { (response) in
                
                self?.searchField.activityIndicator?.stopAnimating()
                
                let _response = (response as? [FeaturesListModel]) ?? []
                
                self?.arrayItems[/self?.textCellIdentifier] = _response
                self?.dataSourceCollections?.arrayItemsDictionary = self?.arrayItems ?? [:]
                
                self?.collectionView.reloadData()
                
                let isContainedInList = self?.arrayItems[/self?.textCellIdentifier]?.contains(where: { self?.vcType == .selectForfilter ? (/$0.feature?.lowercased() == /self?.searchField.text?.lowercased()) : (/$0.feature?.lowercased() == /self?.searchField.text?.lowercased())})
                
                self?.isNoFeatureFound = !(isContainedInList ?? true)
                self?.view.isUserInteractionEnabled = true
                
            }, error: { (_) in
                
                self?.view.isUserInteractionEnabled = true
                self?.searchField.activityIndicator?.stopAnimating()
                
            })
            
        }
        
    }
    
    //MARK:- Button actions
    
    @IBAction func didTapAddNotFoundData(_ sender: Any) {
        
        viewAddNotFoundData.isHidden = true
        if !noFeatureAddedText.trimmed().isEmpty{
            self.actionAddFeature(item: FeaturesListModel.init(feature: noFeatureAddedText))
        }
        self.searchField.text = ""
        resetArray()
    }
    
    //next action
    @IBAction func didTapAddNext(_ sender: UIButton) {
        
        setApiViewModel()
        
        switch vcType {
            
        case .addFeatures:
            
            let vc = ENUM_STORYBOARD<AddCarStep6SponsorsVC>.car.instantiateVC()
            vc.viewModel = self.viewModel
            vc.vcType = .addSponsors
            self.navigationController?.pushViewController(vc, animated: true)
            
            NotificationCenter.default.post(name: .UPDATE_LOADING, object: nil)
            
        case .editFeatures:
            
            self.apiAddAndEditCar()
            
        case .selectForfilter:
            
            delegate?.didSelectFeatures(model: self.selectedFeatures)
            self.navigationController?.popViewController(animated: true)
            
            break
            
        }
        
        
    }
    
    //action remove tag
    @objc func didTapRemoveTag(sender:UIButton){
        
        self.arrayItems[tagCellIdentifier]?.remove(at: sender.tag)
        self.dataSourceCollections?.arrayItemsDictionary = arrayItems
        self.selectedFeatures = self.arrayItems[tagCellIdentifier] ?? []
        
        self.collectionView.performBatchUpdates({ [weak self] in
            
            self?.collectionView.deleteItems(at: [IndexPath.init(item: sender.tag, section: 1)])
            
        }) { [weak self] (_) in
            
            self?.collectionView.reloadData()
            
        }
        
    }
    
    @objc func didTapAddTag(sender:UIButton){
        
        //            if indexPath.section == 0{ //selection enabled only for searched list in section 0
        self.actionAddFeature(item: (self.arrayItems[/self.textCellIdentifier])?[sender.tag])
        
        //            }
        
    }
    
    
    //MARK:- Collecitonview configuration
    
    //configuring layout of collection view
    func configureCollectionViewLayout(){
        
        //Footer view register
        collectionView.registerNibCollectionCell(nibName: textCellIdentifier)
        collectionView.registerNibCollectionCell(nibName: tagCellIdentifier)
        collectionView.register(UINib(nibName: headerIdentifer, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifer)
        
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 80.0, right: 0.0)
        
        flowLayout?.sectionInset = UIEdgeInsets(top: 4.0, left: 16, bottom: 16, right: 16.0)
        flowLayout?.minimumLineSpacing = 8.0
        flowLayout?.minimumInteritemSpacing = 16.0
        
        arrayItems = [textCellIdentifier:[],tagCellIdentifier:[]]
        //setting collectionview items
        
        arrayIdentifiers = [textCellIdentifier,tagCellIdentifier]
        
    }
    
    //Configuring collection view data SOurce
    func configureCollectionViewDataSource(){
        
        self.configureCollectionViewLayout()
        
        //layout configuration
        let leftRightTotalPadding:CGFloat = 40.0
        let cellSpacing:CGFloat = 16.0
        let cellHeight:CGFloat = 38.0
        
        
        //creating instance of datasource with initialization
        
        dataSourceCollections = CollectionViewDataSourceWithMultipleTypeCells(arrayItemsDictionary: arrayItems, collectionView: collectionView, cellHeight: cellHeight, cellWidth: 56.0, identifiers: arrayIdentifiers, configureCellBlock: { [unowned self] (cell, item, indexPath) in
            
            if let _cell = cell as? TagCollectionViewCell{
                _cell.tagString = self.vcType == .selectForfilter ?  /(item as? FeaturesListModel)?.name : /(item as? FeaturesListModel)?.feature
                
                _cell.btnSelectedTag.tag = indexPath.item
                _cell.btnSelectedTag.addTarget(self, action: #selector(self.didTapRemoveTag(sender:)), for: .touchUpInside)
                
            }else if let _cell = cell as? TextCollectionViewCell{
                
                _cell.btnAdd.isHidden = false
                _cell.btnAdd.tag = indexPath.item
                _cell.btnAdd.addTarget(self, action: #selector(self.didTapAddTag(sender:)), for: .touchUpInside)
                _cell.lblName.text =  self.vcType == .selectForfilter ?  /(item as? FeaturesListModel)?.name : /(item as? FeaturesListModel)?.feature
            }
            
            
            
        }) { [weak self] (indexPath, item) in
            
//            if indexPath.section == 0{ //selection enabled only for searched list in section 0
//                self?.actionAddFeature(item: (self?.arrayItems[/self?.textCellIdentifier])?[indexPath.row])
//
//            }
            
        }
        
        
        
        
        //header footer in section
        
        dataSourceCollections?.headerFooterInSection = { [weak self] (indexPath) -> UICollectionReusableView in
            
            let footerView = self?.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: /self?.headerIdentifer, for: indexPath)
            let lblFeature = footerView?.viewWithTag(1) as? UILabel
            lblFeature?.text = "Features added"
            
            return footerView ?? UICollectionReusableView()
        }
        
        //height for row at
        
        dataSourceCollections?.headerHeightForSectionAt = { [weak self] (section) -> CGSize in
            
            let identifier = /self?.arrayIdentifiers[/section]
            let isEmpty = self?.arrayItems[identifier]?.isEmpty
            
            return CGSize(width: /self?.collectionView.frame.width, height: section == 0 || /isEmpty ? 0.0 : 40.0)
        }
        
        dataSourceCollections?.didSizeForItemAt = { [weak self] (indexPath) ->CGSize in
            
            if indexPath.section == 1{
                
                let feature = /(self?.arrayItems[self?.arrayIdentifiers[/indexPath.section] ?? ""]?[/indexPath.row])?.feature
                let tagString = /(self?.arrayItems[self?.arrayIdentifiers[/indexPath.section] ?? ""]?[/indexPath.row])?.name
                let tag = self?.vcType == .selectForfilter ? tagString : feature
                
                let cellWidth = (tag.widthOfString(font: ENUM_APP_FONT.bold.size(14)) ) + leftRightTotalPadding
                
                return CGSize(width: cellWidth, height: cellHeight)
                
            }else{
                
                return CGSize(width: /self?.collectionView.frame.width - 32, height: cellHeight)
                
            }
            
            
        }
        
        
        collectionView.dataSource = dataSourceCollections
        collectionView.delegate = dataSourceCollections
        collectionView.reloadData()
    }
    
    func actionSkip(){
        
        //skip button action
        
        MainAddCarVC.headerView?.headerView.didTapRightButton = { [weak self] (sender) in
            
            self?.didTapAddNext(UIButton())
        }
        
        
    }
    
    
}

//MARK:- common use functions

extension AddCarStep5SelectFeatureVC{
    
    func checkSkip(){
        
        isHideSkip = !(/selectedFeatures.isEmpty) //skip button
    }
    
    func resetArray(){
        
        self.arrayItems[/self.textCellIdentifier] = []
        self.dataSourceCollections?.arrayItemsDictionary = self.arrayItems
        self.isNoFeatureFound = false
        self.collectionView.reloadData()
        
    }
    
    func setApiViewModel(){
        
        
        viewModel?.arrayFeatures = (self.selectedFeatures as? [FeaturesListModel])
        viewModel?.featureId = (self.selectedFeatures as? [FeaturesListModel])?.map({/$0.id})
    }
    
    func actionAddFeature(item:Any){
        
        self.view.endEditing(true)
        
        let featureName = self.vcType == .selectForfilter ?  /(item as? FeaturesListModel)?.name : /(item as! FeaturesListModel).feature
        
        if /self.arrayItems[/self.tagCellIdentifier]?.contains(where: {self.vcType == .selectForfilter ? (/$0.name?.trimmed() == /featureName.trimmed()) : (/$0.feature?.trimmed() == /featureName.trimmed())}){
            
            Toast.show(text: "Feature already added in list".localized, type: .error)
            return
        }
        
        self.collectionView.performBatchUpdates({
            
            self.arrayItems[/self.tagCellIdentifier]?.append(item as! FeaturesListModel)
            
            self.dataSourceCollections?.arrayItemsDictionary = self.arrayItems
            self.selectedFeatures = self.arrayItems[tagCellIdentifier] ?? []
            
            self.collectionView.insertItems(at: [IndexPath.init(item: /self.arrayItems[/self.tagCellIdentifier]?.count - 1, section: 1)])
            
            
            if /self.arrayItems[/self.tagCellIdentifier]?.count < 2{
                self.collectionView.reloadSections(IndexSet.init(integer: 1))
            }
            
        }, completion: { (_) in
            
            self.collectionView.reloadData()
            
        })
        
    }
    
    
}
