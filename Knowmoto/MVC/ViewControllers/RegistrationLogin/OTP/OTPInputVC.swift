//
//  OTPInputVC.swift
//  Knowmoto
//
//  Created by Apple on 29/07/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

protocol OTPInputVCDelegate:class {
    func didNumberVerifiedSuccessfully()
}

class OTPInputVC: BaseLoginSignupVC {
    
    //MARK:- Outlets
    
    @IBOutlet weak var viewOTPInput: UIView!
    @IBOutlet weak var lblOtpSentTo: UILabel!
    
    var codeInputView: OTPCodeInputView?
    var delegate:OTPInputVCDelegate?
    
    override var vcType:ENUM_VIEWCONTROLLER_TYPE{
        get{
            return .OTPInputVC
        }
    }
    
    //MARK:-View controller lifecycle
    
    deinit {
        debugPrint("Deintialized",String(describing: self))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        codeInputView?.becomeFirstResponder()
    }
    
    internal override func initialSetup(){
        
        //        self.vcType = .OTPInputVC
//        setUpOTPCodeView()
        
        btnSubmit.setTitle(isfromEditProfile ? "Update".localized : "Submit".localized, for: .normal)
                self.perform(#selector(self.setUpOTPCodeView), with: nil, afterDelay: 0.1)
        lblOtpSentTo.text = /loginSignupModel.otpSentText
    }
    
    
    //Setting up otp code view
    @objc func setUpOTPCodeView(){
        
        viewOTPInput.backgroundColor = UIColor.clear
        
        if viewOTPInput.viewWithTag(7) == nil {
            
            // generate code input field
            
            codeInputView = OTPCodeInputView(frame: viewOTPInput.bounds)
            codeInputView!.tag = 7
            viewOTPInput.addSubview(codeInputView!)
            codeInputView?.delegate = self
        }
        
    }
    
    //action Submit
    @IBAction func didTapSubmit(_ sender: UIButton) {
        
        self.apiOTPVerificationAndGetOtp(isGetOtp: false) //Verifying otp
        
    }
    
    //MARK:- Button actions
    @IBAction func didTapReseneCode(_ sender: UIButton) {
        
        self.apiOTPVerificationAndGetOtp(isGetOtp: true)
        
    }
    
    func redirectToProfileSetup(response:Any){
        
        let _response = (response as? UserData)
        
        let profileSetupVC = ENUM_STORYBOARD<ProfileSetupVC>.registrationLogin.instantiateVC()
        profileSetupVC.loginSignupModel = self.loginSignupModel.copy() as! LoginSignupViewModal
        profileSetupVC.loginSignupModel.userId = _response?.id
        self.navigationController?.pushViewController(profileSetupVC, animated: true)
    }
    
    func handleResponse(response:Any){
        
        let _response = (response as? UserData)
        
        let type = ENUM_LOGIN_SIGNUP_TYPE(rawValue: /loginSignupModel.type?.toInt()) ?? .login
        
        switch type {
            
        case .login: // redirect to home
            
            UserDefaultsManager.shared.loggedInUser = _response
            //intialize socket
            SocketAppManager.sharedManager.initializeSocket()
            
            self.reInstantiateWindow()
            
            break
            
        case .signup: // redirect to signup
            
            self.redirectToProfileSetup(response: response)
            
        }
        
    }
    
}

//MARK:- API
extension OTPInputVC{
    
    func apiOTPVerificationAndGetOtp(isGetOtp:Bool){
        
        self.view.endEditing(true)
        
        let verifyOtpRequest = EP_Login.signIn(model:loginSignupModel)
        let getOTPRequest = EP_Login.getOtp(model:loginSignupModel)
        let verifyOtpRequestForEditProfile = EP_Login.loginAndNumberVerification(model: loginSignupModel)
        
        let endPoint = isGetOtp && !self.isfromEditProfile ? getOTPRequest : isfromEditProfile ? verifyOtpRequestForEditProfile : verifyOtpRequest
        
        endPoint.request(success: { [weak self] (response) in
            
             if /self?.isfromEditProfile && !isGetOtp{  // edit profile
                
                let _response = (response as? UserData)
                UserDefaultsManager.shared.loggedInUser = _response
                
                self?.delegate?.didNumberVerifiedSuccessfully()
                self?.navigationController?.popViewController(animated: true)
                Toast.show(text: "Phone number verified and updated successfully".localized, type: .success)
                
            }else if !isGetOtp && !(/self?.isfromEditProfile){ //Otp verification in signup process
                
                self?.handleResponse(response: response)
                
            }else{ //otp sent
                
                Toast.show(text: "An OTP resent to your registered mobile number".localized, type: .success)
                self?.codeInputView?.becomeFirstResponder()
                
            }
            
            
        }) { [weak self] (error) in
            
            
            self?.loginSignupModel.otp = nil
            self?.codeInputView?.becomeFirstResponder()
            self?.codeInputView?.clear()
            
            
            debugPrint(error)
            
        }
    }
    
    
}

//MARK:- OTP code inputView delegate
extension OTPInputVC: CodeInputViewDelegate
{
    func codeInputView(_ codeInputView: OTPCodeInputView, didFinishWithCode code: String,completion:Bool){
        
        btnSubmit.enableButton = completion // completion -> true  when 5 boxes all filled
        
        if completion{
            
            loginSignupModel.otp = code
            self.didTapSubmit(UIButton())
            
        }
        
        debugPrint(code)
    }
}
