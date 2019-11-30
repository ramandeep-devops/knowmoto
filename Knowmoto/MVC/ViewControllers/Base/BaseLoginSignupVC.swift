//
//  BaseLoginSignupVC.swift
//  Knowmoto
//
//  Created by Apple on 01/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

/*
 Description:- Phone InputPhoneVC screen always getting otp for login and signup flow and on this flow getting
 
 (type param-> 1-Signup,2-Login)
 
 Flow
 InputPhoneVC ->Get ->type param  ->sendingTo -> Otpverify screen ->Hit verify api -> return ->
 
 */

typealias LoginSignUpType = (ccc:String,phone:String,otp:String,type:String)

protocol ProtocolLoginSignupProfile:class {
    
    var vcType:ENUM_VIEWCONTROLLER_TYPE{get}
    func initialSetup()
    
}

class BaseLoginSignupVC: BaseVC,ProtocolLoginSignupProfile{
    
    //MARK:-Outlets
    
    @IBOutlet weak var btnVerify: UIButton!
    
    @IBOutlet weak var btnSubmit: KnomotButton!
    
    @IBOutlet weak var textFieldUserName: KnowMotoTextField!
    
    @IBOutlet weak var textFieldPhoneNumber: KnowMotoTextField!
    
    @IBOutlet weak var btnCountryCode: UIButton!
    
    @IBOutlet weak var imageViewProfilePic: KnowmotoUIImageView!
    
    @IBOutlet weak var textFieldZipCode: KnowMotoTextField!
    
    @IBOutlet weak var textFieldCity: KnowMotoTextField!
    
    @IBOutlet weak var textFieldName: KnowMotoTextField!
    
    @IBOutlet weak var textFieldEmail: KnowMotoTextField!
    
    
    //MARK:- Properties
    
    var isfromEditProfile:Bool = false
    var vcType:ENUM_VIEWCONTROLLER_TYPE{
        get{
            return .PhoneInputVC
        }
    }
    
    var loginSignupModel = LoginSignupViewModal(ccc: "+1")
    
    //MARK;-View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
    //Intialize setup
    func initialSetup(){
   
        textFieldPhoneNumber?.delegate = self
        textFieldZipCode?.delegate = self
        textFieldName?.delegate = self
        textFieldUserName?.delegate = self
    }

    
    //MARK:- Button actions
    
    //action country code selction
    @IBAction func didTapCountryCode(_ sender: UIButton) {
        
        let vc = ENUM_STORYBOARD<CountryCodeSearchViewController>.miscelleneous.instantiateVC()
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
  
}

//MARK:- country picker delegate
extension BaseLoginSignupVC:CountryCodeSearchDelegate{
    
    func didTap(onCode detail: [AnyHashable : Any]!) {
        
        let dialCode = /(detail[ENUM_COUNTRY_PICKER_KEYS.dial_code.rawValue] as? String)
        btnCountryCode.setTitle(dialCode, for: .normal)
        loginSignupModel.ccc = dialCode
        
        if isfromEditProfile{
            
            btnVerify.isHidden = textFieldPhoneNumber.text == userData?.phone && btnCountryCode.titleLabel?.text == /userData?.ccc
            btnSubmit.enableButton = btnSubmit.isEnabled && btnVerify.isHidden
            
        }
        
    }
    
}


//MARK:- Validation onlly Login signup flow empty string to enable submit button
extension BaseLoginSignupVC{
    
    func validatingEmptyStringLoginSignUpFlow(currentSenderText:String,sender:UITextField){
        
        switch vcType {
            
        case .PhoneInputVC:
            
            btnSubmit.enableButton = !(currentSenderText.isEmpty)
            
            
        case .profileSetup:
            
            if currentSenderText.trimmed().isEmpty{
                
                btnSubmit.enableButton = false
                
            }else{
                
                
                var isEnableSubmitButton = true
                
                if sender != textFieldName{
                    
                   isEnableSubmitButton = !(/textFieldName.text?.trimmed().isEmpty)
              
                }
                if sender != textFieldZipCode{
                    
                    isEnableSubmitButton = isEnableSubmitButton && !(/textFieldZipCode.text?.isEmpty)
                    
                }
                if sender != textFieldCity{
                    
                    isEnableSubmitButton = isEnableSubmitButton && !(/textFieldCity.text?.trimmed().isEmpty)
                    
                }
                
                if sender != textFieldPhoneNumber && isfromEditProfile{
                    
                    isEnableSubmitButton = isEnableSubmitButton && !(/textFieldPhoneNumber.text?.trimmed().isEmpty)
                    
                }
                
                if sender != textFieldUserName && isfromEditProfile{
                    
                    isEnableSubmitButton = isEnableSubmitButton && !(/textFieldUserName.text?.trimmed().isEmpty)
                    
                }
          
                
                btnSubmit.enableButton = isEnableSubmitButton
            }
   
            break
            
        default:
            break
        }
        
    }
    
    //Validating all login signup flow
    func validate() ->Bool{
        
        switch vcType {
            
        case .PhoneInputVC:
            
            loginSignupModel.phone = textFieldPhoneNumber?.text
            let valid = Validations.sharedInstance.validatePhoneNumber(phone: /loginSignupModel.phone)
            
            return valid
            
            
        case .profileSetup:
            
            let valid = Validations.sharedInstance.validateSetupProfile(name: /loginSignupModel.name, email: /loginSignupModel.email, city: /loginSignupModel.city, zipCode: /loginSignupModel.zipcode, isFromEditProfile: isfromEditProfile, userName: loginSignupModel.userName)
            
            switch valid{
                
            case .success:
                
                return true
                
            case .failure(let message):
                
                Toast.show(text: message, type: .error)
                return false
            }
            
            
            break
            
        default:
            break
        }
        
        return true
    }
    
    
    
}

//MARK:-Uitextfield delegate
extension BaseLoginSignupVC{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let updatedText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        
        
        
        if textField != textFieldCity{
        validatingEmptyStringLoginSignUpFlow(currentSenderText: updatedText, sender: textField) // to enable submit button
        }
        
        if isfromEditProfile && textField == textFieldPhoneNumber{
            
            let isUpdatingPhoneTextValid = updatedText.count >= 5 && updatedText.count <= 15
            
            if isUpdatingPhoneTextValid{
                
                btnVerify.isHidden = updatedText == userData?.phone && btnCountryCode.titleLabel?.text == /userData?.ccc
                btnSubmit.enableButton = btnSubmit.isEnabled && btnVerify.isHidden
                
            }else{
                
                btnVerify.isHidden = true
                btnSubmit.enableButton = false
                
            }
            
            
        }
        
        return true
    }
}


extension BaseLoginSignupVC{
    
    //MARK:- redirection controller functions
    
    func openPlacePicker(){//place picker
        
        let placePickerVC = ENUM_STORYBOARD<PlacePickerVC>.miscelleneous.instantiateVC()
        placePickerVC.selectedAddress = /textFieldCity.text
        placePickerVC.searchType = [.district,.place]
        
        placePickerVC.didGetLocation = { [weak self] (location) in
            
            self?.loginSignupModel.city = /location.name
            self?.loginSignupModel.location = [location.longitude,location.latitude].toJsonString()
            
            
            self?.textFieldCity.text = self?.loginSignupModel.city
            
            
            self?.validatingEmptyStringLoginSignUpFlow(currentSenderText: /self?.textFieldCity.text, sender: (self?.textFieldCity)!)
        }
        
        self.present(placePickerVC, animated: true, completion: nil) // navigationController?.pushViewController(placePickerVC, animated: true)
        
    }
    
}
