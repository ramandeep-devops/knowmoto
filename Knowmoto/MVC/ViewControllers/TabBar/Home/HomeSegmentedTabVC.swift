//
//  HomeVC.swift
//  Knowmoto
//
//  Created by Apple on 30/07/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit
import CoreLocation

class HomeSegmentedTabVC: BaseVC {
    
    //MARK:- Outlets
    
    @IBOutlet weak var btnJoinKnowmoto: UIButton!
    
    @IBOutlet weak var lblLocationIcon: UIImageView!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var btnYouAreLive: UIButton!
    @IBOutlet weak var btnGoLive: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    //MARK:- Properties
    
    var segmentVC: SJSegmentedViewController?
    var beaconOwnerPostsVC = ENUM_STORYBOARD<PostsListVC>.post.instantiateVC()
    var basicUsersPostsVC = ENUM_STORYBOARD<PostsListVC>.post.instantiateVC()
    var headerVC = ENUM_STORYBOARD<HomeFeaturedCarsHeaderVC>.tabbar.instantiateVC()
    var isGuestUser:Bool{
        return UserDefaultsManager.isGuestUser
    }
    var headerHeight:CGFloat = 364.0
    
    let dispatchGroup = DispatchGroup()
    
    
    //MARK:- View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        
    }
    
    func initialSetup(){
        
        if isGuestUser{// UI for guest user switch

            lblCity.isHidden = true
            lblLocationIcon.isHidden = true
            btnCity.isHidden = true
            btnJoinKnowmoto.isHidden = false
            switchToGuestUserUI()

        }
        
//        else{
        
            self.perform(#selector(self.switchToRegisteredUserUI), with: nil, afterDelay: 0.2)
            
            instantiateLiveCarSetup()
//        }
        
        imageViewUser.addTapGesture(target: self, action: #selector(self.didTapUser(_:)))
        
       
        if let locationAddress = UserDefaultsManager.shared.location?.selectedLocation{
            
            self.btnCity.setTitle(locationAddress.name ?? "Select Location".localized, for: .normal)
            
            self.updateLocation(location: locationAddress)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        apiGetNotificationsUnreadCount()
        lastSelectedTab = .home // to check last opened tab
        
        setLoggedInUser()
        apiGetHomeFeaturedRecentCars()
        setGoLiveButtonEnable(enable: !UserDefaultsManager.shared.isLive)
        updateDeviceToken()
    }
    
    
    func updateDeviceToken(){
        
        if !UserDefaultsManager.isGuestUser{
            
            let fcmToken = UserDefaults.standard.value(forKey: "fcmToken") as? String
            
            EP_Profile.update_device_token(deviceToken: fcmToken).request(loaderNeeded: false, successMessage: nil, success: { (_) in
                
                
            }, error: nil)
            
        }
        
    }
    
    
    //MARK:- Funtions
    
    func switchToGuestUserUI(){ //guest user UI
        
        imageViewUser.isHidden = true
        
//        headerVC.willMove(toParent: self)
//
//        // Add to containerview
//        headerVC.view.frame = self.containerView.bounds
//        self.containerView.addSubview(headerVC.view)
//        self.addChild(headerVC)
//        headerVC.didMove(toParent: self)
        
    }
    
    @IBAction func didTapJoinKnowmoto(_ sender: UIButton) {
        
        handleGuestUser()
        
    }
    
    
    @objc func switchToRegisteredUserUI(){ //registerd user UI
        
        //getHeaderVCHeight
        func getHeaderVCCellHeight() ->CGFloat{
            
            let tableHeaderViewHeight:CGFloat = 93 //isGuestUser ? 0.0 : 93//headerView.bounds.height
            let sectionHeaderViewHeight:CGFloat = 56
            let bottomSpacing:CGFloat = 32.0
            let totalHeight:CGFloat = headerHeight - (tableHeaderViewHeight + sectionHeaderViewHeight + bottomSpacing)
            return totalHeight
        }
        
        headerVC.layoutDelegate = self
        headerVC.cellHeight = getHeaderVCCellHeight()
        //setting post type
        beaconOwnerPostsVC.postType = .beaconOwner
        basicUsersPostsVC.postType = .basicUser
        
        //setting delegate
        beaconOwnerPostsVC.delegate = self
        basicUsersPostsVC.delegate = self
        
        reinstantaiteSegmentsVCwithHeight(headerHeight: nil)
        
    }
    
    func reinstantaiteSegmentsVCwithHeight(headerHeight:CGFloat?){
        
        //removing all container view subviews
        containerView.subviews.forEach({$0.removeFromSuperview()})
        
        //setting header titles
        let titles = ["Owner Pictures".localized,"User Pictures".localized]
        
        //initialiazing segemntVC
        segmentVC = SJSegmentedViewController.init(headerViewController: headerVC, segmentControllers: [beaconOwnerPostsVC, basicUsersPostsVC])
        
        _ = SJSegmentDataSource.init(segmentVC: segmentVC, containerView: containerView, vc: self, titles: titles, segmentViewHeight: 48, selectedHeight: 2,headerHeight: headerHeight ?? self.headerHeight,fontSize: 14.0,tabChanged: { [unowned self] (index) in
            
            
            
            }, success: {
                
        })
        
        segmentVC?.segmentedScrollView.alwaysBounceVertical = true
        segmentVC?.segmentedScrollView.bounces = true
        
        //configuring pull to refresh
        addPullToRefresh()
        
        self.view.bringSubviewToFront(btnGoLive)
    }
    
    
    func setGoLiveButtonEnable(enable:Bool){
        
        //        btnGoLive.alpha = enable ? 1.0 : 0.5
        //        btnGoLive.isUserInteractionEnabled = enable
        btnYouAreLive.isHidden = enable || UserDefaultsManager.isGuestUser
        
        //hide go live for guest user
        
        btnGoLive.isHidden = UserDefaultsManager.isGuestUser
    }
    
    func reloadData(){
        
        self.apiGetHomeFeaturedRecentCars()
        beaconOwnerPostsVC.reloadPullToRefreshFromParent()
        basicUsersPostsVC.reloadPullToRefreshFromParent()
        dispatchGroup.enter()
        dispatchGroup.enter()
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            
            self?.stopPullToRefresh()
            
        }
        
    }
    
    func addPullToRefresh(){
        
        segmentVC?.segmentedScrollView.es.addPullToRefresh { [weak self] in
            
            self?.reloadData()
            
        }
    }
    
    func stopPullToRefresh(){
        
        self.segmentVC?.segmentedScrollView.es.stopPullToRefresh()
        
    }
    
    func instantiateLiveCarSetup(){
  
        if UserDefaultsManager.shared.liveCar?.liveCars == nil && !isGuestUser{
            
            self.apiGetMyVehicles { [weak self] (_) in
                
                DispatchQueue.main.async {
                    
                    self?.checkLiveCarStatus()
                    
                }
                
            }
            
        }else{
            
            checkLiveCarStatus()
            
        }
        
    }
    
    func checkLiveCarStatus(){
        
        //        if !liveCarTimers.isEmpty{
        //
        setGoLiveButtonEnable(enable: !UserDefaultsManager.shared.isLive)
        
        let liveCars = UserDefaultsManager.shared.liveCar?.liveCars
        
        if UserDefaultsManager.shared.isLive{ //if app close
            
            liveCars?.forEach({ (liveCarData) in
                
                let liveExpiryTimeStamp = liveCarData.liveExpiryTimeStamp
                
                if /liveExpiryTimeStamp?.toDate().isPast{ // live car time gone
                    
                    self.apiEndLiveCar(liveCar: liveCarData)
                    
                }else{ //live car time continue
                    
                    let currentMilliseconds = Date().millisecondsSince1970
                    let secondsLeftForEndLive = ((liveExpiryTimeStamp ?? 0.0) - currentMilliseconds)/1000
                    
                    Timer.scheduledTimer(withTimeInterval: secondsLeftForEndLive, repeats: false) { (_) in
                        
                        self.apiEndLiveCar(liveCar: liveCarData)
                        
                    }
                    
                    //                        liveCarTimers[/liveCarData.id] = liveTimer
                    
                }
                
            })
            
            
        }
        
        //        }
        
    }
    
    //MARK:- Button actions
    
    @IBAction func didTapGoLive(_ sender: UIButton) {
        
        self.apiGetMyVehicles { (response) in
            
            let _response = (response as? [CarListDataModel]) ?? []
            let arrayVehiclesWithBeacon = _response.filter({/$0.beaconID?.isEmpty == false})
            
            
            if _response.isEmpty{
                
                self.alertBox(message: "Vehicles are not found to go live, please add at least one vehicle from your profile.".localized, okButtonTitle: "Profile".localized, title: "Alert!".localized, ok: {
                    
                    let vc = ENUM_STORYBOARD<ProfileHomeSegementedVC>.profile.instantiateVC()
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                })
                
                
            }else if arrayVehiclesWithBeacon.isEmpty{
                
                
                self.alertBox(message: "Please attach a beacon with your vehicle first.".localized, okButtonTitle: "Manage Beacon".localized, title: "Alert!", ok: {
                    
                    self.didTapManageBeacons()
                    
                })
                
            }else{
                
                self.redirectToGoLive(vehicles: arrayVehiclesWithBeacon)
                
            }
            
        }
        
    }
    
    //my live view
    @IBAction func didTapMyLiveView(_ sender: UIButton) {
        
        let vc = ENUM_STORYBOARD<MBMapVC>.map.instantiateVC()
        vc.isFromMyLive = true
        vc.presentWithNavigationController()
//        self.present(vc, animated: true, completion: nil)
    }
    
    //open manage beacon
    func didTapManageBeacons() {
        
        let vc = ENUM_STORYBOARD<ManageBeaconVC>.profile.instantiateVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //redirect to go live
    func redirectToGoLive(vehicles:[CarListDataModel]){
        
        let vc = ENUM_STORYBOARD<GoLiveVC>.car.instantiateVC()
        vc.arrayCars = vehicles
        self.present(vc, animated: true, completion: nil)
        
    }
    
    //did tap user name and image
    @IBAction func didTapUser(_ sender: UIButton) {
        
        
        if UserDefaultsManager.isGuestUser{ //guest user
            
            handleGuestUser()
            
        }else{ //logged in user
            
            let vc = ENUM_STORYBOARD<ProfileHomeSegementedVC>.profile.instantiateVC()
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    @IBAction func didTapSelectLocation(_ sender: UIButton) {
        
        let placePickerVC = ENUM_STORYBOARD<PlacePickerVC>.miscelleneous.instantiateVC()
        //        placePickerVC.selectedAddress = /btnCity.titleLabel?.text
        placePickerVC.searchType = [.district,.place]
        placePickerVC.didGetLocation = { [weak self] (location) in
            
            self?.updateLocation(location: location)
            self?.btnCity.setTitle(/location.name, for: .normal)
        }
        
        self.present(placePickerVC, animated: true, completion: nil)
        
    }
    
    //update user location
    func updateLocation(location:LocationAddress){
        
        if UserDefaultsManager.isGuestUser{
            return
        }
        
        let locationData = LocationData()
        
        let loginSignupModel = LoginSignupViewModal()
        locationData.location = [/location.longitude,/location.latitude]
        locationData.place = location.name
        
        loginSignupModel.filter = JSONHelper<LocationData>().toJSONString(model: locationData)
        
        EP_Profile.updateProfile(model: loginSignupModel).request(loaderNeeded:false,success:{ [weak self] (response) in
            
            let userData = (response as? UserData)
            UserDefaultsManager.shared.loggedInUser = userData
     
        })
        
    }
    
    
    //api get vehicles
    func apiGetMyVehicles(completion:@escaping (Any?)->()){
        
        EP_Car.get_car_feeds(id: nil, userId: userData?.id, loggedInUserId: userData?.id).request(loaderNeeded: true, successMessage: nil, success: { [weak self] (response) in
            
            let _response = (response as? [CarListDataModel]) ?? []
            let arrayVehiclesWithBeacon = _response.filter({/$0.beaconID?.isEmpty == false})
            
            //setting live vehicles
            var liveVehicles = UserDefaultsManager.shared.liveCar
            if liveVehicles == nil{
                liveVehicles = LiveVehicleModal()
            }
            liveVehicles?.liveCars = _response.filter({$0.liveExpiryTimeStamp?.toDate().isPast == false})
            UserDefaultsManager.shared.liveCar = liveVehicles
            
            completion(_response)
            
            
        }) { (error) in
            
            debugPrint(error)
        }
    }
    
    
    
}

//MARK:- PostVC delegate
extension HomeSegmentedTabVC:PostListVCDelegate{
    
    func didReloadData() {
        
        //reloading from parentVC(thus) by dispatch group
        dispatchGroup.leave()
        
    }
    
}

//MARK:- Home api
extension HomeSegmentedTabVC:SegementedVCsDelegate{
    
    func didChangeHeaderVCHeight(height: CGFloat) {
        
        DispatchQueue.main.async { [weak self] in
            
            if self?.headerHeight != height{
                
                self?.headerHeight = height
                self?.reinstantaiteSegmentsVCwithHeight(headerHeight: height)
                
            }
            
            
        }
        
        
    }
    
    //getting home featured cars
    func apiGetHomeFeaturedRecentCars(){
        
        let selectedLocation = CLLocationCoordinate2D(latitude: UserDefaultsManager.shared.location?.selectedLocation?.latitude ?? 0.0, longitude: UserDefaultsManager.shared.location?.selectedLocation?.longitude ?? 0.0)
        
        let currentLocation = UserDefaultsManager.isGuestUser ?  LocationManager.shared.currentLocation?.coordinate : selectedLocation
        let jsonLocation = [currentLocation?.longitude ?? 72.856164,currentLocation?.latitude ?? 19.017615].toJsonString()
        
        //type:isGuestUser ? 5 : 2
        EP_Home.get_home_feed(type: 2, skip: 0, limit: 10, distance: nil, location: nil).request(loaderNeeded: isFirstTime, successMessage: nil, success: { [weak self] (response) in
            
            self?.isFirstTime = false
            
            self?.headerVC.reloadData(response: response)
            
            
        }) { (error) in
            
        }
        
    }
    
}
