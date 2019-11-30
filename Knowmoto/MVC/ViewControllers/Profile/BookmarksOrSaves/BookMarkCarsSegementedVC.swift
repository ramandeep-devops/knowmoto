//
//  BookMarkCarsVC.swift
//  Knowmoto
//
//  Created by Apple on 30/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

enum ENUM_BOOKMARKED_VC_TYPE:Int{
    
    case followed = 2
    case myCars = 4
    case alert = 6
    case liked = 1
    case nearby = 3
    
}



class BookMarkCarsSegementedVC: BaseVC {
    
    @IBOutlet weak var containerView: UIView!
    
    //MARK:- Properties
    
    var followedVC = ENUM_STORYBOARD<BookMarkCarsListVC>.profile.instantiateVC()
    var likedVC = ENUM_STORYBOARD<BookMarkCarsListVC>.profile.instantiateVC()
    var alertTagVC = ENUM_STORYBOARD<BookMarkCarsListVC>.profile.instantiateVC()
    
    lazy var myCarsVC = ENUM_STORYBOARD<BookMarkCarsListVC>.profile.instantiateVC()
    lazy var nearByCarsVC = ENUM_STORYBOARD<BookMarkCarsListVC>.profile.instantiateVC()
    
    var dataSource:SJSegmentDataSource?
    var segmentVC: SJSegmentedViewController?
    
    weak var delegate:BookMarkCarsListVCDelegate?
    var selectedCar:CarListDataModel?
    
    var isFromCreatePost:Bool = false
    var ouserData:UserData?
    private var isFromOtherUserProfile:Bool{
        return ouserData != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        
    }
    
    
    func initialSetup(){
        
        setupSegemntedController()
        setupUI()
    }
    
    func setupUI(){
        
        headerView.headerView.lblTitle?.text = ouserData?.userName ?? "Saves"
    }
    
    
    
    func setupSegemntedController(){ //registerd user UI
        
        containerView.subviews.forEach({$0.removeFromSuperview()})
        
        let titles = isFromOtherUserProfile ?
            ["Liked vehicles".localized,"Followed vehicles".localized] : isFromCreatePost ?
            ["Nearby".localized,"My vehicles".localized,"Liked".localized,"Followed".localized] :
            ["Followed vehicles".localized,"Liked vehicles".localized,"Alert tags".localized]
        
        let arrayController = isFromOtherUserProfile ? [likedVC,followedVC] : isFromCreatePost ? [nearByCarsVC,myCarsVC,likedVC,followedVC] : [followedVC,likedVC,alertTagVC]
        
        followedVC.vcType = ENUM_BOOKMARKED_VC_TYPE.followed
        likedVC.vcType = ENUM_BOOKMARKED_VC_TYPE.liked
        alertTagVC.vcType = ENUM_BOOKMARKED_VC_TYPE.alert
        nearByCarsVC.vcType = ENUM_BOOKMARKED_VC_TYPE.nearby
        myCarsVC.vcType = ENUM_BOOKMARKED_VC_TYPE.myCars
        
        arrayController.forEach { (vc) in
            vc.delegate = self.delegate
            vc.selectedCar = self.selectedCar
            vc.isFromCreatePost = self.isFromCreatePost
            vc.ouserData = ouserData
        }
        
        segmentVC = SJSegmentedViewController.init(headerViewController: nil, segmentControllers:arrayController)
        
        dataSource = SJSegmentDataSource.init(selectedTitleColor:UIColor.white,segmentBackgroundColor:UIColor.backGroundHeaderColor!,segmentVC: segmentVC, containerView: containerView, vc: self, titles: titles, segmentViewHeight: 48.0, selectedHeight:0.0,headerHeight: 0.0,fontSize: 13.0,tabChanged: { [unowned self] (index) in
            
            
            
            }, success: {
                
        })
        
    }
    
}
