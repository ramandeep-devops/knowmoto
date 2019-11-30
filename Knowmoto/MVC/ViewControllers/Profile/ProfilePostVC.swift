//
//  ProfilePostVC.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/9/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class ProfilePostVC: BaseVC {
    
    @IBOutlet weak var containerViewMyPostLabel: UIView!
    @IBOutlet weak var collectionViewPosts: UICollectionView!
    
    var isHideTitle:Bool = true
    var dataSourceCollections:CollectionViewDataSource?
    var arrayPosts = [PostList](){
        didSet{
            
            self.dataSourceCollections?.items = arrayPosts
            self.collectionViewPosts.reloadData()
            
            arrayPosts.isEmpty ? self.setCollectionViewBackgroundView(collectionView: collectionViewPosts, noDataFoundText: "No Posts found!".localized) : (collectionViewPosts.backgroundView = nil)
        }
    }
    var arrayGallery:[ImageUrlModel]?
    var carData:CarListDataModel?
    var searchData:SearchDataModel?
    var ouserData:UserData?
    
    var postType:ENUM_GET_POST_TYPE = .tagUserPosts
    
    var isLoadGallery:Bool = false
    var isFromMyProfile:Bool = false
    
    var limit:Int = 40
    var skip:Int = 0
    
    var titleAttributes:(UIColor,String) = (UIColor.white,"My Posts".localized) //(color,text)
    
    var delegate:MakeModelPostListsSegmentedVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initialSetup()
        
    }
    
    func initialSetup(){
        
        isLoadGallery = !isFromMyProfile && postType == .postAccordingToTheCar
        
        containerViewMyPostLabel.isHidden = isHideTitle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            
            if /self?.isLoadGallery{
                
                self?.arrayGallery = self?.carData?.image
                
            }else{
                
                self?.apiGetPosts(ofUserId: self?.ouserData?.id)
                
            }
            self?.configureCollectionView()
            
        }
        
         NotificationCenter.default.addObserver(self, selector: #selector(self.reloadPostsData), name: .DELETE_POST, object: nil)
        
        setTitle(text: titleAttributes.1, color: titleAttributes.0)
        
    }
    
    func setTitle(text:String,color:UIColor = UIColor.white){
        
        lblTitle.text = text
        lblTitle.textColor = color
        
        containerViewMyPostLabel.isHidden = isHideTitle
    }
    
    @objc func reloadPostsData(){
        
        self.skip = 0
        self.apiGetPosts(ofUserId: self.ouserData?.id)
    }
    
    @objc func actionRemoveTaggedPost(sender:UIButton){
        
        self.alertBox(message: "Do you really want to remove tagged post from your wall?", okButtonTitle: "Remove", title: "Remove?") { [unowned self] in
            
            self.apiRemoveTaggedPost(postData: self.arrayPosts[sender.tag])

            
        }
        
    }
    
    func configureCollectionView(){ //Configuring collection View cell
    
        collectionViewPosts.contentInset = UIEdgeInsets(top: isHideTitle ? 16 : 0.0, left: 0, bottom: 48, right: 0)
        
        let cellSpacing:CGFloat = 16
        let cellWidth:CGFloat = (UIScreen.main.bounds.width - ((cellSpacing * 4)))/3 - 2
        let cellHeight:CGFloat = cellWidth
        
        
        let identifier = String(describing: PostCarsCollectionViewCell.self)
        collectionViewPosts.registerNibCollectionCell(nibName: identifier)
        
        
        dataSourceCollections = CollectionViewDataSource(items: isLoadGallery ? arrayGallery : arrayPosts, collectionView: collectionViewPosts, cellIdentifier: identifier, headerIdentifier: nil, cellHeight: cellHeight, cellWidth: cellWidth, configureCellBlock: { [unowned self] (_cell, item, indexPath) in
            
            let cell = _cell as? PostCarsCollectionViewCell
            
            cell?.layer.cornerRadius = 4
            cell?.clipsToBounds = true
            cell?.imageViewCar.layer.cornerRadius = 8
            cell?.imageViewCar.clipsToBounds = true
            cell?.btnRemove.tag = indexPath.item
            cell?.btnRemove.isHidden = self.postType != .tagUserPosts
            
            if let image = (item as? PostList)?.image?.first?.thumb{
                
                let cacheKey = /(item as? PostList)?.image?.first?.originalImageKey
                cell?.imageViewCar.loadImage(key: image, isLoadWithSignedUrl: false, cacheKey: cacheKey)
                
                cell?.btnRemove.addTarget(self, action: #selector(self.actionRemoveTaggedPost(sender:)), for: .touchUpInside)
                
            }else if let image = (item as? ImageUrlModel){
                
                let cacheKey = image.thumbImageKey
                cell?.imageViewCar.loadImage(key: /image.thumb, isLoadWithSignedUrl: false, cacheKey: cacheKey)
            }
            
        }, aRowSelectedListener: { [unowned self] (indexPath, item) in
            
            if !self.isLoadGallery{ // posts
                
                let allPostListVC = ENUM_STORYBOARD<PostsListVC>.post.instantiateVC()
                
                allPostListVC.userId = /self.isFromMyProfile ? self.userData?.id : nil
                allPostListVC.vehicleId = self.carData?.id
                allPostListVC.postType = self.postType
                allPostListVC.isHideHeaderView = false
                allPostListVC.skip = self.skip
                allPostListVC.limit = self.limit
                allPostListVC.arrayPosts = self.arrayPosts
                allPostListVC.selectedPostIndex = indexPath.item
                allPostListVC.makeId = self.searchData?.type == 1 ? self.searchData?.id : nil //this search id have make id
                
                self.navigationController?.pushViewController(allPostListVC, animated: true)
                
            }else{ //gallery
                
                self.showImagePreview(intial: indexPath.item)
                
            }
            
            }, willDisplayCell: nil, scrollViewDelegate: nil)
        
        collectionViewPosts.dataSource = dataSourceCollections
        collectionViewPosts.delegate = dataSourceCollections
        collectionViewPosts.reloadData()
        
    }
    
    
    func showImagePreview(intial:Int){
        
        var arr = [INSPhoto]()
        
        for image in self.carData?.image ?? []{
         
            arr.append(INSPhoto.init(imageURL: URL.init(string: /image.original), thumbnailImageURL: URL.init(string: /image.original), cacheKey: /image.originalImageKey))

        }
        
        let galleryPreview = INSPhotosViewController(photos: arr, initialPhoto: arr[intial], referenceView: topMostVC?.view)
        
        topMostVC?.present(galleryPreview, animated: true, completion: nil)
        
    }
    
}

