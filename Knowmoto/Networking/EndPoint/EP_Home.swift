//
//  EP_Home.swift
//  Knowmoto
//
//  Created by Apple on 27/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation
import Moya


enum EP_Home {
    
    case get_home_feed(type:Int?,skip:Int?,limit:Int?,distance:Double?,location:Any?)
    case search(search:String?,id:String?,limit:Int?,skip:Int?,loggedInUserId:String?,type:Int?)
    case get_most_trending(type:Int?,limit:Int?,skip:Int?)
    
    case news(categories:Int?,per_page:Int)
    
}

extension EP_Home: TargetType, AccessTokenAuthorizable {
    
    var path: String {
        
        switch self {
            
        case .get_home_feed(_):
            return APIConstant.get_home_feed
            
        case .search(_):
            return APIConstant.search
            
        case .get_most_trending(_):
            return APIConstant.get_most_trending
            
        case .news(_):
            return APIConstant.news
    

        }
    }
    
    var method: Moya.Method {
        switch self {
            
        case .get_home_feed(_),.search(_),.get_most_trending(_),.news(_):
            return .get
            
        default:
            return .post
        }
    }
  
    //Custom Varaibles
    
    var parameters: [String: Any]? {
        
        switch self {
            
        case .get_home_feed(let type,let skip,let limit,let distance,let location):
            
            return Parameters.get_home_feed.map(values: [type,skip, limit,distance,location])
            
            
        case .search(let search ,let id ,let limit ,let skip,let loggedInUserId,let type):
            
            return Parameters.search.map(values: [search,id, limit,skip,loggedInUserId,type])
            
        case .get_most_trending(let type,let limit,let skip):
            
            return Parameters.get_most_trending.map(values: [type,limit, skip])
            
        case .news(let categories,let per_page):
            
            return Parameters.news.map(values: [categories,per_page])
            
        }
    }
    
}
extension EP_Home{
    
    var baseURL: URL {
        
        switch self {
            
        case .news(_):
            return URL(string: APIBasePath.basePath + APIBasePath.commonEndPoint)!
            
        default:
            return URL(string: APIBasePath.basePath + APIBasePath.userEndPoint)!
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
    
    var parameterEncoding: ParameterEncoding {
        switch self {
            
        default:
            return method == .get ? URLEncoding.queryString : JSONEncoding.default
        }
    }
}
