//
//  Car.swift
//  Knowmoto
//
//  Created by Apple on 05/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation



class CarBrandsModel:NSObject,Codable{
    
    var list:[BrandOrCarModel]?
    var modelList:[BrandOrCarModel]?
}

class YearPickerModel:NSObject,Codable{
    
    var list:[Int]?
}

class BrandOrCarModel:NSObject,Codable{
    
    var id:String?
    var name:String?
    var image:[ImageUrlModel]?
    var isSelected:Bool?
    var signedUrl:String?
    var arraySelectedModels:[BrandOrCarModel]?
    var year:Int?
    var type:Int?
    var parentId:String?
    var color:[String]?
    
    var makeId: BrandOrCarModel?
    var modelId:BrandOrCarModel?
    var subModel:SubModel?
    
    init(name:String?,id:String?,type:Int) {
        self.name = name
        self.id = id
        self.type = type
    }
    
    init(model:BrandOrCarModel) {
        self.name = model.name
        self.id = model.id
        self.type = model.type
    }
    
}



class ModificationType: NSObject,Codable {

    var modificationData:FeaturesListModel?
    var brandData:FeaturesListModel?
    var customBrandName:String?
    var modificationId, brandId, partNumber, part: String?
    
    override init() {
        
    }
  
}


class FeaturesModel:NSObject,Codable{
    
    var list:[FeaturesListModel]?
}

class FeaturesListModel:NSObject, Codable {
    
    var image:[ImageUrlModel]?
    var name:String?
    var feature: String?
    var id:String?
    var sponsors:[FeaturesListModel]?
    var category:String?
    var customBrandName:String?
    
    override init(){
        
    }
    
    init(feature:String?) {
        self.feature = feature
    }
    
    init(name:String?) {
        self.name = name
    }
    
    init(name:String?,image:ImageUrlModel) {
        self.name = name
        self.image = [image]
    }
}

struct CarList:Codable{
    
    var list:[CarListDataModel]?
}

// MARK: - List
class CarListDataModel:Codable {
    
    var id: String?
    var type: Int?
    var featureID: [FeaturesListModel]?
    var sponsorID: [FeaturesListModel]?
    var createdAt, year: Int?
    var image: [ImageUrlModel]?
    var nickName: String?
    var modificationType: [ModificationType]?
    var userID: UserData?
    var make: [BrandOrCarModel]?
    var model: [BrandOrCarModel]?
    var beaconID:[BeaconlistModel]?
    var subModel:[BrandOrCarModel]?
    var isFeaturedCar:Bool?
    var followedByMe:Bool?
    var totalLikes:Int?
    var totalFollowers:Int?
    var name:String?
    var location:LocationData?
    var liveExpiryTimeStamp:Double?
    var isLive: Bool?
    var likeByMe:Bool?
    var color:String?
    
    var displayAppName:String{
        
        let modelyear = /self.model?.first?.year?.toString
        let modelName = /self.model?.first?.name
        let makeName = /self.make?.first?.name
        let carNickName = /self.nickName
      return "\([modelyear,makeName,modelName].joined(separator: " ")) (\(carNickName))"
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type
        case featureID = "featureId"
        case sponsorID = "sponsorId"
        case isLive, createdAt, year, image, nickName, modificationType,likeByMe
        case userID = "userId"
        case make, model
        case beaconID = "beaconId"
        case subModel
        case followedByMe
        case totalFollowers
        case totalLikes
        case name
        case location
        case liveExpiryTimeStamp = "isLiveExpiry"
        case color
    }
    
    
    
    
}

// MARK: - Make
class Make: NSObject,Codable {
    
    var id: String?
    var type: Int?
    var name: String?
    var image: [ImageUrlModel]?
    var modelId:Model?

    init(id:String?,modelId:Model) {
        self.id = id
        self.modelId = modelId
    }
    override init() {
    }
}


// MARK: - Model
class Model:NSObject,Codable {
    
    var id:String?
    var name: String?
    var parentId: String?
    var type:Int?
    var year: Int?
    var image: [ImageUrlModel]?
    
    var subModel:SubModel?
    
    init(id:String?,submodel:SubModel?) {
        
        self.id = id
        self.subModel = submodel
    }
    
    override init() {
    }
}

class SubModel: NSObject,Codable {
    
    var id, color: String?
    var subModelName:String?
    
    init(color:String?,id:String?) {
        self.color = color
        self.id = id
    }
    
    override init() {
    }

}

//// MARK: - SponsorID
//struct SponsorID: Codable {
//
//    let id: String?
//    let isActive, isApproved: Bool?
//    let name: String?
//    let image: [ImageUrlModel]?
//
//}

struct LiveVehicleModal:Codable{
    
    var vehicleId:String?
    var location:[Double]?
    var distance:Double? //in meters
    var liveCars:[CarListDataModel]?
    var role:Int?
    
    init(vehicleId:String? = nil,location:[Double],distance:Double? = nil,role:Int? = nil) {
        
        self.role = role
        self.vehicleId = vehicleId
        self.location = location
        self.distance = distance
        
    }
    
    init() {
        self.liveCars = []
    }
    
    
}

struct NearbyVehicle:Codable{
    
    var vehicles:[CarListDataModel]?
    
}

struct ColorsData:Codable{
    
    var color:String?
    
}
