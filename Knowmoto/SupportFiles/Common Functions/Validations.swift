//
//  Validation.swift
//  Grintafy
//
//  Created by Sierra 4 on 14/07/17.
//  Copyright © 2017 com.example. All rights reserved.
//

import Foundation
import SwiftMessages

enum FieldType {
    case name
    case email
    case phone
}

enum Valid {
    case success
    case failure(String)
}

class Validations {
    
    static let sharedInstance = Validations()
    
    func validateEmail(email: String) -> Bool {
        //    if email.isBlank {
        //      Toast.show(text: AlertMessage.emptyEmailId.localized(), type: .error,changeBackground: true)
        //      return false
        //    }
        if !email.isBlank {
            let emailRegex = "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$"
            let status = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
            if status {
                return true
            } else {
                Toast.show(text: AlertMessage.notValidEmailId.localized(), type: .error,changeBackground: true)
                return false
            }
        }
        return true
    }
    
    func validateUserName(userName: String) -> Bool {
        if userName.isEmpty || userName.length > 16{
            return false
        } else {
            return true
        }
    }
    
    func validatePassword(pswd: String) -> Bool {
        
        if(pswd.isEmpty) {
            Toast.show(text: AlertMessage.emptyPassword.localized(), type: .error,changeBackground: true)
            return false
        }
        else if pswd.count < 8 {
            Toast.show(text: AlertMessage.notValidPassword.localized(), type: .error,changeBackground: true)
            return false
        }else {
            return true
        }
        
    }
    
    func validatePhoneNumber(phone: String) -> Bool {
        if phone.isEmpty {
            Toast.show(text: AlertMessage.emptyPhoneNumber.localized(), type: .error,changeBackground: true)
            return false
        } else {
            if (phone.count > 15 || phone.count < 5 ) {
                Toast.show(text: AlertMessage.notValidPhoneNumber.localized(), type: .error,changeBackground: true)
                return false
            } else{
                return true
            }
        }
    }
    
    
    func validateSetupProfile(name:String?,email:String?,city:String?,zipCode:String?,isFromEditProfile:Bool,userName:String?) ->Valid{
        
        func checkNextValidation() -> Valid {
            
            if (/city?.isEmpty) || /city == "Select city"{
                
                return Valid.failure(AlertMessage.emptyAddress.localized())
                
            }else if (/zipCode?.trimmed().isEmpty){
                
                return Valid.failure(AlertMessage.emptyZipCode.localized())
                
            }else{
                
                return Valid.success
            }
        }
   
        if /userName?.isEmpty{
            
            return Valid.failure(AlertMessage.emptyUserName.localized())
            
        }else if !self.validateUserName(userName: /userName){
            
            return Valid.failure(AlertMessage.notValidUserName.localized())
            
        }else if (/name?.isEmpty){
            
            return Valid.failure(AlertMessage.emptyName.localized())
            
        }else if !(/email?.trimmed().isEmpty){
            
            if !self.validateEmail(email: /email){
                
                return Valid.failure(AlertMessage.notValidEmailId.localized())
                
            }else{
                
                return checkNextValidation()
            }
            
        }else {
            
            return checkNextValidation()
        }
        
    }
    
    func validateAddbeaconPopup(beaconId: String, beaconName:String) -> Valid {
        
            if (/beaconName.trimmed().isEmpty){
                
                return Valid.failure(AlertMessage.emptyBeaconName.localized())
                
            }else if (/beaconId.trimmed().isEmpty){
                
                return Valid.failure(AlertMessage.emptyBeaconId.localized())
                
            }else{
                
                return Valid.success
            }
    }
    
    func validateAddModification(brand:String?,category:String?,partNo:String?,part:String?) -> Valid {
        
        if (/category?.isEmpty){
            
            return Valid.failure("Please select category".localized)
            
        }else if (/brand?.isEmpty){
            
            return Valid.failure("Please select brand".localized)
            
        }
//        else if (/partNo?.trimmed().isEmpty){
//            
//            return Valid.failure("Please enter part number".localized)
//            
//        }
        else if (/part?.trimmed().isEmpty){
            
            return Valid.failure("Please enter part".localized)
            
        }else{
            
            return Valid.success
            
        }
        
    }
    
    
    func validateAddCarStep3(year:String,country:String,nickName:String,arrayPics:[ImageUpload]) -> Valid{
        
//        if (/year.isEmpty){
//
//            return Valid.failure("Please select year".localized)
//
//        }else if (/country.isEmpty) || /country == "Select Country"{
//
//            return Valid.failure("Please select country".localized)
//
//        }else
        if (/nickName.isEmpty){
            
            return Valid.failure("Please enter nick name".localized)
            
        }else if arrayPics.count < 2{ //1 count is of add button thats why not isempty check
            
            return Valid.failure("Please add at least one pic of your car to display.".localized)
            
        }else if !arrayPics.filter({$0.isImageUploaded == false}).isEmpty{ //filtering any image not uploaded from array pics
            
            return Valid.failure("Please wait for image to upload".localized)
            
        }else{
            
            return Valid.success
            
        }
        
    }
    
}


