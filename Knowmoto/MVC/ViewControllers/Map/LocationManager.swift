//
//  LocationManager.swift
//  Knowmoto
//
//  Created by Apple on 24/09/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager:NSObject{
    
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    var currentLocation:CLLocation?
    var blockPermissionGranted:((Bool)->())?
    
    func configureCLLocation(){
        
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
    }
    
    func checkPermission(completion:((Bool)->())?){
        
        CheckPermission.shared.permission(For: .locationAlwaysInUse) { [weak self] (permission) in
            
            if !permission{
                
                self?.openAlertForSettings(for: .locationAlwaysInUse)
                completion?(false)
            }else{
                
                completion?(true)
            }
            
        }
        
    }
    
    
    
    func askPermission(blockPermissionGranted:((Bool)->())?){
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        self.blockPermissionGranted = blockPermissionGranted
    }
    
    func startUpdateLocation(){
        
        
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation(){
        
        locationManager.stopUpdatingLocation()
        
    }
    
}

extension LocationManager:CLLocationManagerDelegate{
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        blockPermissionGranted?(true)
        
        guard let location = locations.first else {
            return
        }
        
        self.currentLocation = location
        //check any car is live
//        if UserDefaultsManager.shared.isLive{
//            
//            locationManager.distanceFilter = 1 // 1 metre notified period
//            self.updateMyLiveCarLocation(location: location)
//            
//        }
    
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
 
        blockPermissionGranted?(false)
        
    }
    
    
    //When you are live update location by socket
    func updateMyLiveCarLocation(location:CLLocation){
        
//        let liveVehicle = UserDefaultsManager.shared.liveCar
//
//        let json = JSONHelper<LiveVehicleModal>().toDictionary2(model: LiveVehicleModal(vehicleId: liveVehicle?.id, location: [location.coordinate.longitude,location.coordinate.latitude]))
//
//        SocketAppManager.sharedManager.updateLocation(vehicleLocation: json)
    }
    
    
    func reverseGeocode(){
        
        MapBoxGeocodingCustom.reverseGeocode(allowedScoped:[.all], lat: /self.locationManager.location?.coordinate.latitude, long: /self.locationManager.location?.coordinate.longitude, address: { (placeMarker) in
        
            let locationAddress = self.getLocationAddressObject(data: placeMarker)
            
            if UserDefaultsManager.shared.location == nil{
                 UserDefaultsManager.shared.location = SavedLocations()
            }
            
            UserDefaultsManager.shared.location?.selectedLocation = locationAddress
            
        })
        
    }
    
    
}
