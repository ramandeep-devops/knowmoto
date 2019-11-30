//
//  ProfileSetupVC.swift
//  Knowmoto
//
//  Created by Apple on 29/07/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit
extension String{
    
    func getImageKey()-> String{
        return self.components(separatedBy: "/").last ?? ""
    }
    
}

class ProfileSetupVC: BaseLoginSignupVC {
    
    //MARK:- Properties
    @IBOutlet weak var viewUserName: UIView!
    
    @IBOutlet weak var viewPhoneNumber: UIView!
    @IBOutlet weak var viewTitleSubtitleContainer: UIView!
    var profileImage:ImageUrlModel?
    
    override var vcType:ENUM_VIEWCONTROLLER_TYPE{
        get{
            return .profileSetup
        }
    }
    
    //MARK:- View controller lifecycle
    
    deinit {
        debugPrint("Deintialized",String(describing: self))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if isScreenOpeningFirstTime {
            
            if !isfromEditProfile{
                textFieldUserName.becomeFirstResponder()
            }
            isScreenOpeningFirstTime = false
        }
    }
    
    func setEditProfileData(){
        
        imageViewProfilePic.loadImage(nameInitial: nil, key: /userData?.image?.original, isLoadWithSignedUrl: true, cacheKey: /userData?.image?.originalImageKey, placeholder: #imageLiteral(resourceName: "userplaceholder_small"))
        
        textFieldCity.text = userData?.city
        textFieldName.text = userData?.name
        textFieldEmail.text = userData?.email
        textFieldZipCode.text = userData?.zipCode
        textFieldPhoneNumber.text = userData?.phone
        textFieldUserName.text = userData?.userName
        
        if isfromEditProfile{
            textFieldPhoneNumber.setRightPadding(padding: 72.0)
        }
        
        loginSignupModel.userName = userData?.userName
        loginSignupModel.phone = userData?.phone
        loginSignupModel.ccc = userData?.ccc
        loginSignupModel.location = userData?.location?.coordinates?.toJsonString()
        loginSignupModel.city = userData?.city
        loginSignupModel.name = userData?.name
        loginSignupModel.email = userData?.email
        loginSignupModel.zipcode = userData?.zipCode
        profileImage = ImageUrlModel.init(original: /userData?.image?.original, thumb: /userData?.image?.thumb)
        loginSignupModel.image = JSONHelper<ImageUrlModel>().toJSONString(model: (profileImage) ?? ImageUrlModel.init(original: "", thumb: ""))
        
        btnCountryCode.setTitle(/userData?.ccc, for: .normal)
        self.view.layoutIfNeeded()
        
    }
    
    func setLayout(){
        
        btnSubmit.enableButton = isfromEditProfile
        self.viewTitleSubtitleContainer.isHidden = isfromEditProfile
        btnSubmit.setTitle(isfromEditProfile ? "Update".localized : "Submit".localized, for: .normal)
        viewPhoneNumber.isHidden = !isfromEditProfile
        
    }
    
    internal override func initialSetup(){
        
        super.initialSetup()
        
        if isfromEditProfile{
            
            setEditProfileData()
            
        }
        
        self.setLayout()
        actionSelectPhoto()
        actionBackButtonOvverride()
    }
    
    func actionSelectPhoto(){
        
        //action select profile pic
        imageViewProfilePic.didSelectPhoto = { [weak self] (sender) in
            
            self?.didSelectProfilePic(sender)
        }
    }
    
    func actionBackButtonOvverride(){
        
        //action back button
        headerView.headerView.didTapLeftButton = { [weak self] (sender) in
            
            if /self?.isfromEditProfile{
                
                self?.navigationController?.popViewController(animated: true)
                
            }else{
                
                self?.navigationController?.viewControllers.forEach({ (vc) in
                    
                    if vc.isKind(of: PhoneInputVC.self){
                        
                        self?.navigationController?.popToViewController(vc, animated: true)
                        
                    }
                    
                })
                
            }
            
        }
    }
    
    //MARK:- button Actions
    
    //action select city
    @IBAction func didTapCity(_ sender: UIButton) {
        
        openPlacePicker()
        
    }
    
    @objc func didSelectProfilePic(_ sender: UIButton) { //action didSelect profile pic
        
        self.view.endEditing(true)
        
        CameraGalleryPickerBlock.sharedInstance.pickerImage(pickedListner: { [weak self] (image, imageData, mediatype) in
            
            
            _ = S3BucketHelper.shared.setImage(image: image, dictImages: nil, imageView: (self?.imageViewProfilePic)!, completeion: { [weak self] (originalUrl, thumbnailUrl,_) in
                
                self?.profileImage = ImageUrlModel(original: /originalUrl.getImageKey(), thumb: /thumbnailUrl.getImageKey())
                debugPrint("original url:-",originalUrl)
                debugPrint("thumbnailUrl:-",thumbnailUrl)
                
                
            })
            
        }) {
            
        }
        
    }
    
    //action Submit
    @IBAction func didTapSubmit(_ sender: UIButton) {
        
        setApiModelData()
        
        self.view.endEditing(true)
        
        //validate
        if !validate(){
            
            return
        }
        
        
        apiSignup()
    }
    
    func setApiModelData(){
        
        loginSignupModel.userName = textFieldUserName.text
        loginSignupModel.city = textFieldCity.text
        loginSignupModel.name = textFieldName.text
        loginSignupModel.email = textFieldEmail.text?.trimmed()
        loginSignupModel.zipcode = textFieldZipCode.text?.trimmed()
        loginSignupModel.image = JSONHelper<ImageUrlModel>().toJSONString(model: (profileImage) ?? ImageUrlModel.init(original: "", thumb: ""))
        
    }
    
    
    //MARK:- API
    
    func apiSignup(){
        
        if !imageViewProfilePic.isImageLoaded{ // check image loading in progress
            
            Toast.show(text: AlertMessage.waitingImageUpload.localized(), type: .error)
            return
        }
        
        if isfromEditProfile{
            
            EP_Profile.updateProfile(model: loginSignupModel).request(success:{ [weak self] (response) in
                
                let userData = (response as? UserData)
                UserDefaultsManager.shared.loggedInUser = userData
                
                self?.navigationController?.popViewController(animated: true)
                
                Toast.show(text: "Profile updated successfully".localized, type: .error)
                
            })
            
            
        }else{
            
            EP_Login.signUp(model: loginSignupModel).request(success: { [weak self] (response) in
                
                
                
                
                let userData = (response as? UserData)
                UserDefaultsManager.shared.loggedInUser = userData
                
                //intialize socket
                SocketAppManager.sharedManager.initializeSocket()
                
                self?.redirectToSelectInterest(isFromSignupProcess: true)
                
            })
        }

    }
    
    func apiGetOtpForEditProfofile(){
        
        self.view.endEditing(true)
        
        let verifyOtpRequestForEditProfile = EP_Login.loginAndNumberVerification(model: loginSignupModel)
        
        verifyOtpRequestForEditProfile.request(success: { [weak self] (response) in
            
            self?.redirectToOTPVC(response: response)
            
            
        }) { [weak self] (error) in
            
            
            debugPrint(error)
            
        }
    }
    
    func redirectToOTPVC(response:Any){ // redirection to otp screen
        
        let _response = (response as? UserData)
        
        let otpVC = ENUM_STORYBOARD<OTPInputVC>.registrationLogin.instantiateVC()
        otpVC.loginSignupModel = self.loginSignupModel.copy() as! LoginSignupViewModal
        otpVC.isfromEditProfile = self.isfromEditProfile
        otpVC.delegate = self
        self.navigationController?.pushViewController(otpVC, animated: true)
    }
    
    @IBAction func didTapVerifyPhoneNumberInEditProfile(_ sender: Any) {
        
        loginSignupModel.type = "3"
        loginSignupModel.phone = textFieldPhoneNumber.text?.trimmed()
        
        self.apiGetOtpForEditProfofile()
        
    }
    
    
}
extension ProfileSetupVC:OTPInputVCDelegate{
    
    func didNumberVerifiedSuccessfully() {
        
        btnVerify.isHidden = true
        self.validatingEmptyStringLoginSignUpFlow(currentSenderText: /textFieldPhoneNumber.text, sender: textFieldPhoneNumber)
        
    }
    
}
