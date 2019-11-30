//
//  KontaktBeaconHandleVC.swift
//  Knowmoto
//
//  Created by Apple on 10/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit
import KontaktSDK

class KontaktBeaconHandleVC: UIViewController {

    var devicesManager: KTKDevicesManager!
    var bluetoothManager:CBCentralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        devicesManager = KTKDevicesManager(delegate: self)
        bluetoothManager = CBCentralManager()
        bluetoothManager.delegate = self
        
        if devicesManager.centralState == bluetoothManager.state {
            devicesManager.startDevicesDiscovery(withInterval: 1.0)
            //  devicesManager.startDevicesDiscovery()
        }
        // Do any additional setup after loading the view.
    }
    

}

extension KontaktBeaconHandleVC:KTKDevicesManagerDelegate,CBCentralManagerDelegate{
    
    
    func devicesManager(_ manager: KTKDevicesManager, didDiscover devices: [KTKNearbyDevice]) {
        
     
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
            print("Bluetooth is on")
            break
        case .poweredOff:
            print("Bluetooth is Off.")
            break
        case .resetting:
            break
        case .unauthorized:
            print("Bluetooth is on")
            break
        case .unsupported:
            print("Bluetooth is on")
            break
        case .unknown:
            print("Bluetooth is on")
            break
        default:
            break
        }
    }
    
}
