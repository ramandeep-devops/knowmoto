//
//  ExtensionMBMapVC.swift
//  Knowmoto
//
//  Created by Apple on 01/10/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit
import CoreLocation

extension MBMapVC {

    func addMyLiveCarsAnnotations(){
        
        let liveCars = UserDefaultsManager.shared.liveCar?.liveCars
        
        liveCars?.forEach({ (car) in
            
            let carLiveLocation = car.location?.coordinates
           
            let annotation = MBCustomMarker(reuseIdentifier: car.id, imageUrl: /car.image?.first?.originalImageKey, cacheKey: /car.image?.first?.originalImageKey,isLoadFromSignedUrl:true)
            
            //set coordinate of live location
            annotation.title = car.displayAppName
            annotation.coordinate = CLLocationCoordinate2D.init(latitude: /carLiveLocation?[1], longitude: /carLiveLocation?[0])
            
            self.mapView.addAnnotation(annotation)
            
        })
        
        
    }
    
    @IBAction func didTapEndLive(_ sender: UIButton) {
        
        self.alertBox(message: "Do you really want to end \(/self.currentSelectedCar?.displayAppName) Live session now?", okButtonTitle: "End now".localized, title: "Alert!".localized) {
            
            self.apiEndLiveCar(liveCar: self.currentSelectedCar, completion: { [weak self] in
                
            })
        }
    }

    func startTimerFor(car:CarListDataModel?){
      
        stackViewTimerLabels.isHidden = car == nil
        btnEndLive.isHidden = car == nil
      
        timerEndSession?.invalidate()
        
        if car == nil{return}
        
        
        let currentMilliseconds = Date().millisecondsSince1970
        let secondsLeftForEndLive = ((car?.liveExpiryTimeStamp ?? 0.0) - currentMilliseconds)/1000
        
        totalSecondsLeftForEndSession = Int64(secondsLeftForEndLive)
        
    
        timerEndSession = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
            
            self?.totalSecondsLeftForEndSession = (self?.totalSecondsLeftForEndSession ?? 0) - 1
            
        }
        
    }
    
    func setTimerLabels(){
        
        
        
        let totalTimeLeftInMilliseconds:Double =  Double((self.totalSecondsLeftForEndSession ?? 0))
        _ = totalTimeLeftInMilliseconds.toDate()
        
        let hrs = Int(totalTimeLeftInMilliseconds) / 3600 //date.hour.toString.addZeroForTime()
        let min = Int(totalTimeLeftInMilliseconds) / 60 % 60 //date.minute.toString.addZeroForTime()
        let sec = Int(totalTimeLeftInMilliseconds) % 60//date.second.toString.addZeroForTime()
        
        lblHrs.text = hrs.toString.addZeroForTime()
        lblMin.text = min.toString.addZeroForTime()
        lblSec.text = sec.toString.addZeroForTime()
        
        
        
    }

    
    func reloadMapOnCarEndSession(){
        
        if let endLiveCar = self.currentSelectedCar{
            delegate?.didEndLiveSessionOf(vehicle: endLiveCar)
        }
        
        self.removeAnnotation(reuseIdentifier: /self.currentSelectedCar?.id)
        
        let remainingLiveCars = UserDefaultsManager.shared.liveCar?.liveCars
        
        if let firstCar = remainingLiveCars?.first{
            
            self.isSelectedVehicleFromList = true
            self.currentSelectedCar = firstCar
            
        }
        
    }
    
}
