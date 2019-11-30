//
//  Enums.swift
//  Knowmoto
//
//  Created by Apple on 27/07/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation
import UIKit


enum ENUM_STORYBOARD<T : UIViewController>: String {
    case main = "Main"
    case miscelleneous = "Miscelleneous"
    case tabbar = "TabBar"
    case registrationLogin = "RegistrationLogin"
    case profile = "Profile"
    case car = "Car"
    case post = "Post"
    case map = "Map"
    
    func instantiateVC() -> T {
        let sb = UIStoryboard(name: self.rawValue, bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: String(describing: T.self)) as! T
        return vc
    }
}



enum ENUM_VIEWCONTROLLER_TYPE:String{
    
    enum DISMISS_TYPE{
        
        case dismiss
        case pop
    }
    
    typealias HeaderDetail = (String,UIImage?,Bool,Bool,DISMISS_TYPE,UIColor)//(title,centerTitleImage,isHideLeftButton,isHideRightButton,dismissType,backgroundColor)

    case PhoneInputVC = "PhoneInputVC"
    case OTPInputVC = "OTPInputVC"
    case profileSetup = "profileSetup"
    
    //common
    case commonWithBackPop = "commonWithBackPop"
    case commonWithBackPopWithRightButton = "commonWithBackPopWithRightButton"
    case commonWithBackDismiss = "commonWithBackDismiss"
    case commonCenterAppIcon = "commonCenterAppIcon"
    case commonCenterAppIconAndBack = "commonCenterAppIconAndBack"
    case commonWithBackDismissWithRightButton = "commonWithBackDismissWithRightButton"

