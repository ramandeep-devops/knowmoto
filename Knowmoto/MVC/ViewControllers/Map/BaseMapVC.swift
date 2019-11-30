//
//  BaseMapVC.swift
//  Knowmoto
//
//  Created by Apple on 04/10/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit
import Mapbox

class BaseMapVC: BaseVC {
    
    @IBOutlet weak var btnCurrentLocation: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    var mapView:MGLMapView! = nil
    var delegate:MBMapVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func setupMapView(){
        
        //add mapview to subview
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(mapView)
        
        //        //back button on top
        //        if isFromMyLive{
        //            self.containerView.bringSubviewToFront(stackViewTimerLabels)
        //        }
        self.containerView.bringSubviewToFront(self.btnCurrentLocation)
        //        self.view.bringSubviewToFront(self.btnBack)
        //        self.view.bringSubviewToFront(self.btnEndLive)
        
        //delegate
        //        mapView.delegate = self
        
        //MARK:- mapview configuration
        mapView.styleURL = mapStyleUrl

        
        //remove mapbox (logo,compass,info)
        mapView.compassView.isHidden = true
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        
        //show user location
        mapView.showsUserLocation = true
        
    }
    
    //current location action
    @IBAction func didTapCurrentLocation(_ sender: UIButton) {
        
        moveCameraToCurrentLocation()
        
    }
    
    func moveCameraToCurrentLocation(){
        
        let camera = MGLMapCamera(lookingAtCenter: mapView.userLocation?.coordinate ?? LocationManager.shared.currentLocation?.coordinate ??  CLLocationCoordinate2D.init(latitude: 30.637707, longitude: 76.807804), altitude: 4500, pitch: 15, heading: 0)
        
        // Animate the camera movement over 5 seconds.
        mapView.fly(to: camera, withDuration: 4.0) {
            
            
        }
//        mapView.setCamera(camera, withDuration: 5.0, animationTimingFunction: CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
    }
    
    
}
