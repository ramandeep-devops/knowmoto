//
//  TabBarVC.swift
//  Knowmoto
//
//  Created by Apple on 03/09/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit


class TabBarVC: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.addCenterButton()
        }
    }
    
    
    func addCenterButton() {
        
        //setting button frame
        let button = UIButton(type: .system)
        button.tintColor = UIColor.BorderColor!.withAlphaComponent(0.5)
        button.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin]
        button.frame = CGRect(x: 0.0, y: 0.0, width: 56, height: 56)
        button.layer.masksToBounds = false
        button.setImage(#imageLiteral(resourceName: "ic_addpost"), for: .normal)
        
        let rectBoundTabbar = self.tabBar.bounds
        let xx = rectBoundTabbar.midX
        let yy = button.center.y
        button.center = CGPoint(x: xx, y: yy)
        
        //adding to tabbar
        self.tabBar.addSubview(button)
        self.tabBar.bringSubviewToFront(button)
        
        //button action
        button.addTarget(self, action: #selector(handleTouchTabbarCenter), for: .touchUpInside)
    }
    
    
    @objc func handleTouchTabbarCenter(){
        
        if UserDefaultsManager.isGuestUser{
            
            if UserDefaultsManager.shared.isWalkthroughDone{
                
                let vc = ENUM_STORYBOARD<PhoneInputVC>.registrationLogin.instantiateVC()
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else{
                
                let vc = ENUM_STORYBOARD<WalkThroughVC>.registrationLogin.instantiateVC()
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            
        }else{
            
            let vc = ENUM_STORYBOARD<GalleryVC>.post.instantiateVC()
            let navigationController = UINavigationController(rootViewController: vc)
            
            navigationController.navigationBar.isTranslucent = false
            navigationController.navigationBar.isHidden = true
            navigationController.navigationBar.barTintColor = UIColor.clear
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}
