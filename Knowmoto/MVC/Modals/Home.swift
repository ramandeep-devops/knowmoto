//
//  Home.swift
//  Knowmoto
//
//  Created by Apple on 27/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation

class HomeDataList:NSObject,Codable{
    
    var totalLiveCars:Int?
    var recent:[CarListDataModel]?
    var featured:[CarListDataModel]?
}

enum ENUM_MAIN_SEARCH_TYPE:Int{
    
    case make = 1
    case model = 2
    case color = 3
    case feature = 4
    case vehicle = 5
    case sponsors = 6
    case user = 7
    
    func getTitleSubtitle(_ of:SearchDataModel)->(String,String){
        
        switch self{
            
        case .color:
            
            return ("in Colors",/of.color?.first)
            
        case .feature:
            
            return ("in Tags",/of.feature)
            
        case .make:
            
            return ("in Makes",/of.name)
            
        case .model:
            
            return ("in Models",/of.name)
            
        case .vehicle:
            
            return ("in Vehicles",/of.displayVehicleName)
            
        case .sponsors:
            
            return ("in Sponsors",/of.name)
            
        case .user:
            
            return ("",/of.name)
            
        }
 
    }
    
    var placeHolder:String{
    
        switch self {
            
        case .color:
            return "Search color.."
        case .feature:
            return "Search feature.."
        case .sponsors:
            return "Search sponsor.."
            
        case .vehicle:
            return "Search vehicle.."
            
        default:
            return "Search make, model, color or a tag"
            
        }
    
    }
    
}

struct SearchModal:Codable{
    
    let alertByMe:Bool?
    let totalPosts:Int?
    let list:[SearchDataModel]?
    
}

class SearchDataModel:Codable{
    
    var modelName:String?
    var modelYear:Int?
    var nickName:String?
    var makeName:String?
    var color:[String]?
    var name:String?
    var parentId:String?
    var id:String?
    var feature:String?
    var type:Int?
    var image:[ImageUrlModel]?
    var alertByMe:Bool?
    var tagName:String?{
        return (type == 1 || type == 2 || type == 6) ? name : type == 3 ? /color?.first : type == 4 ? /feature : /nickName
    }
    var displayVehicleName:String{
        return "\([/modelYear?.toString,/makeName,/modelName].joined(separator: " ")) (\(/nickName))"
    }
    
    init(data:CarListDataModel,type:Int = 1) { //by default type make
        
        self.name = data.name
        self.id = data.id
        self.type = type
        self.image = data.image
        
    }
    
    init(data:UserData?,type:Int = 7){
        
        self.id = data?.userId
        self.type = type
        
    }
    
    

}

struct TrendingData:Codable{
    
    let mostLikedCars:[CarListDataModel]?
    let mostTrendingMake:[CarListDataModel]?

}

//class News:Codable{
//    
//    var data:[NewsData]?
//    
//}
//
//class NewsData:Codable{
//    
//    var title:NewsInternalData?
//    var excerpt:NewsInternalData?
//    var date:String?
//    var _embedded:[Media]?
//    
//}
//
//class NewsInternalData:Codable {
//    
//    var rendered:String?
//    
//    enum CodingKeys:String,CodingKey{
//        
//        case rendered = "rendered"
//    }
//    
//}
//
//class Media:Codable {
//  
//    var featureMedia:[FeatureMedia]?
//    
//    enum CodingKeys:String,CodingKey{
//
//        case featureMedia = "wp:featuredmedia"
//    }
//    
//}
//
//class FeatureMedia:Codable {
//    
//    var media_details:MediaDetails?
// 
//}
//
//class MediaDetails:Codable {
//    
//    var sizes:Sizes?
//
//}
//
//class Sizes:Codable {
//    
//    var medium:SizeType?
//    
//}
//
//class SizeType:Codable {
//    
//    var source_url:String?
//    
//}
