//
//  MapBoxGeocodingCustom.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/22/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation
import MapboxGeocoder

class MapBoxGeocodingCustom:NSObject{
    
    static let shared = MapBoxGeocodingCustom()
    
    static var geocode = Geocoder.shared
    
    static func reverseGeocode(allowedScoped:MBPlacemarkScope = [.all],lat:Double,long:Double,address:@escaping (GeocodedPlacemark)->()) {
        
        // main.swift
        let options = ReverseGeocodeOptions(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long))
        options.allowedScopes = allowedScoped
        // Or perhaps: ReverseGeocodeOptions(location: locationManager.location)
        
        let task = geocode.geocode(options) { (placemarks, attribution, error) in
            
            
            
            guard let placemark = placemarks?.first else {
                return
            }
            
            
            address(placemark)
            
            //            print(placemark.imageName ?? "")
            //            // telephone
            //            print(placemark.genres?.joined(separator: ", ") ?? "")
            //            // computer, electronic
            //            print(placemark.administrativeRegion?.name ?? "")
            //            // New York
            //            print(placemark.administrativeRegion?.code ?? "")
            //            // US-NY
            //            print(placemark.place?.wikidataItemIdentifier ?? "")
            //            // Q60
        }
        
    }
    
   static func forwarGeocode(allowedScoped:MBPlacemarkScope = [.all],text:String,completion:@escaping (Array<Any>) ->()){
        
        let geocoder = Geocoder.shared
        
        let options = ForwardGeocodeOptions(query: text)
        
        // To refine the search, you can set various properties on the options object.
        //        options.allowedISOCountryCodes = ["IN"]
        //        options.focalLocation = CLLocation(latitude: 45.3, longitude: -66.1)
        options.maximumResultCount = 5
        options.allowedScopes = allowedScoped
        options.autocompletesQuery = true
        
        let task = geocoder.geocode(options) { (placemarks, attribution, error) in
            
            completion(placemarks ?? [])
            
            //            guard let placemark = placemarks?.first else {
            //                return
            //            }
            
            //            debugPrint(placemarks)
            //            print(placemark.name)
            //            // 200 Queen St
            //            print(placemark.qualifiedName)
            //            // 200 Queen St, Saint John, New Brunswick E2L 2X1, Canada
            //
            //            let coordinate = placemark.location?.coordinate
            //            print("\(/coordinate?.latitude), \(/coordinate?.longitude)")
            // 45.270093, -66.050985
            
        }
        
    }
    
    
}
