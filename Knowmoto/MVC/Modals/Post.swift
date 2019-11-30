//
//  Post.swift
//  Knowmoto
//
//  Created by Apple on 12/09/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation

struct PostList: Codable {
    
    let id, title: String?
    let image: [ImageUrlModel]?
    let location: LocationData?
    let place: String?
    let vehicleID: CarListDataModel?
    let user: UserData?
    var reportedBy:Bool?
    let createdAt:Double?
    var taggedId:String?
    
    
    enum CodingKeys: String, CodingKey {
        case id, title, image, location, place
        case vehicleID = "vehicleId"
        case user
        case createdAt
        case reportedBy
        case taggedId
    }
}
