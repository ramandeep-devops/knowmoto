//
//  AddCarPagerVC.swift
//  Knowmoto
//
//  Created by Apple on 10/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class ModelSelection{
    
    var name:String?
    var isSelected:Bool?
    var selectedIndexPath:IndexPath?
    
    init(name:String?) {
        self.name = name
    }
    
    
}

class AddCarStep2SelectModelVC: BaseAddCarVC {
    
    //MARK:- outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var heightConstraintCollectionView: NSLayoutConstraint!
    @IBOutlet weak var textFieldSelectYear: KnowMotoTextField!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var lblMakeName: UILabel!
    @IBOutlet weak var imageViewMake: KnowmotoUIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK:- Properties

    
    var arraySectionTitles = ["Model","Submodel","Color"]
    
    var isModelSelected:Bool = false{
        didSet{
            
            self.setNextButton()
        }
    }
    var isSubmodelOrTypeSelected:Bool = false{
        didSet{
            self.setNextButton()
        }
    }
    var isColorSelected:Bool = false{
        didSet{
            self.setNextButton()
        }
    }
    
    var arrayTags2:[[BrandOrCarModel]] = []
    var dataSourceCollections:CollectionViewDataSourceForSections? = nil
    let group = DispatchGroup()
    var isMakeChangedInEditCar:Bool = false
    var isEnableScrollToSelectedItem:Bool = true
    var arrayColors:[BrandOrCarModel] = []
    
    
    //View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initialSetup()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.view.layoutIfNeeded()
        let contentHeight = self.collectionView.contentSize.height
        heightConstraintCollectionView.constant = contentHeight < collectionViewStartingHeight() ? collectionViewStartingHeight() : contentHeight
        
    }
    
    func collectionViewStartingHeight() -> CGFloat{
        
        let screenHeight = UIScreen.main.bounds.height
        let height = screenHeight - 462 //calcualated height of screen other views escept collectionview
        return height
    }
    
    func initialSetup(){
        
        imageViewMake.loadImage(key: /viewModel?.makeId?.image?.first?.thumb, isLoadWithSignedUrl: false)
        lblMakeName.text = /viewModel?.makeId?.name
        isEnableScrollToSelectedItem = !isFromEditCar //for reload all items first time disbale scrolling to item
        apiGetYears()
        apiGetColors()
        self.configureCollectionView()
      
    }

    
    func configurePlanPickerView(textField:UITextField){ //---- usage of this function for open select weeks
        
        textField.inputView = pickerViewYear
        textField.tintColor = UIColor.clear
        pickerViewYear.backgroundColor = UIColor.backGroundHeaderColor!
        
        dataSourcePickerViewYear = PickerViewCustomDataSource(textField: textField, picker: pickerViewYear, items: arrayYears, columns: 1) { [weak self] (selectedRow, item) in
            
            debugPrint(item)
            self?.textFieldSelectYear.text = String(/(item as? Int))
            
        }
        
        dataSourcePickerViewYear?.aSelectedBlock = { [weak self] (selectedRow,item) in
            
            self?.view.endEditing(true)
            self?.textFieldSelectYear.text = self?.arrayYears[selectedRow].toString
            self?.arrayTags2 = []
            self?.dataSourceCollections?.items = self?.arrayTags2
            self?.collectionView.reloadData()
            
            self?.apiGetModelsSubModelsColors(of: .model, parentId: self?.viewModel?.makeId?.id, loaderneeded: true, year: self?.arrayYears[selectedRow])
        }
        
        dataSourcePickerViewYear?.titleForRowAt = { [weak self] (row,component)-> String in
            
            return /self?.arrayYears[row].toString
            
        }
        
    }
    
    func configureCollectionView(){ //Configuring collection View cell
        
        self.collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0, bottom: 80.0, right: 0)
        
        flowLayout?.sectionInset = UIEdgeInsets(top: 4.0, left: 16, bottom: 16, right: 16.0)
        flowLayout?.minimumLineSpacing = 16.0
        flowLayout?.minimumInteritemSpacing = 16.0
        
        
        let identifier = String(describing: TagCollectionViewCell.self)
        collectionView.registerNibCollectionCell(nibName: identifier)
        
        let cellHeight:CGFloat = 44.0
        let leftRightTotalPadding:CGFloat = 40.0
        
        let headerIdentifer = String(describing: TextCollectionViewReusableView.self)
        collectionView.register(UINib(nibName: headerIdentifer, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifer)
        
        dataSourceCollections = CollectionViewDataSourceForSections.init(items: arrayTags2, collectionView: collectionView, cellIdentifier: identifier, headerIdentifier: headerIdentifer, cellHeight: cellHeight, cellWidth: 56.0, configureCellBlock: { (cell, item, indexPath) in
            
            let _cell = cell as? TagCollectionViewCell
            _cell?.model = item
            
        }, aRowSelectedListener: { [weak self] (indexPath, item) in
            
      
            if let index = self?.unSelectTag(indexPath: indexPath){
                
                if indexPath.item == index{
                    return
                }
            }
            
            self?.selectTag(indexPath: indexPath)
            
            
        }, willDisplayCell: nil, scrollViewDelegate: nil)
        
        //header footer in section
        
        dataSourceCollections?.headerFooterInSection = { [weak self] (indexPath) -> UICollectionReusableView in
            
            let headerView = self?.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: /headerIdentifer, for: indexPath)
            let lblFeature = headerView?.viewWithTag(1) as? UILabel
            lblFeature?.text = self?.arraySectionTitles[indexPath.section]
            
            return headerView ?? UICollectionReusableView()
        }
        

        dataSourceCollections?.headerHeight = 48.0
        
        
        dataSourceCollections?.didSizeForItemAt = { [weak self] (indexPath) ->CGSize in
            
            let cellWidth = ((self?.arrayTags2[indexPath.section][indexPath.item])?.name?
                .widthOfString(font: ENUM_APP_FONT.bold.size(14)) ?? 0) + leftRightTotalPadding
            
            return CGSize(width: cellWidth, height: cellHeight)
        }
        
        collectionView.dataSource = dataSourceCollections
        collectionView.delegate = dataSourceCollections
        self.collectionView.reloadData()
        
    }
    
    func unSelectTag(indexPath:IndexPath) ->Int?{
        
        //unselect previous selected cell
        if let index = self.arrayTags2[indexPath.section].firstIndex(where: {/$0.isSelected == true}){
            
            self.arrayTags2[indexPath.section][index].isSelected = false
            
            self.didSelectDeselectTag(model: self.arrayTags2[indexPath.section][index])
            
            let cell = (self.collectionView.cellForItem(at: IndexPath.init(item: index, section: indexPath.section)) as? TagCollectionViewCell) //accessing direct cell
            
         
            cell?.model = self.arrayTags2[indexPath.section][index]
     
            return index
            
        }else{
            return nil
        }
    }
    
    func selectTag(indexPath:IndexPath){
        
        //selecting new selected cell
        let model = self.arrayTags2[indexPath.section][indexPath.item]
        
        model.isSelected = !(/model.isSelected) // set selected
        
        let cell = (self.collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell) //accessing direct cell
        
        cell?.model = model
        self.didSelectDeselectTag(model: model)
    }

    
    @IBAction func didTapAddNext(_ sender: UIButton) {
        
        setApiModel()
        
        if isFromEditCar{
            
            self.apiAddAndEditCar()
            
        }else{
            
            let vc = ENUM_STORYBOARD<AddCarStep3AddPicsVC>.car.instantiateVC()
            vc.viewModel = self.viewModel
            self.navigationController?.pushViewController(vc, animated: true)
            
            NotificationCenter.default.post(name: .UPDATE_LOADING, object: nil)
            
        }
    }
    
    func setApiModel(){
        
        self.viewModel?.year = /self.textFieldSelectYear.text?.toInt()
        
    }
    
    
    func setNextButton(){
        
        btnNext.enableButton = isColorSelected && isSubmodelOrTypeSelected && isModelSelected
    }
    
    
}

