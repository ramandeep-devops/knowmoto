//
//  LoginEP.swift
//  AE
//
//  Created by MAC_MINI_6 on 16/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation
import Moya

enum EP_Login {
    
    case loginAndNumberVerification(model:LoginSignupViewModal?)
    case getOtp(model:LoginSignupViewModal?)
    case signUp(model:LoginSignupViewModal?)
    case getImageSignedUrl(file_name:String?)
    case signIn(model:LoginSignupViewModal?)
    
}

extension EP_Login: TargetType, AccessTokenAuthorizable {
    
    var baseURL: URL {
        
        switch self {
        case .getImageSignedUrl(_):
            return URL(string: APIBasePath.basePath + APIBasePath.commonEndPoint)!
        default:
            return URL(string: APIBasePath.basePath + APIBasePath.userEndPoint)!
        }
        
    }
    
    var path: String {
        
        switch self {
            
        case .getImageSignedUrl(_):
            return APIConstant.getImageSignedUrl
            
        case .loginAndNumberVerification(_):
            return APIConstant.loginAndNumberVerification
            
        case .signIn(_),.getOtp(_):
            return APIConstant.signIn
            
            
        case .signUp(_):
            return APIConstant.signup
        }
    }
    
    var method: Moya.Method {
        switch self {
           
        case .getImageSignedUrl(_):
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
            
        case .loginAndNumberVerification(let model):
            
            return Parameters.loginAndNumberVerification.map(values: [model?.ccc, model?.phone, model?.otp, model?.type])
            
        case .signIn(let model):
            
            return Parameters.signIn.map(values: [model?.ccc, model?.phone, "2", model?.otp, model?.type, "12345678"])
            
        case .getOtp(let model):
            
            return Parameters.signIn.map(values: [model?.ccc, model?.phone, "2", nil, nil, "12345678"])
            
        case .signUp(let model):
            
            return Parameters.signup.map(values: [model?.userId, model?.ccc, model?.phone,model?.name,model?.email,model?.city,model?.location,model?.zipcode,"12345678","2",model?.image,model?.userName])
            
        case .getImageSignedUrl(let file_name):
            
            return Parameters.getImageSignedUrl.map(values: [5,file_name])
            
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
            
        default:
            return method == .get ? URLEncoding.queryString : JSONEncoding.default
        }
    }
}

extension Array{
    
    func toJsonString() -> String? {
        
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
        
    }
}
