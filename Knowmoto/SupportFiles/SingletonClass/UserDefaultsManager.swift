//
//  UserDefaultsManager.swift
//  InTheNight
//
//  Created by OSX on 19/02/18.
//  Copyright © 2018 InTheNight. All rights reserved.
//

import UIKit
import CoreLocation

struct UserdefaultKeys {
    
    
    static let user = "user"
    static let walkthroughDone = "WalkthroughDone"
    static let savedLocations = "savedLocations"
    static let liveCar = "liveCar"
    
}


class UserDefaultsManager: NSObject {
    
    
    static let shared = UserDefaultsManager()
    
    var addCarViewModel:AddEditCarViewModel?
    
    var loggedInUser : UserData? {
        
        get{
            
            guard let data = UserDefaults.standard.value(forKey: UserdefaultKeys.user) else{
                
                let mappedModel = JSONHelper<UserData>().getCodableModel(data: ["":""])
                return mappedModel
            }
            
            let mappedModel = JSONHelper<UserData>().getCodableModel(data: data as! [String:Any])
            return mappedModel
            
        }set{
            
            if let value = newValue {
                
                if let jsonModal = JSONHelper<UserData>().toDictionary2(model: value){
                    
                    UserDefaults.standard.set(jsonModal, forKey: UserdefaultKeys.user)
                    UserDefaults.standard.synchronize()
                }
                
            } else {
                UserDefaults.standard.removeObject(forKey: UserdefaultKeys.user)
            }
        }
    }

    
    var location : SavedLocations? {
        
        get{
            
            guard let data = UserDefaults.standard.value(forKey: UserdefaultKeys.savedLocations) else{
                
                let mappedModel = JSONHelper<SavedLocations>().getCodableModel(data: ["":""])
                return mappedModel
            }
            
            let mappedModel = JSONHelper<SavedLocations>().getCodableModel(data: data as! [String:Any])
            return mappedModel
            
        }set{
            
            if let value = newValue {
                
                if let jsonModal = JSONHelper<SavedLocations>().toDictionary2(model: value){
                    
                    UserDefaults.standard.set(jsonModal, forKey: UserdefaultKeys.savedLocations)
                    UserDefaults.standard.synchronize()
                }
                
            } else {
                UserDefaults.standard.removeObject(forKey: UserdefaultKeys.savedLocations)
            }
        }
    }
    
    var isWalkthroughDone:Bool{
        
        get{
            
            let isDone = UserDefaults.standard.value(forKey: UserdefaultKeys.walkthroughDone) as? Bool
            return isDone ?? false
            
        }set{
            
            UserDefaults.standard.set(newValue, forKey: UserdefaultKeys.walkthroughDone)
        }
    }
    
   static var isGuestUser:Bool{
        get{
            return UserDefaultsManager.shared.loggedInUser?.accessToken == nil
        }
    }
    
    var liveCar:LiveVehicleModal?{
        get{
            
            guard let data = UserDefaults.standard.value(forKey: UserdefaultKeys.liveCar) else{
                
                let mappedModel = JSONHelper<LiveVehicleModal>().getCodableModel(data: ["":""])
                return mappedModel
            }
            
            let mappedModel = JSONHelper<LiveVehicleModal>().getCodableModel(data: data as! [String:Any])
            return mappedModel
            
        }set{
            
            if let value = newValue {
                
                if let jsonModal = JSONHelper<LiveVehicleModal>().toDictionary2(model: value){
                    
                    UserDefaults.standard.set(jsonModal, forKey: UserdefaultKeys.liveCar)
                    UserDefaults.standard.synchronize()
                }
                
            } else {
                UserDefaults.standard.removeObject(forKey: UserdefaultKeys.liveCar)
            }
        }
    }
    
   class func clearData() {

    UserDefaultsManager.shared.liveCar = nil
    UserDefaultsManager.shared.loggedInUser = nil
    
    SocketAppManager.sharedManager.disconnect()
    SocketAppManager.sharedManager.initializeSocket()

    UserDefaults.standard.removeObject(forKey: UserdefaultKeys.user)
    UserDefaults.standard.synchronize()
        
    }
    
    var currentUserId:String{
        return /UserDefaultsManager.shared.loggedInUser?.id
    }
    
    var isLive:Bool{
        return !(/self.liveCar?.liveCars?.isEmpty) && self.liveCar?.liveCars != nil
    }
    
}





