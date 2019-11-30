//
//  socket?Manager.swift
//  InTheNight
//
//  Created by OSX on 15/03/18.
//  Copyright © 2018 InTheNight. All rights reserved.
//

import UIKit
import SocketIO


enum SocketEventType : String {
    
    case update_car_location = "update_car_location"
    case nearby_cars = "nearby_cars"
    case acknowlege = "ackl"
    case guest_nearby_cars = "guest_nearby_cars"

}

class SocketAppManager {
    
    static let sharedManager = SocketAppManager()
    var manager: SocketManager!
    var socket: SocketIOClient!
    
    var blockNearbyCars:((Any)->())?
//    lazy var isNetworkAvailable : Bool = {
//        return
//    }()
    
    func initializeSocket() {
        
        guard let url = URL(string: APIBasePath.basePath ) else {
            return
        }
        
        let accessToken = UserDefaultsManager.shared.loggedInUser?.accessToken
        
        manager = SocketManager(socketURL: url, config: [.reconnects(true),.log(true),.compress,.connectParams(["token" : /accessToken])])

        socket = manager.defaultSocket
  
        addHandlers()
        
        socket.connect()
    }
    
    
    func addHandlers() {
        

        socket.onAny { (event) in
            
            debugPrint("socket.onAny")
            debugPrint(event.event)
//            debugPrint(event.items)
            debugPrint(self.socket.status)
        }
        
        socket?.on(clientEvent: .connect)  { (data, ack) in
            debugPrint("socket connected")
        }
        
        socket?.on(clientEvent: .error) {data, ack in
            debugPrint("socket error")
        }
        
        socket?.on(clientEvent: .reconnect) {data, ack in
            debugPrint("socket reconnecting")
        }
        
        socket?.on(clientEvent: .disconnect) {data, ack in
            print("socket disconnected")
            self.connect()
        }
        
        ack()
        
        listenNearByCars()
    
    }
    
    func connect() {
        
        if socket?.status == .connected {
            return
        }
        socket.disconnect()
        socket?.connect()
    }
    
    func disconnect() {

        socket?.emit("disconnect", [:])

        if socket?.status == .disconnected {
            return
        }

        socket?.disconnect()
    }
    
    
    //app used sockets
    
    func listenNearByCars(){
        
        let nearbyCars =  UserDefaultsManager.isGuestUser ? SocketEventType.guest_nearby_cars.rawValue : SocketEventType.nearby_cars.rawValue
        
        socket.on(nearbyCars) { [weak self] (event, socketEmitter) in
            
            let jsonOfVehicles = ((event.first as? [String:Any]))// as? [String:Any])?["list"]
            let nearbyVehicleData = JSONHelper<NearbyVehicle>().getCodableModel(data: jsonOfVehicles)
            
            self?.blockNearbyCars?(nearbyVehicleData)
            debugPrint(event)
            
        }
    }
    
    func nearbyCars(nearby:Any){
        
        if socket?.status != .connected {
            
            return
        }
        let nearbyCars =  UserDefaultsManager.isGuestUser ? SocketEventType.guest_nearby_cars.rawValue : SocketEventType.nearby_cars.rawValue
        socket.emit(nearbyCars, with: [nearby])
    }
    
    func ack() {
    
        socket.on(SocketEventType.acknowlege.rawValue) { (event, socketEmitter) in
            
            debugPrint(event)
            
        }
    }
    
    func updateLocation(vehicleLocation:Any){
        
        if socket?.status != .connected {
            
            return
        }
        
        socket.emit(SocketEventType.update_car_location.rawValue, with: [vehicleLocation])
        
    }
}

