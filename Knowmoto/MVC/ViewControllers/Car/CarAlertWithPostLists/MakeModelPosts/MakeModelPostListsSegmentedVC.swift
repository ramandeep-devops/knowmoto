//
//  MakeModelPostListsSegmentedVC.swift
//  Knowmoto
//
//  Created by Apple on 20/09/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

protocol MakeModelPostListsSegmentedVCDelegate:class {
    func didUpdatePosts(totalDocs:Int)
    func didSetAlert(ofStateSelected:Bool)
}

class MakeModelPostListsSegmentedVC: BaseVC {
    
    //MARK:- Outlets
    @IBOutlet weak var heightConstraintViewNotification: NSLayoutConstraint!
    @IBOutlet weak var viewNotification: UIView!
    @IBOutlet weak var containerView: UIView!
    
    //MARK:- Properties
    
    var postVC = ENUM_STORYBOARD<ProfilePostVC>.profile.instantiateVC()
    var userProfileHeaderVC = ENUM_STORYBOARD<OtherUserProfileDetailVC>.car.instantiateVC()
    var headerVC = ENUM_STORYBOARD<MakeModelHeaderListVC>.car.instantiateVC()
    var dataSource:SJSegmentDataSource?
    var segmentVC: SJSegmentedViewController?
    
    private var searchType:ENUM_MAIN_SEARCH_TYPE = .make
    var searchData:SearchDataModel?
    var ouserData:UserData?
    private var isFromUserProfile:Bool{
        return ouserData != nil
    }
    
    
    //MARK:- View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        intialSetup()
        
    }
    
    func setUpUI(){
        
        headerView.headerView.lblTitle?.text = /searchData?.tagName
        
    }
    
    func intialSetup(){
        
        setUpUI()
        setupAddedCarController()
    }
    
    func setupAddedCarController(newHeaderHeight:CGFloat? = nil){ //registerd user UI
        
        containerView.subviews.forEach({$0.removeFromSuperview()})
        
        segmentVC = SJSegmentedViewController.init(headerViewController:isFromUserProfile ? userProfileHeaderVC : headerVC, segmentControllers:[postVC])
        
        if isFromUserProfile{
            
            userProfileHeaderVC.ouserData = ouserData
            userProfileHeaderVC.didGetNewHeaderHeight = { [weak self] (newHeight) in
                self?.setupAddedCarController(newHeaderHeight: newHeight)
            }
            
            postVC.postType = .all
            postVC.ouserData = ouserData
            postVC.delegate = self
            postVC.isHideTitle = false
            postVC.titleAttributes = (UIColor.SubtitleLightGrayColor!,"Posts")
            
        }else{
            
            headerVC.searchData = searchData
            headerVC.delegate = self
            
            postVC.postType = searchData?.type == 1 ? .makePost : .basicUser
            postVC.searchData = searchData
            postVC.delegate = self
            postVC.isHideTitle = false
            postVC.titleAttributes = (UIColor.SubtitleLightGrayColor!,"Posts")
            
        }
        
        self.searchType = ENUM_MAIN_SEARCH_TYPE.init(rawValue: /searchData?.type) ?? .make
        
        let headerHeight:CGFloat = isFromUserProfile ? 416 : searchType == .make ? 272 : 128.0
        
        dataSource = SJSegmentDataSource.init(segmentVC: segmentVC, containerView: containerView, vc: self, titles: [], segmentViewHeight: 0.0, selectedHeight:0.0,headerHeight:newHeaderHeight ?? headerHeight,tabChanged: { [unowned self] (index) in
            
            
            
            }, success: {
                
        })
        
        
        
    }
    
    @IBAction func didTapRemoveAlert(_ sender: UIButton) {
        
        headerVC.apiSetAlert()
        
    }
}


extension MakeModelPostListsSegmentedVC:MakeModelPostListsSegmentedVCDelegate{
    
    func didUpdatePosts(totalDocs: Int) { // getting total docs of posts
        
//        headerVC.totalPosts = totalDocs
        
    }
    
    func didSetAlert(ofStateSelected:Bool) { //setting notification alert for car live
        
//        UIView.animate(withDuration: 0.2) { [weak self] in
//
//            DispatchQueue.main.async {
//
//                self?.heightConstraintViewNotification.constant = ofStateSelected ? 59 : 0.0
//                self?.viewNotification.isHidden = !ofStateSelected
//
//            }
//
//        }
    
    }
}