//MARK:- API
extension ProfilePostVC{
    
    func apiRemoveTaggedPost(postData:PostList){
        
        EP_Notification.approve_tag_request(id: /postData.taggedId, isApproved: 0).request(loaderNeeded: true, successMessage: nil, success: { [unowned self] (response) in
            
            self.apiGetPosts(ofUserId: self.ouserData?.id)
            
        }, error: { (error) in
            
        })
        
    }
    
    func apiGetPosts(ofUserId:String? = nil, completion:(()->())? = nil){
        
        let userId = postType == .tagUserPosts ? nil : UserDefaultsManager.shared.loggedInUser?.id
        let currentUserId = UserDefaultsManager.shared.currentUserId
       
        var endPoint:EP_Post?
            
        if searchData != nil && searchData?.type != 1{
            
            //get post of modal
            endPoint = EP_Post.get_main_search_data(search: nil, id: searchData?.id, type: searchData?.type, limit: limit, skip: skip, loggedInUserId: userData?.id)
            
        }else {
            
            //get post according to defined types in postType
            endPoint = EP_Post.get_post_data(id:nil, type:postType.rawValue, userId:isFromMyProfile ? userId : ofUserId, search:nil, limit:limit, skip:skip, vehicleId: carData?.id, loggedInUserId: currentUserId, makeId: searchData?.id)
            
        }
        
        endPoint?.request(loaderNeeded: false, successMessage: nil, success: { [weak self] (response) in
            
            let list = self?.searchData == nil || self?.searchData?.type == 1 ? ((response as? [PostList]) ?? []) : ((response as? RootListModel)?.list ?? [])
            

            if self?.skip == 0{ //paging from page 1
                
                self?.arrayPosts = list
                
            }else{ //paging
                
                self?.arrayPosts += list
                
                for post in list{
                    
                    self?.dataSourceCollections?.items?.append(post)
                    
                    self?.collectionViewPosts.insertItems(at: [IndexPath.init(row: /self?.dataSourceCollections?.items?.count - 1, section: 0)])
                    
                }
         
            }
            
            completion?()
            
            //stop all loaders
            self?.stopLoaders()
            
        }) { [weak self] (error) in
            
            completion?()
            
            //stop all loaders
            self?.stopLoaders()
            
        }
        
    }
    
    func stopLoaders(){
        
        self.collectionViewPosts.es.stopLoadingMore()
        self.collectionViewPosts.es.stopPullToRefresh()
        
    }
    
}

//observe offset change according to collection view
extension ProfilePostVC:SJSegmentedViewControllerViewSource{
    
    func viewForSegmentControllerToObserveContentOffsetChange() -> UIView {
        return collectionViewPosts
    }
    
}
