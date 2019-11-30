//
//  CarDetailSegmentedVC.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/21/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit



protocol SegementedVCsDelegate {
    func didChangeHeaderVCHeight(height:CGFloat)
}

class CarDetailSegmentedVC: BaseVC {
    
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var containerViewBtnGoLive: UIView!
    @IBOutlet weak var containerView: UIView!
    
    //MARK:- Properties
    var postVC = ENUM_STORYBOARD<ProfilePostVC>.profile.instantiateVC()
    lazy var tagPostVC = ENUM_STORYBOARD<ProfilePostVC>.profile.instantiateVC()
    lazy var detailVC = ENUM_STORYBOARD<SummaryAddCarVC>.car.instantiateVC()
    
    var headerVC = ENUM_STORYBOARD<CarDetailHeaderVC>.car.instantiateVC()
    
    var dataSource:SJSegmentDataSource?
    var segmentVC: SJSegmentedViewController?
    
    var carData:CarListDataModel?
    var vcType:ENUM_CAR_DETAIL_SCREEN_TYPE? = .myCar
    
    var isFromMyProfile:Bool = false
    var isReloadControllers:Bool = false
    var isFromCarDetail:Bool = false
    var vehicleId:String?
    var moreOptions:[String] = []
    var headerHeight:CGFloat? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if isReloadControllers{
            
            isReloadControllers = false
            
            DispatchQueue.main.async { [weak self] in
                
                self?.setupAddedCarController()
                
            }
            
        }
        
    }
    
    func initialSetup(){
        
        apiGetCarData()
        
        setupUI()
        configureActionBlockRightEditButton()
    }
    
    func setupUI(){
        
        let isMyCar = userData?.id == carData?.userID?.id
        let isILiveNow = UserDefaultsManager.shared.isLive
        let isBeaconAdded = !(/carData?.beaconID?.isEmpty)
        
        containerViewBtnGoLive.isHidden = !(isMyCar && isBeaconAdded && !isILiveNow)
        
        moreOptions = isMyCar ? [ENUM_POST_MORE_OPTIONS.edit.rawValue,ENUM_POST_MORE_OPTIONS.delete.rawValue,ENUM_POST_MORE_OPTIONS.share.rawValue] : [ENUM_POST_MORE_OPTIONS.share.rawValue]
        
//        headerView?.headerView.btnRight?.isHidden = /carData?.userID?.id != /userData?.id
//        headerView?.headerView.btnRight?.setImage(#imageLiteral(resourceName: "ic_pencil"), for: .normal)
//
//        headerView.headerView.btnRight2?.isHidden = /carData?.userID?.id != /userData?.id
    }
    
    func setupAddedCarController(headerHeight:CGFloat? = nil){ //registerd user UI
        
        containerView.subviews.forEach({$0.removeFromSuperview()})
        
        let titles = isFromCarDetail ? ["GALLERY".localized,"WALL".localized,"DETAILS".localized] : ["POSTS".localized,"TAGGED".localized,"DETAILS".localized]
        
        segmentVC = SJSegmentedViewController.init(headerViewController: headerVC, segmentControllers:[postVC,tagPostVC,detailVC])
        
        detailVC.carData = self.carData
        detailVC.isFromCarDetail = isFromCarDetail
        detailVC.isFromMyProfile = isFromMyProfile
        
        headerVC.isFromMyProfile = self.isFromMyProfile
        headerVC.carData = self.carData
        headerVC.delegate = self
        
        postVC.postType = .postAccordingToTheCar
        postVC.isFromMyProfile = isFromMyProfile
        postVC.carData = self.carData
        
        tagPostVC.postType = .all
        tagPostVC.isFromMyProfile = isFromMyProfile
        tagPostVC.carData = self.carData
        
        dataSource = SJSegmentDataSource.init(segmentVC: segmentVC, containerView: containerView, vc: self, titles: titles, segmentViewHeight: 48.0, selectedHeight:2.0,headerHeight: headerHeight ?? self.headerHeight ?? /vcType?.headerHeight,fontSize: 11.0,tabChanged: { [unowned self] (index) in
            
            
            }, success: {
                
        })
        
        self.view.bringSubviewToFront(self.containerViewBtnGoLive)
        
    }
    
    //action right edit button
    func configureActionBlockRightEditButton(){
        
        headerView.headerView.didTapRightButton = { [weak self] (sender) in
            
            self?.moreAction()
            
//            if /UserDefaultsManager.shared.liveCar?.liveCars?.contains(where: {$0.id == /self?.carData?.id}){
//
//                self?.alertBoxOk(message: "Sorry you cannot edit car detail, currently you are live with this car".localized, title: "Alert!".localized, ok: {})
//                return
//            }
//
//            self?.redirectToAddCarFlow()
            
        }
        
//        headerView.headerView.didTapRightButton2 = { [weak self] (sender) in
//
//
//            self?.alertBox(message: "Do you really want to remove?".localized, title: "Remove vehicle".localized) {
//
//                EP_Profile.delete(id: /self?.carData?.id, type: 4).request(success: { (response) in
//
//                    NotificationCenter.default.post(name: .PROFILE_UPDATE, object: nil)
//                    self?.navigationController?.popViewController(animated: true)
//
//                })
//
//            }
//
//        }
    }
    
    func moreAction(){
        UtilityFunctions.showActionSheetWithStringButtons(backgroundColor:UIColor.white,buttons: moreOptions) { [weak self] (string) in
            
            let selectionType = ENUM_POST_MORE_OPTIONS.init(rawValue: string) ?? .report
            
            switch selectionType{
                
            case .delete:
                
               self?.deleteCar()
                
            case .edit:
                
                self?.editCar()
                
                break
                
            case .share:
                
                "\(APIBasePath.firebaseDynamicBasePath)/\(/ENUM_DYNAMIC_LINK_TYPE.vehicleId.rawValue)/\(/self?.carData?.id)".share(from: self!, title: /self?.carData?.displayAppName, desc: /self?.carData?.make?.first?.name, imgurl: URL.init(string: AWSConstants.baseUrl + /self?.carData?.image?.first?.thumb), image: nil)
                
                break
                
            default:
                break
            }
            
        }
        
    }
    
    func editCar(){
        
        if /UserDefaultsManager.shared.liveCar?.liveCars?.contains(where: {$0.id == /self.carData?.id}){
            
            self.alertBoxOk(message: "Sorry you cannot edit vehicle detail, currently you are live with this car".localized, title: "Alert!".localized, ok: {})
            return
        }
        
        self.redirectToAddCarFlow()
    }
    
    func deleteCar(){
        
        self.alertBox(message: "Do you really want to remove?".localized, title: "Remove vehicle".localized) {
            
            EP_Profile.delete(id: /self.carData?.id, type: 4).request(success: { (response) in
                
                NotificationCenter.default.post(name: .PROFILE_UPDATE, object: nil)
                self.navigationController?.popViewController(animated: true)
                
            })
            
        }
        
    }
    
    
    func redirectToAddCarFlow(){
        
        let vc = ENUM_STORYBOARD<SummaryAddCarVC>.car.instantiateVC()
        vc.carData = self.carData
        vc.delegate = self
        vc.isFromEditCar = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func didTapGoLive(_ sender: UIButton) {
        
        let vc = ENUM_STORYBOARD<GoLiveOverlayVC>.car.instantiateVC()
        vc.selectedCar = self.carData
        self.present(vc, animated: true, completion: nil)
        
    }
    
}

