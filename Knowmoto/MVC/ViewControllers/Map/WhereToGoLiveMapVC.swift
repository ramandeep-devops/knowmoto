//
//  WhereToGoLiveMapVC.swift
//  Knowmoto
//
//  Created by Apple on 04/10/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit
import Mapbox

class WhereToGoLiveMapVC: BaseMapVC {
    
    @IBOutlet weak var centerConstraintPin: NSLayoutConstraint!
    @IBOutlet weak var btnGoLive: KnomotButton!
    @IBOutlet weak var textFieldLocation: UITextField!
    
    var liveCar:CarListDataModel?
    var livetimeInSecond:Int64?
    var currentLocation:CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        intialSetup()
    }
    
    private func intialSetup(){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            
            self?.setupMapView()
        }
    }
    
    override func setupMapView() {
        super.setupMapView()
        
        mapView.delegate = self
        getLocationOfCurrentLocation()
        centerConstraintPin.constant = UIDevice.isIPhoneXStyle ? 2 : -14
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.moveCameraToCurrentLocation()
        }
        
        
    }
    
    func getLocationOfCurrentLocation(lat:Double? = nil,long:Double? = nil){
        
        let currentLocation = LocationManager.shared.currentLocation?.coordinate
        
        self.currentLocation = currentLocation
        
        //adding pin current selection pin (fixed on position)
//        let pinAnnotation = MBCustomMarker(reuseIdentifier: "pin", imageUrl: nil, cacheKey: nil, willUseImage: true)
//        pinAnnotation.coordinate = currentLocation!
//        self.mapView.addAnnotation(pinAnnotation)
        
        MapBoxGeocodingCustom.reverseGeocode(allowedScoped:[.all], lat: /currentLocation?.latitude, long: /currentLocation?.longitude, address: { [weak self] (placeMarker) in
            
            self?.btnGoLive.enableButton = true
            self?.textFieldLocation.text = placeMarker.formattedName
            
        })
        
    }
    
    @IBAction func didTapGoLive(_ sender: UIButton) {
        
        self.dismiss(animated: true) { [weak self] in
            
            self?.delegate?.didSelectLocationForGoLive(location: self?.currentLocation)
            
        }
        
    }
    
}

//Map view delegate
extension WhereToGoLiveMapVC:MGLMapViewDelegate{
    
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        
        if self.currentLocation == nil{
            
            self.currentLocation = userLocation?.coordinate
            getLocationOfCurrentLocation(lat: userLocation?.location?.coordinate.latitude, long: userLocation?.location?.coordinate.longitude)
            
        }
        
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        if !(/(annotation as? MBCustomMarker)?.willUseImage){
            return nil
        }
        
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "pin")
        
        if annotationImage == nil {
            // Leaning Tower of Pisa by Stefan Spieler from the Noun Project.
            var image = UIImage(named: "ic_pin")!
            
            // The anchor point of an annotation is currently always the center. To
            // shift the anchor point to the bottom of the annotation, the image
            // asset includes transparent bottom padding equal to the original image
            // height.
            //
            // To make this padding non-interactive, we create another image object
            // with a custom alignment rect that excludes the padding.
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: -80, left: 0, bottom: 80, right: 0))
            
            // Initialize the ‘pisa’ annotation image with the UIImage we just loaded.
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "pin")
        }
        
        return annotationImage
        
    }
    
}
