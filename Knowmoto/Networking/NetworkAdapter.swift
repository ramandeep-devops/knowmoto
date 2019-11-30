//
//  NetworkAdapter.swift
//  AE
//
//  Created by MAC_MINI_6 on 16/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation
import Moya

private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data // fallback to original data if it can't be serialized.
    }
}

extension TargetType {
    
    func provider<T: TargetType>() -> MoyaProvider<T> {
        
        let provider = MoyaProvider<T>(plugins: [(NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter))])
        provider.manager.session.configuration.timeoutIntervalForRequest = TimeInterval(1)
        return provider
        
    }
    
    func request(loaderMessage:String = "",loaderNeeded:Bool = true,successMessage:String? = nil,success successCallBack: @escaping (Any?) -> Void, error errorCallBack: ((String?) -> Void)? = nil) {
        
        if loaderNeeded{
            handleLoader(loaderMessage)
        }
        
        provider().request(self) { (result) in
            
            //Hide Loader after getting response
            UIApplication.shared.endIgnoringInteractionEvents()
            UIApplication.getTopViewController()?.stopAnimateLoader()
            
            switch result {
                
            case .success(let response):
                
                switch response.statusCode {
                    
                case 200, 201:
                    
                    let model = self.parseModel(data: response.data)
                    successCallBack(model)
                    
                    
                case 401:
          
                    do {
                        let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String : Any]
                        Toast.show(text: /(json?["message"] as? String), type: .error)
                        errorCallBack?(/(json?["message"] as? String))
                    } catch {
                        Toast.show(text: error.localizedDescription, type: .error)
                    }
                    
                    logout()
                    
                case 400, 409, 500:
                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String : Any]
                        Toast.show(text: /(json?["message"] as? String), type: .error)
                        errorCallBack?(/(json?["message"] as? String))
                    } catch {
                        Toast.show(text: error.localizedDescription, type: .error)
                    }
                    
                default:break
                    
                    //            Toast.show(text: "Server error", type: .error)
                    //          errorCallBack?(error.localizedDescription)
                }
            case .failure(let error):
                
                Toast.show(text: error.localizedDescription, type: .error)
                
                errorCallBack?(error.localizedDescription)
            }
        }
    }
    
    func handleLoader(_ message:String) {
        
        switch self {
            
        case is EP_Login:
            
            let endPoint = self as! EP_Login
            switch endPoint {
                
            case .getImageSignedUrl(_):
                break
                
            default:
                UIApplication.shared.beginIgnoringInteractionEvents()
                UIApplication.getTopViewController()?.startAnimateLoader(message: message, color: UIColor.white)
            }
        default:
            
            UIApplication.shared.beginIgnoringInteractionEvents()
            UIApplication.getTopViewController()?.startAnimateLoader(message: message, color: UIColor.white)
            
        }
    }
}

func logout(){
    
    UserDefaultsManager.clearData()
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    appdelegate.reInstantiateWindow()
    
}
