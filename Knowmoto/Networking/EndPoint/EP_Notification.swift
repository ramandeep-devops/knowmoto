//
//  EP_Notification.swift
//  Knowmoto
//
//  Created by Apple on 16/09/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation
import Moya


enum EP_Notification {
    
    case get_notifications(id:String?,limit:Int?,skip:Int?)
    
    case approve_tag_request(id:String?,isApproved:Int?)
    case get_unread_notification_count()

}

extension EP_Notification: TargetType, AccessTokenAuthorizable {
    
    var baseURL: URL {
        
        switch self {
            
        default:
            return URL(string: APIBasePath.basePath + APIBasePath.userEndPoint)!
        }
    }
    
    var path: String {
        
        switch self {
            
        case .get_notifications(_):
            return APIConstant.get_notifications
            
        case .approve_tag_request(_):
            return APIConstant.approve_tag_request
            
        case .get_unread_notification_count(_):
            return APIConstant.get_unread_notification_count
            
        }
    }
    
    var method: Moya.Method {
        switch self {
            
            
        case .get_notifications(_),.get_unread_notification_count():
            return .get
            
        case .approve_tag_request(_):
            return .put
            
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
            
        case .get_notifications(let id,let limit,let skip):
            
            return Parameters.get_notifications.map(values: [id, limit, skip])
            
        case .approve_tag_request(let id,let isApproved):
            
            return Parameters.approve_tag_request.map(values: [id,isApproved])
            
        case .get_unread_notification_count():
            
            return Parameters.get_unread_notification_count.map(values: [])

        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
            
        default:
            return method == .get ? URLEncoding.queryString : JSONEncoding.default
        }
    }
}
