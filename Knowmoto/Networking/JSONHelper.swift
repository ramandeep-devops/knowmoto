//
//  JSONHelper.swift
//  AE
//
//  Created by MAC_MINI_6 on 17/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//
//30.7227417,76.8003641,
import Foundation

class JSONHelper<T: Codable> {
  
  init() {
    
  }
  
  /* MARK:- Convert any Data to Specific model
  Use case: Used for api responses to map into models */
  func getCodableModel(data: Data) -> T? {
    let model = try? JSONDecoder().decode(T.self, from: data)
    return model
  }
  
  /* MARK:- Convert Any type (which could be dictionary or NSArray or NSDictionary)
   Use case: Used for notification response and socket response to map into models */
    func getCodableModel(data: Any) -> T? {
    
    guard let objData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) else {
      return nil
    }
    return getCodableModel(data: objData)
    
  }
  
  /* MARK:- Convert models to Data
   Use case: Used to save data object in Userdefaults */
  func getData(model: T) -> Data? {
    guard let data: Data = try? JSONEncoder().encode(model) else {
      return nil
    }
    return data
  }
  
  /* MARK:- Convert model to dictionary */
  func toDictionary(model: T) -> [Any]? {
    var dictToReturn: [Any]?
    do {
      guard let data = getData(model: model) else {
        throw NSError(domain: "Can't convert model to data", code: 1, userInfo: nil)
      }
      guard let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [Any] else {
          throw NSError(domain: "Can't convert data into dictionary", code: 2, userInfo: nil)
      }
      dictToReturn = dict
    } catch {
      debugPrint(error.localizedDescription)
    }
    return dictToReturn
  }
    
    func toDictionary2(model: T) -> [String:Any]? {
        var dictToReturn: [String:Any]?
        do {
            guard let data = getData(model: model) else {
                throw NSError(domain: "Can't convert model to data", code: 1, userInfo: nil)
            }
            guard let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] else {
                throw NSError(domain: "Can't convert data into dictionary", code: 2, userInfo: nil)
            }
            dictToReturn = dict
        } catch {
            debugPrint(error.localizedDescription)
        }
        return dictToReturn
    }
  
  /* MARK:- Convert model to JSON String
   Use case: To send input to backend api's as objects input */
  func toJSONString(model: T) -> String? {
    var json: String?
    do {
      guard let data = getData(model: model) else {
        throw NSError(domain: "Can't convert model to data", code: 1, userInfo: nil)
      }
      json = String(data: data, encoding: String.Encoding.utf8)
    } catch {
      debugPrint(error.localizedDescription)
    }
    return json
  }
}
