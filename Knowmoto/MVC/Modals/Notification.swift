//
//  Notification.swift
//  Knowmoto
//
//  Created by Apple on 16/09/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation

// MARK: - Welcome

enum ENUM_NOTIFICATION_TYPE:Int{
    
    case nearBy3Km = 1
    case taggedCar
    case followed
    case liked
    case live
}

class NotificationData: Codable {
    
    let countOfTotalDoc:Int?
    let id: String?
    let isRead: Bool?
    let message: String?
    var type: Int?
    let notificationFrom: UserData?
    let postId:PostList?
    let vehicleId:CarListDataModel?
    let createdAt:Double?
    var taggedId:TaggedId?
}

struct PushNotificationData: Codable {

    let id: String?
    let isRead: Bool?
    let message: String?
    var type: Int?
    let notificationFrom: String?
    let postId:String?
    let vehicleId:String?
    let createdAt:Double?
    var taggedId:String?
}


struct TaggedId: Codable {
    
    let id: String?
    var isApproved: Int?
}