//MARK:- API
extension CarDetailSegmentedVC{
    
    func apiGetCarData(){
        
        EP_Car.get_car_feeds(id:vehicleId ?? carData?.id, userId: nil, loggedInUserId: userData?.id).request(loaderNeeded: true, successMessage: nil, success: { [weak self] (response) in
            
            let _response = (response as? [CarListDataModel]) ?? []
            self?.carData = _response.first
            
            if let carD = self?.carData{
                
                self?.vcType = self?.vcType?.getTypeOfScreen(carData: carD, isFromProfile: /self?.isFromMyProfile)
            }
            
            DispatchQueue.main.async { [weak self] in
                
                self?.setupUI()
                self?.setupAddedCarController()
                
            }
            
            
        }) { (error) in
            
            debugPrint(error)
        }
        
    }
    
}

//MARK:REload data delegat
extension CarDetailSegmentedVC:BaseAddCarDelegate,SegementedVCsDelegate{
    
    func didChangeHeaderVCHeight(height: CGFloat) {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.headerHeight = height
            self?.setupAddedCarController(headerHeight: height)
            
        }

    }
    
    func reloadCarDetail(data: Any?) {
        
        if let carData = data as? CarListDataModel{
            
            self.carData = carData
            
            if let carD = self.carData{
                
                self.vcType = self.vcType?.getTypeOfScreen(carData: carD, isFromProfile: /self.isFromMyProfile)
            }
            
            isReloadControllers = true
            
            headerVC.carData = self.carData
            
            headerVC.setupUI()
            
            detailVC.carData = self.carData
            
            detailVC.setDataAndReload()
            
        }
        
    }
    
}
