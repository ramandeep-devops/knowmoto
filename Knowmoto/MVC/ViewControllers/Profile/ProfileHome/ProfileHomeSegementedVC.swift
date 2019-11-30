//
//  ProfileHomeSegementedVC.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/9/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit
import Crashlytics

class ProfileHomeSegementedVC: BaseVC {
    
    //MARK:- Outlets
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageViewProfile: KnowmotoUIImageView!
    
    //MARK:- Properties
    var dataSource:SJSegmentDataSource?
    var segmentVC: SJSegmentedViewController?
    
    //controllers
    lazy var postVC = ENUM_STORYBOARD<ProfilePostVC>.profile.instantiateVC()
    lazy var tagPostVC = ENUM_STORYBOARD<ProfilePostVC>.profile.instantiateVC()
    
    //header controller (mange car view,manage interest,manage beacon,add car are all included in header controller)
    lazy var headerVC = ENUM_STORYBOARD<ProfileHeaderVC>.profile.instantiateVC()
    
    var centerPointOfHeaderVC = CGPoint.zero
    
    var userType:ENUM_APP_USERS = ENUM_APP_USERS(rawValue: /UserDefaultsManager.shared.loggedInUser?.role) ?? .basicUser
    
    var isControllerLoaded:Bool = true
    var arrayMyCars:[CarListDataModel] = []{
        didSet{
            
            setUserType()
            
            DispatchQueue.main.async { [weak self] in
                
                self?.checkReinstantiateController()
                
            }
            
        }
    }
    
    
    deinit {
        
        debugPrint("deinit")
        NotificationCenter.default.removeObserver(self, name: .PROFILE_UPDATE, object: nil)
        
    }
    
    //MARK:- View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
           self.initialSetup()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        setUserData()
        
        
    }
    
    func initialSetup(){
        
        configureBookMarkActionBlock()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.apiGetCars), name: .PROFILE_UPDATE, object: nil)
        
        self.apiGetCars()
        
    }
    
    
    func setUserData(){
        
        let userData = UserDefaultsManager.shared.loggedInUser
        
        lblUserName.text = /userData?.name
        imageViewProfile.loadImage(nameInitial: nil, key: /userData?.image?.thumb, isLoadWithSignedUrl: true, cacheKey: /userData?.image?.thumb, placeholder: #imageLiteral(resourceName: "userplaceholder_small"))
    }
    
    
    func setUserType(){
        
        userType = .beaconOwnerOrCarsAdded //userData?.role == 2 || !arrayMyCars.isEmpty ? .beaconOwnerOrCarsAdded : .basicUser //**** client want same view for both basic user and beacon owner
    }
    
    func setupAddedCarController(){ //registerd user UI
        
        
        containerView.subviews.forEach({$0.removeFromSuperview()})
        
        let titles = ["MY POSTS".localized,"TAGGED POSTS".localized]
        
        //set header vc data
        headerVC.userType = self.userType
        headerVC.arrayMyCars = self.arrayMyCars
        
        //set post vc data
        postVC.isHideTitle = userType == .beaconOwnerOrCarsAdded
        postVC.containerViewMyPostLabel?.isHidden = userType == .beaconOwnerOrCarsAdded
        postVC.postType = .all
        postVC.isFromMyProfile = true
        
        //tag user post
        tagPostVC.postType = .tagUserPosts
        tagPostVC.isFromMyProfile = true
        
        
        segmentVC = SJSegmentedViewController.init(headerViewController: headerVC, segmentControllers: userType == .basicUser ? [postVC] : [postVC,tagPostVC])
        
        segmentVC?.segmentedScrollView.delegate = self
        
        dataSource = SJSegmentDataSource.init(segmentVC: segmentVC, containerView: containerView, vc: self, titles: titles, segmentViewHeight: userType.segmentViewHeight, selectedHeight:userType.selectedSegmentHeight,headerHeight: userType.headerHeight,fontSize: 11.0,tabChanged: { [unowned self] (index) in
            
            
            }, success: {
                
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            self.centerPointOfHeaderVC = self.headerVC.view.center
            
        }
    }
    
    //MARK:- Actions
    
    @IBAction func didTapViewProfile(_ sender: UIButton) {
        
        let vc = ENUM_STORYBOARD<ProfileDetailVC>.profile.instantiateVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func configureBookMarkActionBlock(){
        
        headerView.headerView.btnRight?.setImage(#imageLiteral(resourceName: "ic_bookmarks"), for: .normal)
        
        headerView.headerView.didTapRightButton = { [weak self] (sender) in
            
            let vc = ENUM_STORYBOARD<BookMarkCarsSegementedVC>.profile.instantiateVC()
            vc.presentWithNavigationController()
            
        }
        
    }
    
}
extension ProfileHomeSegementedVC:UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        debugPrint(scrollView)
        
        headerVC.view?.center.y = (centerPointOfHeaderVC.y) + (scrollView.contentOffset.y)
        
        
        let scale = 1.0 - scrollView.contentOffset.y/5000
        let alpha = 1.0 - scrollView.contentOffset.y/376
        
        headerVC.view?.transform = CGAffineTransform(scaleX: scale, y: scale)
        headerVC.view?.alpha = alpha
        
    }
}

//MARK;- API
extension ProfileHomeSegementedVC{
    
    @objc func apiGetCars(){
    
        
        EP_Car.get_car_feeds(id: nil, userId: userData?.id, loggedInUserId: userData?.id).request(loaderNeeded: true, successMessage: nil, success: { [weak self] (response) in
            
            let _response = (response as? [CarListDataModel]) ?? []
            self?.arrayMyCars = _response
            
        }) { (error) in
            
            debugPrint(error)
        }
        
    }
    
    func checkReinstantiateController(){
        
        if (segmentVC?.segmentControllers.count == 2 && self.arrayMyCars.isEmpty) || (segmentVC?.segmentControllers.count == 1 && !self.arrayMyCars.isEmpty) || isControllerLoaded{ //check for change in data
            isControllerLoaded = false
            
            self.setupAddedCarController()
            
        }
        
        //reloading cars data in header view
        headerVC.arrayMyCars = self.arrayMyCars
        headerVC.dataSourceCollections?.items = self.arrayMyCars
        headerVC.collectionViewAddCar?.reloadData()
        
    }
    
    
}
