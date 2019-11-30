//
//  Profile.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/21/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation

struct AssociatedOrBookMarkCarsModel:Codable{
    
    let myCars:[CarListDataModel]?
    let likedCars:[CarListDataModel]?
    let followedCars:[CarListDataModel]?
    let alertList:[CarListDataModel]?
    
}
