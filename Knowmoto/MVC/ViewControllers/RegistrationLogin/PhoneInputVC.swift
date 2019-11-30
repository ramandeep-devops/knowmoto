//
//  PhoneInputVC.swift
//  Knowmoto
//
//  Created by Apple on 29/07/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class PhoneInputVC: BaseLoginSignupVC {
    
    //MARK:- Properties    
    
    //MARK:- View controller lifecycle
    var isFromWalkThrough:Bool = false

    override var vcType:ENUM_VIEWCONTROLLER_TYPE{
        get{
            return .PhoneInputVC
        }
    }
    
    deinit {
        debugPrint("Deintialized",String(describing: self))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initialSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        textFieldPhoneNumber.becomeFirstResponder()
    }
    
    
    internal override func initialSetup(){
        
        super.initialSetup()
        
        //action back button
        headerView.headerView.didTapLeftButton = { [weak self] (sender) in
            
            self?.switchTab(tab: .home)
            
            if /self?.isFromWalkThrough{
                
                self?.navigationController?.popToRootViewController(animated: true)
                
            }else{
                
                self?.navigationController?.popViewController(animated: true)
                
            }
            
        }
    }
    
    //action Submit
    @IBAction func didTapSubmit(_ sender: UIButton) {

        self.view.endEditing(true)

        //validate
        if !validate(){
            return
        }

        self.apiGetOTP()
    }
  
    func redirectToOTPVC(response:Any){ // redirection to otp screen
        
        let _response = (response as? UserData)
        
        let otpVC = ENUM_STORYBOARD<OTPInputVC>.registrationLogin.instantiateVC()
        otpVC.loginSignupModel = self.loginSignupModel.copy() as! LoginSignupViewModal
        otpVC.loginSignupModel.type = _response?.type?.toString // setting type param
        self.navigationController?.pushViewController(otpVC, animated: true)
    }
}

//MARK:- API
extension PhoneInputVC{
    
    func apiGetOTP(){
        
        self.view.endEditing(true)
        
        //validate
        if !validate(){
            return
        }
        
        let getOTPRequest = EP_Login.getOtp(model:loginSignupModel)
     
        getOTPRequest.request(success: { [weak self] (response) in
            
            
            self?.redirectToOTPVC(response: response)
            
            
        }) { [weak self] (error) in
            
            
            debugPrint(error)
            
        }
    }
    
    
}
