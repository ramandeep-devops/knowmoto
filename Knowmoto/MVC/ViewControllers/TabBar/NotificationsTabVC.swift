//
//  NotificationsVC.swift
//  Knowmoto
//
//  Created by Apple on 30/07/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class NotificationsTabVC: BaseVC {
    
    //MARK:- OUTLET
    @IBOutlet weak var tableview: UITableView!
    
    //MARK:- PROPERTIES
    
    var customDataSource:TableViewDataSource?
    
    var arrayNotifications = [NotificationData](){
        didSet{
            
           arrayNotifications.isEmpty ? self.setTableViewBackgroundView(tableview: tableview,noDataFoundText: "No notifications found !") : (self.tableview.backgroundView = nil)
         
        }
    }
    var limit:Int = 20
    var skip:Int = 0
    
    //MARK:- LIFE CYCLE METHODS

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configureTableView()
        tableview.tableFooterView = UIView(frame: .zero) 

    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.addRedDotAtTabBarItemIndex(index: 3, remove: true)
        
        if UserDefaultsManager.isGuestUser{
            handleGuestUser()
        }else{
            
            apiGetNotifications()
            lastSelectedTab = .notification
        }
    }
    
 
    func configureTableHeaderFooterRefresh(){
        
        //pull to refresh is handled in parent segemented controller working with dispatch group
        
        //footer refresh
        
        self.tableview.es.addPullToRefresh { [weak self] in
            
            self?.skip = 0
            self?.apiGetNotifications()
            
        }
        
        self.tableview.es.addInfiniteScrolling { [weak self] in
            
            self?.skip += /self?.limit
            self?.apiGetNotifications()
            
        }
        
    }
    
    
    func configureTableView(){ // configuring tableview
        
        configureTableHeaderFooterRefresh()
        let identifier = String(describing: NotificationTableViewCell.self)
        
        customDataSource = TableViewDataSource(items: arrayNotifications, tableView: tableview, cellIdentifier: identifier, cellHeight: UITableView.automaticDimension, configureCellBlock: { (cell, item, indexPath) in
            
            if let cell =  cell as? NotificationTableViewCell{

                cell.modal = item as? NotificationData
                cell.btnAllowOnWall.tag = indexPath.row
                cell.btnAllowOnWall.addTarget(self, action: #selector(self.actionAllowPostOnMyWall(sender:)), for: .touchUpInside)
                
            }
            
        }, aRowSelectedListener: { [weak self] (indexPath, cell) in
            
            let notificationType = ENUM_NOTIFICATION_TYPE.init(rawValue: /self?.arrayNotifications[indexPath.row].type)
            
            switch notificationType ?? .liked{
                
            case .taggedCar:
                
                self?.redirectToPostDetail(indexPath: indexPath)
                
            default:
                
                self?.openCarDetail(vehicleId: /self?.arrayNotifications[indexPath.row].vehicleId?.id)
                break
                
            }
       
            
        })
        
        tableview.delegate = customDataSource
        tableview.dataSource = customDataSource
        
    }
    
    //review post
    @objc func actionAllowPostOnMyWall(sender:UIButton){
        
        self.redirectToPostDetail(indexPath: IndexPath.init(row: sender.tag, section: 0))
        
//        UtilityFunctions.showActionSheetWithStringButtons(backgroundColor: UIColor.white, title: "This post will be display on your feed".localized, buttons: ["Allow".localized]) { (str) in
//
//            EP_Notification.approve_tag_request(id:self.arrayNotifications[sender.tag].taggedId?.id, isApproved: 2).request(loaderNeeded: true, successMessage: nil, success: { (response) in
//
//                self.arrayNotifications[sender.tag].taggedId?.isApproved = 2
//                self.tableview.reloadRows(at: [IndexPath.init(item: sender.tag, section: 0)], with: .fade)
//
//            }, error: { (error) in
//
//            })
//
//        }
        
    }
    
    func redirectToPostDetail(indexPath:IndexPath){
        
        let notification = self.arrayNotifications[indexPath.row]
        
        let vc = ENUM_STORYBOARD<PostsListVC>.post.instantiateVC()
        vc.isFromAllowPostOnWall = true
        vc.isHideHeaderView = false
        vc.postId = notification.postId?.id
        vc.taggedId = notification.taggedId?.id
        vc.type = notification.type
        vc.isAllowPostStatus = /notification.taggedId?.isApproved
        vc.notificationData = notification
        
//        vc.notificationData = notification
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    

}
extension NotificationsTabVC{
    
    func apiGetNotifications(){
        
        EP_Notification.get_notifications(id: nil, limit: limit, skip: skip).request(loaderNeeded: false, successMessage: nil, success: { [weak self] (response) in
            
            let notificationList = (response as? [NotificationData]) ?? []
            
            if self?.skip == 0{
                
                self?.arrayNotifications = notificationList
                
                self?.customDataSource?.items = self?.arrayNotifications
                self?.tableview.reloadData()
                
            }else{
                
                self?.arrayNotifications += notificationList

                notificationList.forEach({ (notification) in
                    
                    self?.customDataSource?.items?.append(notification)
                    
                    self?.tableview.insertRows(at: [IndexPath.init(row: /self?.customDataSource?.items?.count - 1, section: 0)], with: .none)
                    
                })
          
            }
            
            self?.tableview.es.stopLoadingMore()
            self?.tableview.es.stopPullToRefresh()
        
        }) { [weak self] (error) in
            
            
            self?.tableview.es.stopLoadingMore()
            self?.tableview.es.stopPullToRefresh()
        }
        
    }
    
}

extension NotificationsTabVC:PostListVCDelegate{
    
    
    func didReloadData() {
    }
    
  
    
    func didAllowPostOnWall(postId: String?) {
        
        if let index = self.arrayNotifications.firstIndex(where: {/$0.postId?.id == postId}){
            
//            self.tableview.re
            
        }
        
    }
    
}
