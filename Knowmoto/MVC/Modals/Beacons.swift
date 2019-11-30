//
//  BeaconModel.swift
//  Knowmoto
//
//  Created by cbl16 on 18/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation


class BeaconsModel:NSObject,Codable{
    
    var list:[BeaconlistModel]?
    var countOfTotalDoc:Int?
    
}

class BeaconlistModel:NSObject,Codable{
    
    var userId:String?
    var beaconCompany:String?
    var id:String?
    var beaconId:String?
    var vehicle:CarListDataModel?
  
    init(beaconId:String,beaconCompany:String) {
        
        self.beaconId = beaconId
        self.beaconCompany =  beaconCompany
        
    }
    
}
