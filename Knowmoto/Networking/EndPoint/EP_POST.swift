//
//  EP_POST.swift
//  Knowmoto
//
//  Created by Apple on 05/09/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation
import Moya


enum EP_Post {
    
    case add_edit_post(id:String?,title:String?,location:Any?,place:String?,image:Any?,vehicleId:String?)
    case get_post_data(id:String?,type:Int?,userId:String?,search:String?,limit:Int?,skip:Int?,vehicleId:String?,loggedInUserId:String?,makeId:String?)
    case report(id:String?,type:Int?)
    case get_main_search_data(search:String?,id:String?,type:Int?,limit:Int?,skip:Int?,loggedInUserId:String?)
    
}

extension EP_Post: TargetType, AccessTokenAuthorizable {
    
    var baseURL: URL {
        
        switch self {
            
        default:
            return URL(string: APIBasePath.basePath + APIBasePath.userEndPoint)!
        }
    }
    
    var path: String {
        
        switch self {
            
        case .add_edit_post(_):
            return APIConstant.add_edit_post
            
        case .get_post_data(_):
            return APIConstant.get_post_data
            
        case .report(_):
            return APIConstant.report
            
        case .get_main_search_data(_):
            return APIConstant.get_main_search_data
            
        }
    }
    
    var method: Moya.Method {
        switch self {
            
            
        case .get_post_data(_),.get_main_search_data(_):
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
            
        case .add_edit_post(let id,let title,let location,let place,let image,let vehicleId):
            
            return Parameters.add_edit_post.map(values: [id, title, location, place, image, vehicleId])
            
        case .get_post_data(let id,let type,let userId,let search,let limit,let skip,let vehicleId,let loggedInUserId,let makeId):
            
            return Parameters.get_post_data.map(values: [id,type, userId, search, limit,skip,vehicleId,loggedInUserId,makeId])
            
        case .report(let id,let type):
            
            return Parameters.report.map(values: [id,type])
            
            
        case .get_main_search_data(let search,let id,let type,let limit,let skip,let loggedInUserId):
            
            return Parameters.get_main_search_data.map(values: [search,id,type,limit,skip,loggedInUserId])
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
            
        default:
            return method == .get ? URLEncoding.queryString : JSONEncoding.default
        }
    }
}
