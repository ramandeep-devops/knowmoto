
//  EP_Profile.swift
//  Knowmoto

//  Created by Apple on 05/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.


import Foundation

import Moya

enum EP_Profile {
    
    case get_make_model_list(search:String?, id:String?,parentId:String?,type:Int?, limit:Int?,skip:Int?,year:Int?,idsToSort:Any?)
    case updateProfile(model:LoginSignupViewModal?)
    case logout()
    case get_beacons(search:String?, id:String?,beaconId:String?,userId:String?,isActive:Bool?, limit:Int?,skip:Int?)
    case add_beacons( id:String?,beaconId:String?,beaconCompany:String?,userId:String?,isActive:Bool?)
    case remove_beacon(id:String?)
    case link_with_vehicle(id:String?,vehicleId:String?,type:Int?)
    case get_user_associated_cars(type:Int?,search:String?,limit:Int?,skip:Int?,userId:String?,loggedInUserId:String?)
    case delete(id:String?,type:Int?)
    case get_model_listing(parentId:String?,limit:Int?,skip:Int?,search:String?,idsToSort:Any?)
    case user_profile(userId:String?)
    case update_device_token(deviceToken:String?)
}

extension EP_Profile: TargetType, AccessTokenAuthorizable {
    
    var baseURL: URL {
        
        switch self {
            
        default:
            return URL(string: APIBasePath.basePath + APIBasePath.userEndPoint)!
        }
    }
    
    var path: String {
        
        switch self {
            
        case .get_make_model_list(_):
            return APIConstant.get_make_model_list
            
        case .updateProfile(_):
            return APIConstant.updateProfile
            
        case .logout():
            return APIConstant.logout
            
        case .get_beacons(_):
            return APIConstant.get_beacons
            
            
        case .add_beacons(_):
            return APIConstant.add_edit_beacon
            
        case .remove_beacon(_):
            return APIConstant.remove_beacon
            
        case .link_with_vehicle(_):
            return APIConstant.link_with_vehicle
            
        case .get_user_associated_cars(_):
            return APIConstant.get_user_associated_cars
            
        case .delete(_):
            return APIConstant.delete
            
        case .get_model_listing(_):
            return APIConstant.get_model_listing
            
        case .user_profile(_):
            return APIConstant.user_profile
            
        case .update_device_token(_):
            return APIConstant.update_device_token
            
        }
    }
    
    var method: Moya.Method {
        switch self {
            
        case .get_make_model_list(_),.get_beacons(_),.get_user_associated_cars(_),.get_model_listing(_),.user_profile(_):
            return .get
            
        case .updateProfile(_),.logout(),.link_with_vehicle(_),.update_device_token(_):
            return .put
            
        case .remove_beacon(_),.delete(_):
            return .delete
            
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
            
        case .get_make_model_list(let search,let id,let parentId,let type,let limit,let skip,let year,let idsToSort):
            
            return Parameters.get_make_model_list.map(values: [search, id, parentId, type, limit, skip,year,idsToSort])
            
        case .updateProfile(let model):
            
            return Parameters.updateProfile.map(values: [model?.interestedMakes,model?.ccc,model?.phone,model?.name,model?.email,model?.city,model?.location,model?.zipcode,model?.image,model?.userName,model?.filter])
            
        case .logout():
            
            return Parameters.logout.map(values: [])
            
        case .get_beacons( let search,let id,let beaconId ,let userId ,let isActive,let limit ,let skip):
            
            return Parameters.get_beacons.map(values: [search,id,beaconId,userId,isActive,limit,skip])
            
        case .add_beacons(let id, let beaconId, let beaconCompany, let userId,let isActive):
            
            return Parameters.add_edit_beacon.map(values: [id,beaconId,beaconCompany,userId,isActive])
            
        case .remove_beacon(let id):
            
            return Parameters.remove_beacon.map(values: [id])
            
            
        case .link_with_vehicle(let id ,let vehicleId,let type):
            
            return Parameters.link_with_vehicle.map(values: [id ,vehicleId, type])
            
        case .get_user_associated_cars(let type,let search,let limit,let skip,let userId,let loggedInUserId):
            
            return Parameters.get_user_associated_cars.map(values: [type ,search, limit,skip,userId,loggedInUserId])
            
            
        case .delete(let id,let type):
            
            return Parameters.delete.map(values: [id,type])
            
            
        case .get_model_listing(let parentId,let limit,let skip,let search,let idsToSort):
            return Parameters.get_model_listing.map(values: [parentId,limit,skip,search,idsToSort])
            
        case .user_profile(let userId):
            return Parameters.user_profile.map(values: [userId])
            
        case .update_device_token(let deviceToken):
            return Parameters.update_device_token.map(values: [deviceToken])
            
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
            
        default:
            return method == .get ? URLEncoding.queryString : JSONEncoding.default
        }
    }
}