//MARK:- API and delegates
extension AddCarStep2SelectModelVC:TagTableViewCellDelegate{
    
    func apiGetYears(){
        
        if isFromEditCar{
            
            self.startAnimateLoader()
        }
        
        EP_Car.get_make_years(id: /viewModel?.makeId?.id ).request(loaderNeeded:!isFromEditCar,success: { [weak self] (response) in
            
            self?.arrayYears = (response as? YearPickerModel)?.list ?? []
            self?.configurePlanPickerView(textField: (self?.textFieldSelectYear)!)
            
            self?.setEditCarData(type: .years)
           
        })
        
    }
    
    func apiGetColors(){
        
        EP_Car.colorsList().request(loaderNeeded: false, success: { (response) in
            
            if let colorsList = (response as? [BrandOrCarModel]){
                
                self.arrayColors = colorsList
                
            }
            
        }) { (error) in
            
            
        }
        
    }
    
    func apiGetModelsSubModelsColors(of type:ENUM_CAR_SELECTION_TYPE,parentId:String? = nil,loaderneeded:Bool = true,year:Int? = nil,completion:(()->())? = nil){

        
        EP_Profile.get_make_model_list(search: nil, id: nil, parentId: parentId, type: type.rawValue, limit: 200, skip: 0,year:year, idsToSort: nil).request(loaderNeeded:false,success:{ [weak self] (response) in
            
            let _response = (response as? CarBrandsModel)?.list ?? []
    
            if !_response.isEmpty{
                
                
                 //get submodel list and insert to array
                if /self?.arrayTags2.isEmpty || /self?.arrayTags2.count == 1{
       
                    self?.arrayTags2.insert(_response, at: type.rawValue - 2)
                    
                }else{
                    
                    self?.arrayTags2[type.rawValue - 2] = _response

                }
                
                self?.collectionView.performBatchUpdates({
                    
                    self?.collectionView.reloadData()
                    
                }, completion: { (_) in
                    
                    self?.viewDidLayoutSubviews()
                    self?.view.layoutIfNeeded()
                    
                    if (type == .submodel && (/self?.isEnableScrollToSelectedItem)) || (/self?.isMakeChangedInEditCar){
                        
                        self?.scrollView.scrollToBottom(animated: true)
 
                    }
                    
                })
 
     
            }else{
                
                //remove submodel list on click model or change model selection
                if /self?.arrayTags2.count > 1{
                    
                    self?.arrayTags2.remove(at: type.rawValue - 2)
                    
                }
                
            }
       
            
            self?.dataSourceCollections?.items = self?.arrayTags2
            
            self?.collectionView.performBatchUpdates({
                self?.collectionView.reloadData()
            }) { (_) in
                
                self?.viewDidLayoutSubviews()
                self?.view.layoutIfNeeded()
                
            }

            if /self?.isFromEditCar && !(/self?.isMakeChangedInEditCar){ //no change in make edit time and from edit car screen
                
                self?.setEditCarData(type: type)
                
            }
            
            if /self?.isFromEditCar && /self?.arrayTags2.count >= 2{
                
                self?.stopAnimating()
                
            }
            
            completion?()
            
            
        })
        
    }
    
