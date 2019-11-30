//
//  KontaktBeaconDataSource.swift
//  Knowmoto
//
//  Created by Apple on 04/10/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation
import KontaktSDK

class KontaktBeaconDataSource:NSObject{
    
    var devicesManager: KTKDevicesManager!
    var bluetoothManager:CBCentralManager!
    
    var arrayDetectedBeacons:[String] = []
    
    static let shared = KontaktBeaconDataSource()
    
    var blockBatteryStatus:[String:((UInt)->(Bool))] = [:]
    
    override init() {
        super.init()
        
        self.beaconSearchConfiguration()
    }
    
    deinit {
        
        devicesManager?.stopDevicesDiscovery()
        
    }
    
    //beacon search configure
    func beaconSearchConfiguration(){
        
        devicesManager = KTKDevicesManager(delegate: self)
        bluetoothManager = CBCentralManager()
        bluetoothManager.delegate = self
        
    }
    
    func checkBeaconAndStartDiscovering(alertMessage:String = "Please on your bluetooth connection, need to detect kontakt beacon is in range".localized)->Bool{
        
        if bluetoothManager.state != .poweredOn{
            
            self.alertBoxOk(message: alertMessage, title: "Bluetooth powered off".localized) {
                
            }
            
            return false
            
        }else{
            
            devicesManager.startDevicesDiscovery(withInterval: 1.0)
            return true
        }
        
    }
    
    func getBatteryStatusOfId(OfId:String,completion:@escaping (UInt)->(Bool)){
        
        devicesManager.startDevicesDiscovery(withInterval: 1.0)
        blockBatteryStatus[OfId] = completion
    }
    
    
    func searchBeaconOf(loaderMessage:String = "Detecting beacon...",alertTitle:String = "Not Found!",alertMessage:String = "No kontakt beacon detected, be sure beacon should be in range of your device".localized,id:String,completion:@escaping (Bool)->()){
        
        self.startAnimateLoader(message: loaderMessage.localized)
        
        let timer1:Timer? //for searching
        var timer2:Timer = Timer() //for search time interval
        
        //to searching after every 1 sec till not found
        timer1 = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
            
            debugPrint(self?.arrayDetectedBeacons)
            
            if self?.arrayDetectedBeacons.contains(id) ?? false{
                
                self?.stopAnimateLoader()
                self?.stopDeviceDiscovery()
                
                timer.invalidate()
                timer2.invalidate()
                completion(true)
                
            }
            
        }
        
        //to stop search after 10 seconds
        timer2 = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { [weak self] (_) in
            
            timer1?.invalidate()
            self?.stopAnimateLoader()
            self?.stopDeviceDiscovery()
            
            self?.alertBoxOk(message: alertMessage, title: alertTitle.localized, ok: {})
            
            completion(false)
        })
        
    }
    
    func stopDeviceDiscovery(){
        
        devicesManager.stopDevicesDiscovery()
    }
    
}

//MARK:- Discover beacon and bluetooth delegates
extension KontaktBeaconDataSource:KTKDevicesManagerDelegate,CBCentralManagerDelegate{
    
    
    func devicesManager(_ manager: KTKDevicesManager, didDiscover devices: [KTKNearbyDevice]) {
        
        
        arrayDetectedBeacons = devices.map({$0.uniqueID ?? ""})
        
        
        
        for device in devices {
        
            let isDone = blockBatteryStatus[/device.uniqueID]?(device.batteryLevel)
            if /isDone{
                
                stopDeviceDiscovery()
            }
            
            if let uniqueId = device.uniqueID {
                
                print("Detected a beacon \(uniqueId)")
                
            } else {
                
                print("Detected a beacon with an unknown Unique ID")
                
            }
            
        }
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .poweredOn:
            print("Bluetooth is on")
            break
        case .poweredOff:
            devicesManager.stopDevicesDiscovery()
            print("Bluetooth is Off.")
            break
        case .resetting:
            devicesManager.stopDevicesDiscovery()
            break
        case .unauthorized:
            devicesManager.stopDevicesDiscovery()
            print("Bluetooth is on")
            break
        case .unsupported:
            devicesManager.stopDevicesDiscovery()
            print("Bluetooth is on")
            break
        case .unknown:
            devicesManager.stopDevicesDiscovery()
            print("Bluetooth is on")
            break
        default:
            break
        }
    }
    
    
}
