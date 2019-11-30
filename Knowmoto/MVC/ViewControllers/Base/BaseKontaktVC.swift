//
//  BaseKontaktVC.swift
//  Knowmoto
//
//  Created by Apple on 30/09/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit
import KontaktSDK

class BaseKontaktVC: BaseVC {
    
    //beacon
    var devicesManager: KTKDevicesManager!
    var bluetoothManager:CBCentralManager!
    
    var arrayDetectedBeacons:[String] = []
    
    deinit {
        devicesManager?.stopDevicesDiscovery()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        beaconSearchConfiguration()
    }
    
    //beacon search configure
    func beaconSearchConfiguration(){
        
        devicesManager = KTKDevicesManager(delegate: self)
        bluetoothManager = CBCentralManager()
        bluetoothManager.delegate = self
        
    }
    
    func checkBeaconAndStartDiscovering()->Bool{
        
        if bluetoothManager.state != .poweredOn{
            
            self.alertBoxOk(message: "Please on your bluetooth connection, need to detect your beacon is available.".localized, title: "Bluetooth powered off".localized) {
                
            }
            
            return false
        }else{
            
            devicesManager.startDevicesDiscovery(withInterval: 1.0)
            return true
        }
        
    }
    
    func searchBeaconOf(id:String,completion:@escaping (Bool)->()){
        
        self.startAnimateLoader(message: "Detecting beacon...".localized)
        
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
            
            self?.alertBoxOk(message: "No beacon was detected. Please make sure you are nearby your beacon and vehicle".localized, title: "Beacon Not Found".localized, ok: {})
            
            completion(false)
        })
        
    }
    
    func stopDeviceDiscovery(){
        
        devicesManager.stopDevicesDiscovery()
    }
    
}
//MARK:- Discover beacon and bluetooth delegates
extension BaseKontaktVC:KTKDevicesManagerDelegate,CBCentralManagerDelegate{
    
    
    func devicesManager(_ manager: KTKDevicesManager, didDiscover devices: [KTKNearbyDevice]) {
        
        
        arrayDetectedBeacons = devices.map({$0.uniqueID ?? ""})
        
        for device in devices {
            
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
            devicesManager.startDevicesDiscovery(withInterval: 1.0)
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
