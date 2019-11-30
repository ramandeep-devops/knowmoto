//
//  EP_Car.swift
//  Knowmoto
//
//  Created by Apple on 18/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation
import Moya


enum EP_Car {
    
    case get_features(search:String?,limit:Int?,skip:Int?,isModification:Bool?)
    case get_modification_category(search:String?,limit:Int?,skip:Int?)
    case get_sponsor_list(search:String?,limit:Int?,skip:Int?)
    case add_edit_car(id:String?,name:String?,makeId:Any?,year:Int?,country:String?,nickName:String?,beaconId:String?,modificationType:Any?,image:Any?,featureId:Any?,sponsorId:Any?,sponsors:Any?,location:Any?,features:Any?,isLiveExpiry:Int64?)
    case get_car_feeds(id:String?,userId:String?,loggedInUserId:String?)
    case get_make_years(id:String?)
    case followUnfollow(id:String?,type:Int?)
    case get_beacon_vehicles(beaconIds:Any?,limit:Int?,skip:Int?)
    case makeAlert(id:String?)
    case like_dislike(id:String?,type:Int?)
    case colorsList()
    case get_available_fm(search:String?,limit:Int?,skip:Int?)
    
  
}

extension EP_Car: TargetType, AccessTokenAuthorizable {
    
    var baseURL: URL {
        
        switch self {
            
        default:
            return URL(string: APIBasePath.basePath + APIBasePath.userEndPoint)!
        }
    }
    
    var path: String {
        
        switch self {
            
        case .get_features(_):
            return APIConstant.get_features
            
        case .get_modification_category(_):
            return APIConstant.get_modification_category
            
        case .get_sponsor_list(_):
            return APIConstant.get_sponsor_list
            
        case .add_edit_car(_):
            return APIConstant.add_edit_car
            
        case .get_car_feeds(_):
            return APIConstant.get_car_feeds
            
        case .get_make_years(_):
            return APIConstant.get_make_years
            
        case .followUnfollow(_):
            return APIConstant.followUnfollow
            
        case .get_beacon_vehicles(_):
            return APIConstant.get_beacon_vehicles
            
        case .makeAlert(_):
            return APIConstant.makeAlert
            
        case .like_dislike(_):
            return APIConstant.like_dislike
            
        case .colorsList():
            return APIConstant.colorsList
            
        case .get_available_fm(_):
            return APIConstant.get_available_fm
            
        }
    }
    
    var method: Moya.Method {
        switch self {
            
        case .get_sponsor_list(_),.get_features(_),.get_modification_category(_),.get_car_feeds(_),.get_make_years(_),.colorsList(),.get_available_fm(_):
            return .get
     
        default:
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        
        switch self {
            
        default:
            
            return Task.requestParameters(parameters: parameters ?? [:], encoding: parameterEncoding)
            
        }
        
    }
    
    var headers: [String : String]? {
        
        switch self {
            
            
        default:
            
            let accessToken = /UserDefaultsManager.shared.loggedInUser?.accessToken
            return ["authorization":"know_moto " + accessToken]
        }
    }
    
    var authorizationType: AuthorizationType {
        return .bearer
    }
    
    
    //Custom Varaibles
    
    var parameters: [String: Any]? {
        
        switch self {
            
        case .get_features(let search,let limit,let skip,let isModification):
            
            return Parameters.get_features.map(values: [search,limit, skip, isModification])
            
            
        case .get_sponsor_list(let search,let limit,let skip):
            
            return Parameters.get_sponsor_list.map(values: [search,limit, skip])
            
        case .get_modification_category(let search,let limit,let skip):
            
            return Parameters.get_modification_category.map(values: [search,limit, skip])

        case .add_edit_car(let id,let name,let makeId ,let year ,let country ,let  nickName ,let beaconId ,let modificationType ,let image ,let featureId ,let sponsorId ,let sponsors ,let location,let features,let isLiveExpiry):
            
            return Parameters.add_edit_car.map(values: [id, name, makeId, year, country, nickName, beaconId, modificationType, image, featureId, sponsorId, sponsors, location,features,isLiveExpiry])
            
        case .get_car_feeds(let id,let userId,let loggedInUserId):
            
            return Parameters.get_car_feeds.map(values: [2,id,userId,loggedInUserId])
            
        case .get_make_years(let id):
            return Parameters.get_make_years.map(values: [id])
            
        case .followUnfollow(let id,let type):
            return Parameters.followUnfollow.map(values: [id,type])
            
        case .get_beacon_vehicles(let beaconIds,let limit,let skip):
            return Parameters.get_beacon_vehicles.map(values: [beaconIds,limit,skip])
            
        case .makeAlert(let id):
            return Parameters.makeAlert.map(values: [id])
            
        case .like_dislike(let id,let type):
            return Parameters.like_dislike.map(values: [id,type])
            
        case .colorsList():
            return Parameters.colorsList.map(values: [])
            
        case .get_available_fm(let search,let limit,let skip):
            return Parameters.get_available_fm.map(values: [search,limit, skip])
            
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
            
        default:
            return method == .get ? URLEncoding.queryString : JSONEncoding.default
        }
    }
}
