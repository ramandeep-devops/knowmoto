//
//  AddCarStep3VC.swift
//  Knowmoto
//
//  Created by Apple on 12/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit


class AddCarStep3AddPicsVC: BaseAddCarVC{
    
    
    //MARK:- Outlets
    
    
    @IBOutlet weak var textFieldNickName: KnowMotoTextField!
    @IBOutlet weak var textFieldCountry: KnowMotoTextField!
    @IBOutlet weak var textFieldYearPicker: KnowMotoTextField!
    @IBOutlet weak var btnAddNewPic: UIButton!
    @IBOutlet weak var containerViewDotted: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK:- Properties
    
    var dataSourceCollections:CollectionViewDataSource?
    
    var arrayPics:[ImageUpload] = [ImageUpload(isAddButton: true)]
    //MARK:- View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
    
    func initialSetup(){
        
        lblSubtitle.text = isFromEditCar ? "Edit or Add a Nickname and Gallery".localized : "Mention other details & upload pics of your vehicle"
        
        self.viewModel?.uiImages = []
        
        arrayYears = Array(1980...Date().year)
        
//        self.configurePlanPickerView(textField: textFieldYearPicker)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            
            self?.configureCollectionView()
        }
        
        if isFromEditCar{
            
            setEditData()
            
        }else{
            
            textFieldNickName.text = "My \(/viewModel?.makeId?.name) \(/viewModel?.makeId?.modelId?.name)"
            
        }
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        self.collectionView.addGestureRecognizer(longPressGesture)
        
    }
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            if selectedIndexPath.item == 0{
                return
            }
            
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    func setEditData(){
        
        textFieldNickName.text = /carData?.nickName
        
        self.viewModel = AddEditCarViewModel()
        
        self.viewModel?.nickName = carData?.nickName
        self.viewModel?.image = carData?.image ?? []
        
        carData?.image?.forEach({ (imageData) in
            
            arrayPics.append(ImageUpload.init(original: imageData.originalImageKey, thumbnail: imageData.thumbImageKey, image: nil, isImageUploaded: true,isLoadFromUrl:true))
            
        })
        
        self.dataSourceCollections?.items = self.arrayPics
        self.collectionView.reloadData()
        
    }
    
    
    func configureCollectionView(){ //Configuring collection View cell
        
        let cellSpacing:CGFloat = 16.0
        let cellWidth:CGFloat = (UIScreen.main.bounds.width - (cellSpacing * 4))/3
        let cellHeight:CGFloat = cellWidth
        
        
        let identifier = String(describing: ImageCollectionViewCell.self)
        collectionView.registerNibCollectionCell(nibName: identifier)
        
        
        dataSourceCollections = CollectionViewDataSource(items: arrayPics, collectionView: collectionView, cellIdentifier: identifier, headerIdentifier: nil, cellHeight: cellHeight,canMoveItem:true, cellWidth: cellWidth, configureCellBlock: { [unowned self] (_cell, item, indexPath) in
            
            let cell = _cell as? ImageCollectionViewCell
            
            //setting cornder radius
            cell?.layer.cornerRadius = 8
            cell?.clipsToBounds = true
            
            //configuring cell
            cell?.configureForAddPicCell(indexPath: indexPath, model: item)
            
            //adding target action
            cell?.btnRemove.addTarget(self, action: #selector(self.didTapRemovePic(sender:)), for: .touchUpInside)
            cell?.btnAddItemView.addTarget(self, action: #selector(self.didTapAddPicture(_:)), for: .touchUpInside)
            
            
            }, aRowSelectedListener: { [unowned self] (indexPath, item) in
                
                
            }, willDisplayCell: nil, scrollViewDelegate: nil)
        
        
        dataSourceCollections?.didMoveItemAt = { [unowned self] (sourceIndexPath,destinationIndexPath) in
      
            let item = self.arrayPics.remove(at: sourceIndexPath.item)
            self.arrayPics.insert(item, at: destinationIndexPath.item)
            self.dataSourceCollections?.items = self.arrayPics
//            self.
            
        }
        
        collectionView.dataSource = dataSourceCollections
        collectionView.delegate = dataSourceCollections
        collectionView.reloadData()
        
    }
    
//    func configurePlanPickerView(textField:UITextField){ //---- usage of this function for open select weeks
//
//        textField.inputView = pickerViewYear
//        textField.tintColor = UIColor.clear
//        pickerViewYear.backgroundColor = UIColor.backGroundHeaderColor!
//
//        dataSourcePickerViewYear = PickerViewCustomDataSource(textField: textField, picker: pickerViewYear, items: arrayYears, columns: 1) { [weak self] (selectedRow, item) in
//
//            debugPrint(item)
//            self?.textFieldYearPicker.text = String(/(item as? Int))
//
//        }
//
//        dataSourcePickerViewYear?.titleForRowAt = { [weak self] (row,component)-> String in
//
//            return /self?.arrayYears[row].toString
//
//        }
//
//    }
    
    //MARK:- Button actions
    
    @objc func didTapRemovePic(sender:UIButton){
        
        viewModel?.uiImages?.remove(at: sender.tag - 1)
        self.arrayPics.remove(at: sender.tag)
        self.dataSourceCollections?.items = self.arrayPics
        
        self.collectionView.deleteItems(at: [IndexPath.init(item: sender.tag, section: 0)])
        self.collectionView.reloadData()
    }
    
    
    //select picture
    
    @objc @IBAction func didTapAddPicture(_ sender: UIButton) {
        
        
        if /arrayPics.count > 1{ //
            
            if !(/arrayPics[1].isImageUploaded){
                
                Toast.show(text: "Please upload already added image first to continue upload next image".localized, type: .error)
                return
            }
            
        }
        
        self.view.endEditing(true)
        
        CameraGalleryPickerBlock.sharedInstance.pickerImage(pickedListner: { [weak self] (image, imageData, mediatype) in
            
            self?.collectionView.isUserInteractionEnabled = false
            
            self?.viewModel?.uiImages?.insert(image, at: 0)
            
            self?.arrayPics.insert(ImageUpload(original: "", thumbnail: "", image: image, isImageUploaded: false), at: 1)
            
            self?.dataSourceCollections?.items = self?.arrayPics ?? []
            
            let indexPath = IndexPath.init(item: 1, section: 0)
            
            self?.collectionView.performBatchUpdates({
                
                self?.collectionView.insertItems(at: [indexPath])
                
            }, completion: { [weak self] (_) in
                
                DispatchQueue.main.async {
                    
                    self?.collectionView.reloadItems(at: self?.collectionView.indexPathsForVisibleItems ?? [])
                    
                    
                    let cell = self?.collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell
                    cell?.imageViewPhoto.image = image
                    
                    _ = S3BucketHelper.shared.setImage(indexPath:indexPath,image: image, dictImages: nil, imageView: cell?.imageViewPhoto, completeion: { [weak self] (originalUrl, thumbnailUrl,indexPath) in
                        
                        
                        DispatchQueue.main.async {
                            
                            cell?.btnRemove.isHidden = false
                            
                            let imageUploaded = !(/originalUrl.isEmpty && /thumbnailUrl.isEmpty)
                            self?.collectionView.isUserInteractionEnabled = true
                            
                            let originalImageKey = /originalUrl.components(separatedBy: "/").last
                            let thumbImageKey = /thumbnailUrl.components(separatedBy: "/").last
                            
                            self?.arrayPics[/indexPath?.item] =  ImageUpload(original: originalImageKey, thumbnail: thumbImageKey, image: image, isImageUploaded: imageUploaded)
                            
                            self?.dataSourceCollections?.items = self?.arrayPics
                            
                            
                        }
                        
                        debugPrint("original url:-",originalUrl)
                        debugPrint("thumbnailUrl:-",thumbnailUrl)
                        
                        
                    })
                    
                    
                }
                
                
            })
            
            
        }) {
            
        }
        
    }
    
    //Country picker selection
    
    @IBAction func didTapCountryPicker(_ sender: Any) {
        
//        let vc = ENUM_STORYBOARD<CountryCodeSearchViewController>.miscelleneous.instantiateVC()
//        vc.delegate = self
//        self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func didTapAddNext(_ sender: UIButton) {
        
        setApiModel()
        
        let valid = Validations.sharedInstance.validateAddCarStep3(year: /viewModel?.year?.toString, country: /viewModel?.country, nickName: /viewModel?.nickName?.trimmed(),arrayPics: self.arrayPics)
        
        switch valid{
            
        case .success:
            
            if isFromEditCar{
                
                self.apiAddAndEditCar()
                
            }else{
                
                let vc = ENUM_STORYBOARD<AddCarStep4ModificationVC>.car.instantiateVC()
                vc.viewModel = self.viewModel
                self.navigationController?.pushViewController(vc, animated: true)
                NotificationCenter.default.post(name: .UPDATE_LOADING, object: nil)
                
            }
            
        case .failure(let error):
            
            Toast.show(text: error, type: .error)
            
        }
   
    }
    
    func setApiModel(){
        
//        viewModel?.country = textFieldCountry.text
//        viewModel?.year = textFieldYearPicker.text?.toInt()
        viewModel?.nickName = textFieldNickName.text
        
        var arrayImages:[ImageUrlModel] = []
        
        arrayPics.forEach({arrayImages.append(ImageUrlModel.init(original: $0.original, thumb: $0.thumbnail))})
        arrayImages.removeFirst() //this is add button removing from display model
        viewModel?.image = arrayImages
        
    }
    
}
extension AddCarStep3AddPicsVC:CountryCodeSearchDelegate{
    
    func didTap(onCode detail: [AnyHashable : Any]!) {
        
//        let name = /(detail[ENUM_COUNTRY_PICKER_KEYS.name.rawValue] as? String)
//        textFieldCountry.text = name
//
    }
    
}
