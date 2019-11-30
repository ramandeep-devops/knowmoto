//
//  APIConstants.swift
//  AE
//
//  Created by MAC_MINI_6 on 16/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation

enum ApplicationPhase {
    
    case live
    case dev
    case test
}

let application_phase : ApplicationPhase = .live

internal struct APIBasePath{
    
    static var basePath :String {
        
        get {
            
            if application_phase == .dev {
                
                return "http://54.203.51.37:2200"
                
            } else if application_phase == .test{
                
                return "http://54.203.51.37:2201"
                
            }else {
                
                return "http://54.203.51.37:2202"
            }
        }
    }
    
    //api end point
    static let userEndPoint = "/v1/user/"
    static let commonEndPoint = "/v1/common/"
    static let firebaseDynamicBasePath = "https://knowmo.to"
    
    //kontakt.io for beacons
    static let accessTokenKontaktIO = "uVpwyETwDmgphTkceqUDToiyvjCWbOGY"
    
}

internal struct APIConstant{
    
    static let loginAndNumberVerification = "number_verification"
    static let signup = "signup"
    static let getBrands = "get_brands"
    static let getBrandModelList = "get_brand_model_list"
    static let updateProfile = "update_profile"
    static let getImageSignedUrl = "generate_sign_url"
    static let logout = "logout"
    static let signIn = "number_signin"
    static let get_make_model_list = "model/get_make_model_list"
    static let get_sponsor_list = "make/get_sponsor_list"
    static let add_edit_beacon = "beacon/add_edit_beacon"
    static let get_beacons = "beacon/get_beacons"
    static let get_features = "feature/get_features"
    static let get_modification_category = "feature/get_modification_category"
    static let add_edit_car = "post/add_edit_car"
    static let get_car_feeds = "post/get_car_lists"
    static let link_with_vehicle = "beacon/link_with_vehicle"
    static let remove_beacon = "beacon/remove_beacon"
    static let get_make_years = "make/get_years"
    static let get_home_feed = "post/get_guest_user_feed"
    static let get_user_associated_cars = "post/get_user_associated_cars"
    static let followUnfollow = "post/follow"
    static let add_edit_post = "post/add_edit_post"
    static let get_post_data = "post/get_post_data"
    static let delete = "post/delete"
    static let report = "post/report"
    static let get_notifications = "get_notifications"
    static let approve_tag_request = "post/approve_tag_request"
    static let search = "make/get_main_search"
    static let get_main_search_data = "make/get_main_search_data"
    static let get_most_trending = "post/get_most_trending"
    static let get_beacon_vehicles = "post/get_beacon_vehicles"
    static let makeAlert = "make/alert"
    static let get_model_listing = "model/get_model_listing"
    static let like_dislike = "post/like_dislike"
    static let user_profile = "user_profile"
    static let update_device_token = "update_device_token"
    static let news = "blog/wp-json/wp/posts"
    static let colorsList = "make/get_color_list"
    static let get_unread_notification_count = "get_unread_notification_count"
    static let get_available_fm = "feature/get_available_fm"
    
}

typealias OptionalDictionary = [String : Any]?

extension Sequence where Iterator.Element == Keys {
    func map(values: [Any?]) -> OptionalDictionary {
        var params = [String : Any]()
        
        for (index,element) in zip(self,values) {
            if element != nil {
                params[index.rawValue] = element
            }
        }
        return params
    }
}

enum Keys: String {
    
    typealias RawValue = String
    
    case ccc
    case phone
    case deviceType
    case otp
    case type
    case deviceToken
    case email
    case userId
    case name
    case city
    case location
    case zipCode
    case image
    case search
    case brandId
    case isActive
    case limit
    case skip
    case expire_in
    case file_name
    case interestedMakes
    case id
    case parentId
    case beaconId
    case beaconCompany
    case isUser
    case makeId
    case year
    case country
    case nickName
    case modificationType
    case featureId
    case sponsorId
    case sponsors
    case role
    case features
    case vehicleId
    case userName
    case title
    case place
    case loggedInUserId
    case isApproved
    case beaconIds
    case isLiveExpiry
    case distance
    case idsToSort
    case categories
    case per_page
    case _embed
    case filter
    case isModification
    
}

struct Parameters {
    
    static let loginAndNumberVerification: [Keys] = [.ccc, .phone,.otp,.type]
    static let signIn: [Keys] = [.ccc, .phone, .deviceType,.otp,.type,.deviceToken]
    static let signup: [Keys] = [.userId, .ccc, .phone,.name,.email,.city,.location,.zipCode,.deviceToken,.deviceType,.image,.userName]
    static let get_make_model_list: [Keys] = [.search,.id,.parentId,.type,.limit,.skip,.year,.idsToSort]
    static let getImageSignedUrl: [Keys] = [.expire_in, .file_name]
    static let updateProfile: [Keys] = [.interestedMakes,.ccc, .phone,.name,.email,.city,.location,.zipCode,.image,.userName,.filter]
    static let logout: [Keys] = []
    static let get_beacons: [Keys] = [.search, .id,.beaconId,.userId,.isActive,.limit,.skip]
    static let add_edit_beacon: [Keys] = [.id,.beaconId,.beaconCompany,.userId,.isActive]
    static let get_features: [Keys] = [.search,.limit,.skip,.isModification]
    static let get_available_fm: [Keys] = [.search,.limit,.skip]
    static let get_modification_category: [Keys] = [.search,.limit,.skip]
    static let get_sponsor_list: [Keys] = [.search,.limit,.skip]
    static let add_edit_car: [Keys] = [.id,.name,.makeId,.year,.country,.nickName,.beaconId,.modificationType,.image,.featureId,.sponsorId,.sponsors,.location,.features,.isLiveExpiry]
    static let get_car_feeds: [Keys] = [.role,.id,.userId,.loggedInUserId]
    
    static let remove_beacon: [Keys] = [.id]
    static let get_make_years: [Keys] = [.id]
    static let link_with_vehicle: [Keys] = [.id,.vehicleId,.type]
    static let get_home_feed: [Keys] = [.type,.skip,.limit,.distance,.location]
    static let get_user_associated_cars: [Keys] = [.type,.search,.limit,.skip,.userId,.loggedInUserId]
    static let followUnfollow: [Keys] = [.id,.type]
    static let add_edit_post: [Keys] = [.id,.title,.location,.place,.image,.vehicleId]
    static let get_post_data: [Keys] = [.id,.type,.userId,.search,.limit,.skip,.vehicleId,.loggedInUserId,.makeId]
    static let delete: [Keys] = [.id,.type]
    static let report:[Keys] = [.id,.type]
    static let get_notifications:[Keys] = [.id,.limit,.skip]
    static let approve_tag_request:[Keys] = [.id,.isApproved]
    static let search:[Keys] = [.search,.id,.limit,.skip,.loggedInUserId,.type]
    static let get_main_search_data:[Keys] = [.search,.id,.type,.limit,.skip,.loggedInUserId]
    static let get_most_trending:[Keys] = [.type,.limit,.skip]
    static let get_beacon_vehicles:[Keys] = [.beaconIds,.limit,.skip]
    static let makeAlert:[Keys] = [.id]
    static let get_model_listing:[Keys] = [.parentId,.limit,.skip,.search,.idsToSort]
    static let like_dislike:[Keys] = [.id,.type]
    static let user_profile:[Keys] = [.userId]
    static let update_device_token:[Keys] = [.deviceToken]
    static let news:[Keys] = [.categories,.per_page]
    static let colorsList:[Keys] = []
    static let get_unread_notification_count:[Keys] = []
    
    
}
