//
//  ExtensionNSObjectCommonAppFunctions.swift
//  Knowmoto
//
//  Created by Apple on 19/10/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation

extension NSObject{
    
    func openCarDetail(vehicleId:String){
        
        let vc = ENUM_STORYBOARD<CarDetailSegmentedVC>.car.instantiateVC()
        vc.vehicleId = vehicleId
        vc.isFromCarDetail = true
        
        topMostVC?.navigationController == nil ? vc.presentWithNavigationController() : topMostVC?.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    func openPostDetail(postId:String){
        
        let vc = ENUM_STORYBOARD<PostsListVC>.post.instantiateVC()
        vc.isHideHeaderView = false
        vc.postId = postId
       
        topMostVC?.navigationController == nil ? vc.presentWithNavigationController() : topMostVC?.navigationController?.pushViewController(vc, animated: true)
    }
    
  
    //redirect to make modal list
    func openMakeModelListVC(item:SearchDataModel){
        
        let vc = ENUM_STORYBOARD<MakeModelPostListsSegmentedVC>.car.instantiateVC()
        vc.searchData = item
        
        topMostVC?.navigationController == nil ? vc.presentWithNavigationController() : topMostVC?.navigationController?.pushViewController(vc, animated: true)
    }
    
    //redirect to make modal list
    func redirectToOUserProfielDetailVC(item:UserData?){
        
        if item?.id == /UserDefaultsManager.shared.currentUserId {
            
            let vc = ENUM_STORYBOARD<ProfileHomeSegementedVC>.profile.instantiateVC()
            topMostVC?.navigationController?.pushViewController(vc, animated: true)
            
        }else{
            
            
            let vc = ENUM_STORYBOARD<MakeModelPostListsSegmentedVC>.car.instantiateVC()
            vc.ouserData = item
            
            
            
            topMostVC?.navigationController == nil ? vc.presentWithNavigationController() : topMostVC?.navigationController?.pushViewController(vc, animated: true)
            
        }
            
    }
    
    
    func setNotificationBadge(isRead:Bool){
        
        if let tabItems = topMostVC?.tabBarController?.tabBar.items {
            // In this case we want to modify the badge number of the third tab:
            let tabItem = tabItems[3]
            tabItem.badgeValue = isRead ? nil : ""
        }
        
    }
    
    func addRedDotAtTabBarItemIndex(index: Int,remove:Bool = false) {
        
        if let vc = self.getParticularVC(className: TabBarVC.self) as? TabBarVC {
            
            
            for subview in vc.tabBar.subviews {
                
                if let subview = subview as? UIView {
                    
                    if subview.tag == 1234 {
                        subview.removeFromSuperview()
                        break
                    }
                }
            }
            
            if remove{
                
                UIApplication.shared.applicationIconBadgeNumber = 0
                return
            }
            
            let RedDotRadius: CGFloat = 5
            let RedDotDiameter = RedDotRadius * 2
            
            let TopMargin:CGFloat = 12
            
            let TabBarItemCount = CGFloat(vc.tabBar.items!.count)
            
            let screenSize = UIScreen.main.bounds
            let HalfItemWidth = (screenSize.width) / (TabBarItemCount * 2)
            
            let  xOffset = HalfItemWidth * CGFloat(index * 2 + 1)
            
            let imageHalfWidth: CGFloat = (vc.tabBar.items![index]).selectedImage!.size.width / 2
            
            let redDot = UIView(frame: CGRect(x: xOffset + imageHalfWidth - 7, y: TopMargin, width: RedDotDiameter, height: RedDotDiameter))
            
            redDot.tag = 1234
            redDot.backgroundColor = UIColor.red
            redDot.layer.cornerRadius = RedDotRadius
            
            vc.tabBar.addSubview(redDot)
            
        }
        
        
        
    }
    
    func getParticularVC<T: UIViewController>(className : T.Type) -> UIViewController? {
        
        guard let vcs = topMostVC?.navigationController?.viewControllers else {
            return nil
        }
        for v in vcs {
            if v is T {
                return v
            }
        }
        
        return nil
    }
    
    func apiGetNotificationsUnreadCount(){
        
        if UserDefaultsManager.isGuestUser{
            return
        }
        
        EP_Notification.get_unread_notification_count().request(loaderNeeded: false, success: { (response) in
            
            if let data = response as? NotificationData{
                
               debugPrint(data.countOfTotalDoc)
                self.addRedDotAtTabBarItemIndex(index: 3, remove: !(/data.countOfTotalDoc > 0))
                
            }
            
            
        }, error: nil)
        
    }
    
}

