//
//  ProfileDetailVC.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/4/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class ProfileDetailVC: BaseVC {
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var imageViewProfile: KnowmotoUIImageView!
   
    @IBOutlet weak var lblZipCode: UILabel!
    @IBOutlet weak var lblContactNo: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblEmailId: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        setUserData()
    }
    
    func setUserData(){
        
        let userData = UserDefaultsManager.shared.loggedInUser
        
        lblCity.text = /userData?.city
        lblEmailId.text = /userData?.email
        lblZipCode.text = /userData?.zipCode
        lblContactNo.text = "\(/userData?.ccc) \(/userData?.phone)"
        lblUserName.text = /userData?.userName
        imageViewProfile.loadImage(nameInitial: nil, key: /userData?.image?.original, isLoadWithSignedUrl: true, cacheKey: /userData?.image?.original, placeholder: #imageLiteral(resourceName: "userplaceholder_big"))
        
        //ui setup
        viewEmail.isHidden = (userData?.email == nil || /userData?.email?.isEmpty)
        
    }

    func initialSetup(){
        
    
        headerView.headerView.btnRight?.setImage(#imageLiteral(resourceName: "ic_pencil"), for: .normal)
        headerView.headerView.didTapRightButton = { [weak self] (sender) in
            
            let profileSetupVC = ENUM_STORYBOARD<ProfileSetupVC>.registrationLogin.instantiateVC()
            profileSetupVC.loginSignupModel = LoginSignupViewModal()
            profileSetupVC.isfromEditProfile = true
            self?.navigationController?.pushViewController(profileSetupVC, animated: true)
            
        }
    }

    @IBAction func didTapLogout(_ sender: UIButton) {
  
        logout()
    }
    
    func logout(){
        
        self.alertBox(message: "Do you really want to logout?".localized, title: "Logout?".localized) {
            
            EP_Profile.logout().request(success:{ [weak self] (_) in
                
                UserDefaultsManager.clearData()
                self?.reInstantiateWindow()
                
            })
            
        }

    }
    
}