    func getHeaderDetail() -> HeaderDetail? {
        
        switch self {
            
        case .PhoneInputVC:
            
            return("",#imageLiteral(resourceName: "logo_small"),false,true,.pop,UIColor.clear)
            
        case .commonCenterAppIcon:
  
            return("",#imageLiteral(resourceName: "logo_small"),true,true,.pop,UIColor.clear)
            
        case .commonCenterAppIconAndBack:
            
            return("",#imageLiteral(resourceName: "logo_small"),false,true,.pop,UIColor.clear)
            
        case .commonWithBackPop:
            
            return("",nil,false,true,.pop,UIColor.clear)
            
        case .commonWithBackDismiss:
            
            return("",nil,false,true,.dismiss,UIColor.clear)
            
        case .commonWithBackDismissWithRightButton:
            
            return("",nil,false,false,.dismiss,UIColor.clear)
            
        case .commonWithBackPopWithRightButton:
            
            return("",nil,false,false,.pop,UIColor.clear)
            
        default:
            break
            
        }
        
        
        return nil
    }
    
}

enum ENUM_MEDIA_PICKER_TYPE{
    
    case camera
    case photoLibrary
    case videoGallery
    case takeAPhoto
    
    func get() -> String{
        
        switch self {
            
        case .camera:
            return "Camera".localized
            
        case .photoLibrary:
            return "Photo Library".localized
            
        case .videoGallery:
            return "Video Gallery".localized
            
        case .takeAPhoto:
            return "Video".localized
        }
    }
}

enum ENUM_MEDIA_TPE{
    
    case image
    case video
    
}


//Fonts
private let familyName = "Nexa"

enum ENUM_APP_FONT: String {
    case light = "Light"
    case book = "Book"
    case bold = "Bold"
    case xbold = "XBold"
    case regular = "Regular"
    
    func size(_ size: CGFloat) -> UIFont {
        if let font = UIFont(name: fullFontName, size: size) {
            return font
        }
        fatalError("Font '\(fullFontName)' does not exist.")
    }
     var fullFontName: String {
        return rawValue.isEmpty ? familyName : familyName + "-" + rawValue
    }
}


enum ENUM_KEYBOARD_DONE_BUTTON_TEXT:String{
    case done = "Done"
    case submit = "Submit"
}

enum ENUM_COUNTRY_PICKER_KEYS:String{
    
    case dial_code = "dial_code"
    case isoCode = "code"
    case name = "name"
}

enum ENUM_LOGIN_SIGNUP_TYPE:Int{
    
    case signup = 1
    case login = 2

}

enum ENUM_SEARCH_TYPE{
    
    case location
    case brand
    case model
    
    func getPlaceHolder() -> String{
        
        switch self {
            
        case .location:
            
            return ""
            break
            
        default:
            break
            
        }
        return ""
    }
    
}

enum ENUM_HOME_TAB:Int{
    case home = 0
    case search
    case addPost
    case notification
    case news
}

extension NSNotification.Name{
    
    static let UPDATE_LOADING = Notification.Name("UPDATE_LOADING")
    static let PROFILE_UPDATE = Notification.Name("PROFILE_UPDATE")
    static let RELOAD_CAR_DETAIL = Notification.Name("RELOAD_CAR_DETAIL")
    static let RELOAD_POST = Notification.Name("RELOAD_POST")
    static let DELETE_POST = Notification.Name("DELETE_POST")
}

enum ENUM_APP_USERS:Int{
    
    case basicUser = 1
    case beaconOwnerOrCarsAdded = 2
    
    var headerHeight:CGFloat{
        
        switch self{
            
        case .basicUser:
            
            return 200
            
        case .beaconOwnerOrCarsAdded:
            
            return 366
            
        }
        
    }
    
    var selectedSegmentHeight:CGFloat{
        
        switch self{
            
        case .basicUser:
            
            return 0
            
        case .beaconOwnerOrCarsAdded:
            
            return 2
            
        }
        
    }
    
    var segmentViewHeight:CGFloat{
        
        switch self{
            
        case .basicUser:
            
            return 0
            
        case .beaconOwnerOrCarsAdded:
            
            return 48
            
        }
        
    }
    
    
}



enum ENUM_GET_POST_TYPE:Int{
    
    case all = 0
    case basicUser = 1
    case beaconOwner = 2
    case tagUserPosts = 3
    case mostLikedPosts = 4
    case postAccordingToTheCar = 5
    case makePost = 7
    
}

enum ENUM_CAR_DETAIL_SCREEN_TYPE{
    
    case myCarWithBeacon
    case myCar
    case sponsor
    case beaconWithSponsor
    case featuredCar
    case carLiked
    case carRemoveLike
    case owner
    case ownerWithSponsor
    
    func getTypeOfScreen(carData:CarListDataModel,isFromProfile:Bool) ->ENUM_CAR_DETAIL_SCREEN_TYPE {
        
        let isHaveBeaconID = (carData.beaconID != nil && !(/carData.beaconID?.isEmpty))
        let isHaveSponsor = (carData.sponsorID != nil && !(/carData.sponsorID?.isEmpty))
        
        if !isHaveBeaconID && !isHaveSponsor && isFromProfile{
            
            return ENUM_CAR_DETAIL_SCREEN_TYPE.myCar
            
        }else if isFromProfile && isHaveBeaconID && !isHaveSponsor{
            
            return ENUM_CAR_DETAIL_SCREEN_TYPE.myCarWithBeacon
            
        }else if isFromProfile && !isHaveBeaconID && isHaveSponsor{
            
            return ENUM_CAR_DETAIL_SCREEN_TYPE.sponsor
            
        }else if isFromProfile && isHaveBeaconID && isHaveSponsor{
            
            return ENUM_CAR_DETAIL_SCREEN_TYPE.beaconWithSponsor
            
        }else if !isFromProfile && isHaveSponsor{
            
            return ENUM_CAR_DETAIL_SCREEN_TYPE.ownerWithSponsor
            
        }else if !isFromProfile && !isHaveSponsor{
            
            return ENUM_CAR_DETAIL_SCREEN_TYPE.owner
        }else {
            
            return ENUM_CAR_DETAIL_SCREEN_TYPE.owner
        }
        
    }
    
    var isHideRightButton:Bool{
        
        switch self {
            
        case .myCar,.myCarWithBeacon,.beaconWithSponsor,.myCarWithBeacon:
            
            return false
            
        default:
            
            return true
        }
    }
    
    var headerHeight:CGFloat{
        switch self {
            
        case .myCar:
            
            return 156.0
            
        case .myCarWithBeacon:
            
            return 334.0
            
        case .sponsor:
            
            return 388.0
            
        case .beaconWithSponsor,.ownerWithSponsor:
            
            return 500.0
            
        case .owner:
            
            return 334.0
            
        default:
            return 0.0
        }
    }
    
    var segmentTitleArray:[String]{
        
        switch self{
            
        case .myCar,.myCarWithBeacon:
            
            return ["POSTS".localized,"TAGGED".localized,"DETAILS".localized]
            
        default:
            
            return ["GALLERY".localized,"TAGGED".localized,"DETAILS".localized]
        }
        
    }
}

enum ENUM_DYNAMIC_LINK_TYPE:String{
    case postId = "p" // postid
    case vehicleId = "v" //vehicleId
}

enum ENUM_CAR_SELECTION_TYPE:Int{
    
    case make = 1
    case model
    case submodel
    case color
    case brandOrSponsor
    case myCars
    case years
    
    
    
    var noOfCellInRow:Int{
        switch self {
        case .brandOrSponsor,.myCars:
            return 3
        default:
            return 2
        }
    }
    
    var squareCell:Bool{
        switch self {
        case .brandOrSponsor,.myCars:
            return true
        default:
            return false
        }
    }
    
    var noDataFoundText:String{
        switch self {
            
        case .myCars:
            
            return "No vehicles found".localized
            
        case .make:
            
            return "No makes found".localized
            
        case .model:
            
            return "No models found".localized
            
        case .brandOrSponsor:
            
            return "No brands founds".localized
            
        default:
            return ""
            
        }
    }
    
    var title:String{
        switch self {
            
        case .myCars:
            
            return "My vehicles".localized
            
        case .make:
            
            return "What are you interested in?".localized
            
        case .model:
            
            return ""
            
        case .brandOrSponsor:
            
            return "Select brand".localized
            
        default:
            return ""
            
        }
    }
    
    var subTitle:String{
        switch self {
            
        case .make:
            
            return "Select makes mentioned below to help personalize your knowmoto experience.".localized
            
        case .model:
            
            return "Select models you are interested in to personalize your feed.".localized
            
        default:
            return ""
            
        }
    }
    
    var placeHolder:String{
        switch self {
            
        case .make:
            
            return "Search for a vehicle makes".localized
            
        case .model:
            
            return "Search for a models".localized
            
        default:
            return ""
            
        }
    }
    
}
