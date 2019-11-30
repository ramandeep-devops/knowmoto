//
//  AlertMessages.swift
//  Idea
//
//  Created by Dhan Guru Nanak on 2/16/18.
//  Copyright © 2018 OSX. All rights reserved.
//

import Foundation

enum AlertMessage:String,CaseIterable{
    
    case emptyEmailId = "Please enter your email Id."
    case notValidEmailId = "Please enter valid email Id."
    case emptyPassword = "Please enter your password."
    case emptyPhoneNumber = "Please enter your phone number."
    case serverError = "Server error"
    case notValidPhoneNumber = "Please enter valid phone number."
    case emptyAddress = "Please select city"
    case emptyName = "Please enter name"
    case notValidPassword = "Please enter valid password"
    case waitingImageUpload = "Image upload is in progress"
    case emptyZipCode = "Please enter zipcode"
    case emptyBeaconId = "Please enter beacon id"
    case emptyBeaconName = "Please enter beacon company name"
    case notValidUserName = "Please enter valid username."
    case emptyUserName = "Please enter user name."
    
    
    func localized()-> String{
        return NSLocalizedString(self.rawValue, comment:"")
    }
}


enum AlertMessageTitle:String,CaseIterable{
    
    case alert = "Alert"
    case success = "Success"

    
    func localized()-> String{
        return NSLocalizedString(self.rawValue, comment:"")
    }
    
}



enum ButtonTitle:String,CaseIterable{
    
    case cancel = "Cancel"
    case delete = "Delete"
    case ok = "Ok"
    
    func localized()-> String{
        return NSLocalizedString(self.rawValue, comment:"")
    }
    
}
