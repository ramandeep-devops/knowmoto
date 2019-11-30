//
//  CarModelVC.swift
//  Knowmoto
//
//  Created by Amandeep tirhima on 2019-08-17.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit


class MakeModelHeaderListVC: BaseVC {
    
    //MARK:- OUTLETS
    @IBOutlet weak var lblNoOfPosts: UILabel!
    @IBOutlet weak var imageViewMakeOrModel: KnowmotoUIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnAlert: KnomotButton!
    @IBOutlet weak var viewNotification: UIView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    //MARK:- PROPERTIES
    
    var searchData:SearchDataModel?
    var collectionDataSource:CollectionViewDataSource?
    var totalPosts:Int = 0{
        didSet{
            lblNoOfPosts.text = "\(totalPosts) \(/(totalPosts == 1 ? "Post" : "Posts"))"
        }
    }
    var arrayItems:[CarListDataModel] = []{
        didSet{
            collectionDataSource?.items = arrayItems
            self.collectionView.reloadData()
        }
    }
    var delegate:MakeModelPostListsSegmentedVCDelegate?
    var isSetAlert:Bool = false{
        didSet{
            self.searchData?.alertByMe = isSetAlert
            self.setAlertButton(ofStateSelected: /self.searchData?.alertByMe)
            self.delegate?.didSetAlert(ofStateSelected: /self.searchData?.alertByMe)
        }
    }
    
    //MARK:- LIFE CYCLE METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
    
    func initialSetup(){
        
        apiMakeModelsList()
        
        if /searchData?.type == 1{ //make
            
            self.configureCollectionView()
            
        }
        
        setupUI()
    }
    
    func setupUI(){
        
        imageViewMakeOrModel.loadImage(nameInitial: /searchData?.name, key: /searchData?.image?.first?.thumb, isLoadWithSignedUrl: false, cacheKey: /searchData?.image?.first?.thumbImageKey, placeholder: nil, completion: nil)
        
        //        imageViewMakeOrModel.loadImage(key: /searchData?.image?.first?.thumb, cacheKey: /searchData?.image?.first?.thumbImageKey)
        lblTitle.text = searchData?.name
        lblNoOfPosts.text = "\(totalPosts) Posts"
        
        //        self.setAlertButton(ofStateSelected: /searchData?.alertByMe)
    }
    
    //MARK:- Button Actions
    
    @IBAction func didTapSetAlert(_ sender: UIButton) {
        
//        if !sender.isSelected{
        
            self.apiSetAlert()
            
//        }
    }
    
    //set alert button
    func setAlertButton(ofStateSelected:Bool){
        
        btnAlert.isSelected = ofStateSelected
        btnAlert.backgroundColor = ofStateSelected ? UIColor.clear : UIColor.BlueColor!
        btnAlert.layer.borderColor = UIColor.BlueColor!.cgColor
        btnAlert.layer.borderWidth = ofStateSelected ? 1.0 : 0.0
        btnAlert.setTitleColor(ofStateSelected ? UIColor.BlueColor! : UIColor.white, for: .normal)
        
        //hide on guest user
        btnAlert.isHidden = UserDefaultsManager.isGuestUser
        
    }
    
    
    //MARK:- CONFIGURE COLLECTION CELL
    func configureCollectionView(){
        
        // set cell spacing
        let cellSpacing:CGFloat = 16
        
        // identifier and Xib registration
        let identifier = String(describing: TagCollectionViewCell.self)
        collectionView.registerNibCollectionCell(nibName: identifier)
        
        let cellHeight:CGFloat = 56.0
        let leftRightTotalPadding:CGFloat = 44.0
        
        collectionDataSource = CollectionViewDataSource(items:arrayItems, collectionView: collectionView, cellIdentifier: identifier, headerIdentifier: nil
            , cellHeight: 48.0,cellWidth:56.0, configureCellBlock:{(cell, item, indexPath) in
                
                // get cell data
                if let _cell = cell as? TagCollectionViewCell {
                    
                    _cell.configureCellWithSelection(selectedTag: [], tagName: /(item as? CarListDataModel)?.name)
                    
                }
                
        }, aRowSelectedListener:{ [weak self] (indexPath,item) in
            
            if let carData = self?.arrayItems[indexPath.item]{
                self?.redirectToMakeModelListVC(item: .init(data: carData, type: ENUM_MAIN_SEARCH_TYPE.model.rawValue))
            }
            
            
            } , willDisplayCell:nil , scrollViewDelegate:nil)
        
        collectionDataSource?.didSizeForItemAt = { [weak self] (indexPath) ->CGSize in
            
            let cellWidth = ((self?.arrayItems[indexPath.item].name?.widthOfString(font: ENUM_APP_FONT.bold.size(14)) ?? 0) + leftRightTotalPadding)
            
            return CGSize(width: cellWidth, height: cellHeight)
        }
        
        collectionView.dataSource = collectionDataSource
        collectionView.delegate = collectionDataSource
        collectionView.reloadData()
    }
    
    //redirect to make modal list
    func redirectToMakeModelListVC(item:SearchDataModel){
        
        let vc = ENUM_STORYBOARD<MakeModelPostListsSegmentedVC>.car.instantiateVC()
        vc.searchData = item
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension MakeModelHeaderListVC{
    
    func apiSetAlert(){
        
        EP_Car.makeAlert(id: searchData?.id).request(loaderNeeded: true, success: { [weak self] (response) in
            
            DispatchQueue.main.async {
                
                self?.isSetAlert = !(/self?.isSetAlert)
                
            }
            
        }) { (error) in
            
        }
        
    }
    
    //api for get search data make modals list
    func apiMakeModelsList(){
        
        EP_Post.get_main_search_data(search: nil, id: searchData?.id, type: searchData?.type, limit: 10, skip: 0, loggedInUserId: userData?.id).request(loaderNeeded: true, successMessage: nil, success: { (response) in
            
            if let response = (response as? RootListModel<CarListDataModel>){
                
                self.totalPosts = (response).totalPosts ?? 0
                let response1 = (response).list ?? []
                self.isSetAlert = response.alertByMe ?? false
                self.arrayItems = response1
                
            }else if let response = (response as? RootListModel<PostList>){
                
                self.totalPosts = (response).totalPosts ?? 0
                let response1 = (response).list ?? []
                self.isSetAlert = response.alertByMe ?? false
                //                self.arrayItems = response1
            }
            
            //            self.totalPosts = (response as? RootListModel<CarListDataModel>)?.totalPosts ?? 0
            //            let response1 = (response as? RootListModel<CarListDataModel>)?.list ?? []
            //            self.isSetAlert = (response as? RootListModel<CarListDataModel>)?.alertByMe ?? false
            //            self.arrayItems = response1
            
        }) { (error) in
            
            
        }
        
    }
    
    
}