    func setEditCarData(type:ENUM_CAR_SELECTION_TYPE){
        
        switch type {
            
        case .years:
            
            if let yearIndex = self.arrayYears.firstIndex(where: {$0 == /self.carData?.year}),/self.isFromEditCar,!(/self.isMakeChangedInEditCar){
                
                //selecting year of edit car
                self.pickerViewYear.selectRow(yearIndex, inComponent: 0, animated: false)
                self.dataSourcePickerViewYear?.didSelectRowOnDone(sender: (self.textFieldSelectYear))
                
            }
            
        case .model:
            
            if let modelIndex = self.arrayTags2.first?.firstIndex(where: {/$0.id == /self.carData?.model?.first?.id}){
                
                self.selectTag(indexPath: IndexPath.init(item: modelIndex, section: 0))
                
            }
            
        case .submodel:
            
            if let modelIndex = self.arrayTags2[1].firstIndex(where: {/$0.id == /self.carData?.subModel?.first?.id}){
                
                self.selectTag(indexPath: IndexPath.init(item: modelIndex, section: 1))
                
            }
            
        case .color:
            
            if let modelIndex = self.arrayTags2[2].firstIndex(where: {/$0.name == /self.carData?.subModel?.first?.color?.first}){
                
                self.selectTag(indexPath:IndexPath.init(item: modelIndex, section: 2))
                
            }
            
            break
        default:
            break
        }
        
       
        
    }
    
    
    func didSelectDeselectTag(model: BrandOrCarModel?) { //
        
        let selectionType = ENUM_CAR_SELECTION_TYPE.init(rawValue: /model?.type) ?? .color
        
        switch selectionType {
            
        case .model:
            
            if /model?.isSelected{
                
                viewModel?.makeId?.modelId = model
                
                isModelSelected = true
                isColorSelected = false
                isSubmodelOrTypeSelected = false
                
                self.apiGetModelsSubModelsColors(of: ENUM_CAR_SELECTION_TYPE(rawValue: /model?.type + 1) ?? .submodel, parentId: /model?.id,loaderneeded:false)
                
            }else if self.arrayTags2.count > 1{
                
                viewModel?.makeId?.modelId = nil
                
                isModelSelected = false
                
                self.arrayColors.forEach({$0.isSelected = false})
                self.arrayTags2.removeLast(self.arrayTags2.count == 3 ? 2 : 1)
                self.dataSourceCollections?.items = self.arrayTags2
                
                self.collectionView.reloadData()
                
                self.collectionView.performBatchUpdates({
                    
                    self.collectionView.reloadData()
                    
                }) { (_) in
                    
                    self.viewDidLayoutSubviews()
                    self.view.layoutIfNeeded()
                    
                }
                
                
            
            }
            
        case .submodel:
            
            if /model?.isSelected{
                
                
                isSubmodelOrTypeSelected = true
                isColorSelected = false
                
                viewModel?.makeId?.modelId?.subModel = SubModel.init(color: nil, id: /model?.id)
                viewModel?.makeId?.modelId?.subModel?.subModelName = /model?.name
                
                var arrayColorsModel:[BrandOrCarModel] = []
                
                model?.color?.forEach({arrayColorsModel.append(BrandOrCarModel(name: $0,id:/model?.id,type:4))}) //creating color array model from submodel contained colors list
                
                if self.arrayTags2.count == 3{ //if already contains colors
                    
                    self.arrayTags2[2] = self.arrayColors//arrayColorsModel

                    
                }else{ // not contains in array tags array add colors array
                    
                   self.arrayTags2.append(self.arrayColors)// self.arrayTags2.append(arrayColorsModel)
                    
                    
                }
                self.dataSourceCollections?.items = self.arrayTags2
                self.collectionView.reloadData()
                
                self.collectionView.performBatchUpdates({ [weak self] in
                    
                    self?.collectionView.reloadData()
                    
                }, completion: { [weak self] (_) in
            
                    self?.viewDidLayoutSubviews()
                    self?.view.layoutIfNeeded()
                    
                    if /self?.isEnableScrollToSelectedItem || (/self?.isMakeChangedInEditCar){
                        
                        self?.scrollView.scrollToBottom(animated: true)
 
                        
                    }else{
                        
                        if !(/self?.isMakeChangedInEditCar){ // if no change in make selected
                            
                            self?.setEditCarData(type: .color)
                            
                        }
                        
                    }
                    
                    self?.isEnableScrollToSelectedItem = self?.arrayTags2.count == 3
           
                })
                
                
            }else if self.arrayTags2.count > 2{ // remove color model
                
                isSubmodelOrTypeSelected = false
                
                viewModel?.makeId?.modelId?.subModel = nil
                
                self.arrayColors.forEach({$0.isSelected = false})
                self.arrayTags2.remove(at: 2)
                self.dataSourceCollections?.items = self.arrayTags2
                
                self.collectionView.reloadData()
                
                self.collectionView.performBatchUpdates({
                    
                    self.collectionView.reloadData()
                    
                }) { (_) in
                    
                    self.viewDidLayoutSubviews()
                    self.view.layoutIfNeeded()
                    
                }
                
                
            }else {
                
                viewModel?.makeId?.modelId?.subModel = nil
                isSubmodelOrTypeSelected = false
                
                self.dataSourceCollections?.items = self.arrayTags2
                
                self.collectionView.performBatchUpdates({
                    
                    self.collectionView.reloadData()
                    
                }) { (_) in
                    
                    self.viewDidLayoutSubviews()
                    self.view.layoutIfNeeded()
                    
                }
//                self.collectionView.reloadData()
            }
            
            
        case .color:
            
            viewModel?.makeId?.modelId?.subModel?.color = model?.name
//            viewModel?.makeId?.modelId?.subModel?.id = model?.id
            isColorSelected = (/model?.isSelected)
            
        default:
            
            break
        }
        
        
        
        
    }

}
