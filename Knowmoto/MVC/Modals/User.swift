//
//  User.swift
//  Knowmoto
//
//  Created by Apple on 01/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation

class RootModel<T : Codable> : Codable{
    
    var data:T?
    var message:String?
    
}

class RootDataListModel<T : Codable> : Codable{
    
    var data:RootListModel<T>?
    var message:String?
    
    
}

class RootListModel<T : Codable> : Codable{
    
    var alertByMe:Bool?
    var totalPosts:Int?
    var countOfTotalDoc:Int?
    var list:[T]?
    var message:String?
    
}

class LoginSignupViewModal:NSObject,NSCopying{
    
    var ccc:String?{
        didSet{
            ccc = /ccc?.contains("+") ? ccc : "+" + /ccc
        }
    } //country calling code
    var phone:String?{
        didSet{
            otpSentText = "Enter the OTP sent to \(/ccc) \(/phone)"
        }
    }
    var otp:String?
    var type:String? //Send otp type with OTP and phone number. Type 1 = Signup, 2 = Signin(Already Exist)
    var userId:String?
    var name:String?
    var email:String?
    var city:String?
    var location:Any?
    var image:Any?
    var zipcode:String?
    var accessToken:String?
    var otpSentText:String = ""
    var interestedMakes:Any?
    var userName:String?
    var filter:Any?
    
    init(phone:String?,otp:String?,type:String?,ccc:String?,otpSentText:String = "") {
        
        self.ccc = ccc
        self.phone = phone
        self.otp = otp
        self.type = type
        self.otpSentText = otpSentText
    }
 
    
    convenience init(ccc:String){
        
      self.init(phone: nil, otp: nil, type: nil, ccc: ccc)
        
    }
    
    
    func copy(with zone: NSZone? = nil) -> Any {
        
        let copy = LoginSignupViewModal(phone: /phone, otp: /otp, type: /type, ccc: /ccc,otpSentText:otpSentText)
        return copy
        
    }
    
    override init() {
    }
    
}

class UserData:Codable{
    
    var role:Int?
    var userId:String?
    var type:Int?
    var id:String?
    var name:String?
    var email:String?
    var ccc:String?
    var phone:String?
    var userName:String?
    var city:String?
    var zipCode:String?
    var accessToken:String?
    var image:ImageUrlModel?
    var location:LocationData?
    var interestedMakes:[ModelSelectedInterestedMakes]?
    var recentLocationSearches:[LocationAddress]?
    var selectedHomeLocation:LocationAddress?
    var recentSearches:[SearchDataModel]? // make modal searches (second tab)
}

class LocationData:Codable{
    
    var coordinates:[Double]?
    var location:[Double]?
    var place:String?
}

class ImageUrlModel:NSObject,Codable{
    
    var url:String?
    var thumb:String?
    var _id:String?
    var original:String?
    
    var thumbImageKey:String{
        
        return thumb?.slice(from: ".com/", to: "?") ?? /thumb
        
    }
 
    var originalImageKey:String{
        
        return original?.slice(from: ".com/", to: "?") ?? /original
        
    }
    
    init(original:String?,thumb:String?) {
        
         self.thumb = thumb
         self.original = original
        
    }
    
    convenience override init() {
        self.init(original: "", thumb: "")
    }
    
}

struct SavedLocations:Codable {
    
    var recentSavedLocations:[LocationAddress]?
    var selectedLocation:LocationAddress?
    
}

struct ModelSelectedInterestedMakes:Codable {
    
    var makeId:BrandOrCarModel?
    var modelIds:[BrandOrCarModel]?
    
}

struct SelectedInterestedModel:Codable {
    
    var makeId:String?
    var modelIds:[String]?
    
}


class LocationAddress:NSObject,Codable{
    
    var state:String?
    var name:String?
    var address:String?
    var latitude:Double?
    var longitude:Double?
    
    init(address:String?,latitude:Double?,longitude:Double?,state:String?,name:String?) {
        
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.state = state
        self.name = name
        
    }
    
    override init() {
    }
    
}


class ImageUpload:NSObject{
    
    var original:String?
    var thumbnail:String?
    var image:UIImage?
    var isImageUploaded:Bool?
    var isAddButton:Bool = false
    var isLoadFromUrl:Bool = false
    var isSelected:Bool = false
    
    override init() {
    }
    
    init(original:String?,thumbnail:String?,image:UIImage?,isImageUploaded:Bool?,isLoadFromUrl:Bool = false) {
        
        self.original = original
        self.thumbnail = thumbnail
        self.image = image
        self.isImageUploaded = isImageUploaded
        self.isLoadFromUrl = isLoadFromUrl
        
    }
    
    init(isAddButton:Bool) {
        
        self.isAddButton = isAddButton
        
    }
    
    init(image:UIImage?) {
        self.image = image
    }
    
    
}
