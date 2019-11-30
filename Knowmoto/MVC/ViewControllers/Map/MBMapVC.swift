//
//  MapVC.swift
//  Knowmoto
//
//  Created by Apple on 19/09/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit
import Mapbox

protocol MBMapVCDelegate:class {
    func didEndLiveSessionOf(vehicle:CarListDataModel)
    func didSelectLocationForGoLive(location:CLLocationCoordinate2D?)
}

extension MBMapVCDelegate{
    func didEndLiveSessionOf(vehicle:CarListDataModel){}
    func didSelectLocationForGoLive(location:CLLocationCoordinate2D?){}
}

class MBMapVC: BaseMapVC {
    
    //MARK:- Outlets
    
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var lblFilterApplied: UILabel!
    @IBOutlet weak var lblSec: UILabel!
    @IBOutlet weak var lblMin: UILabel!
    @IBOutlet weak var lblHrs: UILabel!
    @IBOutlet weak var stackViewTimerLabels: UIStackView!
    @IBOutlet weak var bottomConstraintDetectLocation: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraintContainerView: NSLayoutConstraint!
    @IBOutlet weak var btnEndLive: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    
    //MARK:- Properties
    
    //nearby
    private var arrayNearbyVehicles:[CarListDataModel] = []{
        didSet{
            
            let set1 = Set(oldValue.map({/$0.id}))
            let set2 = Set(arrayNearbyVehicles.map({/$0.id}))
            
            let isAnyNewChangesInDiscoveredBeacons = !(set1.count == set2.count && set1 == set2)
            
            //            if isAnyNewChangesInDiscoveredBeacons{
            
            self.checkOldAnnotations(oldLiveCars: oldValue) // remove if they are not exist(live cars)
            self.setAnnotationOnMap() //set new updated annotation(live cars)
            
            //            }
        }
    }
    
    private var timerNearbyCars:Timer?
    private var currentLocation:CLLocation?{
        didSet{
            
//            self.setCurrentLocationMarker()
            
            if oldValue == nil{
                
                self.emitLocationToGetNearbyCars(fromLocation: currentLocation)
                
            }
        }
    }
    
//    private var currentLocationMarker:MBCustomMarker?
    var selectedFromPreviousScreen:CarListDataModel?
    var currentSelectedCar:CarListDataModel?{
        didSet{
            
            reloadAnnotationsSelection()
            
        }
    }
    private var bottomPopupView:FollowingLiveCarsPopUp?
    
    //My live cars
    
    var isFromMyLive:Bool = false
    var totalSecondsLeftForEndSession:Int64?{
        didSet{
            
            if (totalSecondsLeftForEndSession ?? 0) < Int64(1){
                timerEndSession?.invalidate()
            }
            setTimerLabels()
        }
    }
    private var arrayMyLiveCars:[CarListDataModel]{
        return UserDefaultsManager.shared.liveCar?.liveCars ?? []
    }
    var timerEndSession:Timer?
    
    enum CustomError: Error {
        case castingError(String)
    }
    
    deinit {
        
        timerEndSession?.invalidate()
        timerNearbyCars?.invalidate()
        debugPrint("Deinit successfully... mapvc")
        
    }
    var isSelectedVehicleFromList:Bool = false
    
    private var filterModel = FilterMapModal()
    
    var isFilterApplied:Bool{
        return !(/filterModel.selectedFilterMakes.isEmpty) || !(/filterModel.selectedFilterFeatures.isEmpty) || !(/filterModel.selectedFilterSponsors.isEmpty) || !(/filterModel.selectedFilterColors.isEmpty)
    }
    private var isFirstCarSelected:Bool = false
    
    //MARK:- View controller lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        intialSetup()
    }
    
    func intialSetup(){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            
            self?.setupMapView()
            
            
            //block of nearby cars
            
            
            if /self?.isFromMyLive{
                
                self?.addMyLiveCarsAnnotations()
                
                if self?.selectedFromPreviousScreen != nil{
                    
                    self?.isSelectedVehicleFromList = true
                    self?.isFirstCarSelected = true
                    self?.currentSelectedCar = self?.selectedFromPreviousScreen
                }
                
            }else{
                
                self?.updateCurrentLocation() //timer
                self?.getNearbyCars()
                
            }
            
            
            
            self?.setupUI()
            
        }
    }
    
    
    func setupUI(){
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            
            if !(/UserDefaultsManager.isGuestUser){
                self?.presentLiveCarPopup()
            }
            
        }
        
        btnFilter.isHidden = isFromMyLive
        stackViewTimerLabels.isHidden = !isFromMyLive
        btnEndLive.isHidden = !isFromMyLive
        
        bottomConstraintDetectLocation.constant = UserDefaultsManager.isGuestUser ? 24.0 : UIDevice.isIPhoneXStyle ?  56.0 : 48.0
        btnEndLive.isHidden = !isFromMyLive
        
    }
    
//    //this current location marker change on home selected city and from that location searching live cars in bydefault 30 miles radius set
//    func setCurrentLocationMarker(){
//
//        if currentLocationMarker != nil || isFromMyLive || UserDefaultsManager.isGuestUser{
//            return
//        }
//
//        currentLocationMarker = MBCustomMarker.init(reuseIdentifier: "currentLocation", imageUrl: nil, cacheKey: nil, isLoadFromSignedUrl: false, willUseImage: true)
//        currentLocationMarker?.coordinate = currentLocation?.coordinate ?? CLLocationCoordinate2D.init(latitude: 23.00, longitude: 241234.00)
//        self.mapView.addAnnotation(currentLocationMarker!)
//
//    }
    
    //MARK:- Mapview configuration
    
    override func setupMapView(){
        super.setupMapView()
        
        if isFromMyLive{
            
            self.containerView.bringSubviewToFront(stackViewTimerLabels)
            
        }else{
            
            if selectedFromPreviousScreen == nil{
            
             mapView.setCenter(CLLocationCoordinate2D.init(latitude: 38.732949, longitude: -102.336923), zoomLevel: 2, animated: true)
                
            }
            
        }
        
        mapView.showsHeading = true
        mapView.showsUserHeadingIndicator = true
        mapView.showsUserLocation = true//isFromMyLive || UserDefaultsManager.isGuestUser
        mapView.delegate = self
        
    }
    
    //MARK:- Button acitons
    
    @IBAction func didTapFilter(_ sender: UIButton) {
        
        let vc = ENUM_STORYBOARD<FilterMapVC>.map.instantiateVC()
        
        vc.delegate = self
        vc.filterModel = self.filterModel

        self.presentWithNavigationController(vc: vc)
        
    }
    
    override func didTapCurrentLocation(_ sender: UIButton) {
//
//        if isFromMyLive || UserDefaultsManager.isGuestUser{
//
            super.didTapCurrentLocation(sender)
            
//        }else{
//
//            self.moveCameraToAnnotation(location: CLLocationCoordinate2D.init(latitude: currentLocation?.coordinate.latitude ?? 0.0, longitude: currentLocation?.coordinate.longitude ?? 0.0))
//
//        }
        
    }
    
}

//MARK:- Maqp box delegate functions

extension MBMapVC:MGLMapViewDelegate{
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
       
//        if !isFromMyLive{
//
//            let location = UserDefaultsManager.shared.location?.selectedLocation
//            self.currentLocation = CLLocation.init(latitude: /location?.latitude, longitude: /location?.longitude)
//
//        }
        
    }
    
//    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
//
//        if !(/(annotation as? MBCustomMarker)?.willUseImage){
//            return nil
//        }
//
//        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "currentLocation")
//
//        if annotationImage == nil {
//            // Leaning Tower of Pisa by Stefan Spieler from the Noun Project.
//            var image = UIImage(named: "ic_map_pin")!
//
//            // The anchor point of an annotation is currently always the center. To
//            // shift the anchor point to the bottom of the annotation, the image
//            // asset includes transparent bottom padding equal to the original image
//            // height.
//            //
//            // To make this padding non-interactive, we create another image object
//            // with a custom alignment rect that excludes the padding.
//            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
//
//            // Initialize the ‘pisa’ annotation image with the UIImage we just loaded.
//            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "currentLocation")
//        }
//
//        return annotationImage
//
//    }
    
    //view for annotation
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        
        if let customAnnotation =  annotation as? MBCustomMarker,!customAnnotation.willUseImage{
            
            return MBCustomAnnotationView(annotation: annotation, resuseIdentifier: customAnnotation.reuseIdentifierId, url: customAnnotation.imageUrl,size:CGSize(width: 48, height: 48),isLoadFromSignedUrl:/customAnnotation.isLoadFromSignedUrl,cacheKey:customAnnotation.cacheKey,isSelected:customAnnotation.isSelected)
            
        }
        
        return nil
    }
    
    
    func mapView(_ mapView: MGLMapView, didDeselect annotation: MGLAnnotation) {
        
        debugPrint(annotation as? MBCustomMarker)
        self.currentSelectedCar = nil

    }

    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        
        if let vehicleId = (annotation as? MBCustomMarker)?.reuseIdentifierId,!isSelectedVehicleFromList{
            
            self.openCarDetail(id: vehicleId)
        }
        
        
        if let selectedCar = arrayMyLiveCars.first(where: {$0.id == (annotation as? MBCustomMarker)?.reuseIdentifierId}) {
            
            self.currentSelectedCar = selectedCar
            
        }else if let selectedCar = arrayNearbyVehicles.first(where: {$0.id == (annotation as? MBCustomMarker)?.reuseIdentifierId}) {
            
            self.currentSelectedCar = selectedCar
        }
        
        self.isSelectedVehicleFromList = false
        
    }
    
    func openCarDetail(id:String?){
        
        let vc = ENUM_STORYBOARD<CarDetailSegmentedVC>.car.instantiateVC()
        
        vc.vehicleId = id
        vc.isFromCarDetail = true
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    // did change user location
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        
        //emmit location for nearby cars
        
//        update current location wh
//        if UserDefaultsManager.shared.location?.selectedLocation == nil || isFromMyLive{
//
            self.currentLocation = userLocation?.location //using for live tracking
            
//        }
        
    }
    
}


//MARK:- Current nearby Live cars

extension MBMapVC{
    
    func updateCurrentLocation(){
        
        //live tracking after every 4.0 seconds
        timerNearbyCars = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true, block: { [weak self] (timer) in
            
            if let updatedLocation = self?.currentLocation{
                
                self?.emitLocationToGetNearbyCars(fromLocation: updatedLocation)
                
            }
            
        })
        
        
        
    }
    
    //emit socket to get nearby car in provided radius
    func emitLocationToGetNearbyCars(fromLocation:CLLocation?){
        
        let json = JSONHelper<LiveVehicleModal>().toDictionary2(model: LiveVehicleModal(vehicleId: nil, location: [/fromLocation?.coordinate.longitude,/fromLocation?.coordinate.latitude], distance: radiusOfNearbyCars,role:UserDefaultsManager.isGuestUser ? 4 : nil))
        
        //emittin location for getting nearby cars
        SocketAppManager.sharedManager.nearbyCars(nearby: json)
        
    }
    
    //listen nearby cars
    func getNearbyCars(){
        
        //right that are nearby cars
        SocketAppManager.sharedManager.blockNearbyCars = { [weak self] (cars) in
            
            self?.arrayNearbyVehicles = (cars as? NearbyVehicle)?.vehicles ?? []
            
            if self?.selectedFromPreviousScreen != nil{
                
                self?.isSelectedVehicleFromList = true
                self?.isFirstCarSelected = true
                self?.currentSelectedCar = self?.selectedFromPreviousScreen
                self?.selectedFromPreviousScreen = nil
            }
            
            debugPrint(cars)
            
        }
        
    }
    
    
    
    //setting nearby cars annotations on map
    func setAnnotationOnMap(){
        
        self.arrayNearbyVehicles.forEach { (car) in
            
            let carLiveLocation = car.location?.coordinates
            
            if isFilterApplied{
                
                let isExistInFilter = filterAnnotations(ofCar: car)
                if !isExistInFilter{
                    return
                }
                
            }
            
            if let addedAnnotation = self.mapView.annotations?.first(where: {/($0 as? MBCustomMarker)?.reuseIdentifierId == /car.id}){ // already on map(move to new location)
                
                let coordinate = CLLocationCoordinate2D.init(latitude: /carLiveLocation?[1], longitude: /carLiveLocation?[0])
                self.changeAnnotationPosition(annotation: addedAnnotation as! MGLPointAnnotation, location:coordinate)
                
            }else{ //add new annotation to map
                
                //car live location
                
                //add nearby car annotation on map
                let annotation = MBCustomMarker(reuseIdentifier: car.id, imageUrl: /car.image?.first?.thumb, cacheKey: /car.image?.first?.thumbImageKey)
                
                //set coordinate of live location
                annotation.coordinate = CLLocationCoordinate2D.init(latitude: /carLiveLocation?[1], longitude: /carLiveLocation?[0])
                annotation.accessibilityFrame = CGRect(x: 0, y: 0, width: 68, height: 68)
                self.mapView.addAnnotation(annotation)
                
                //followed cars
                self.bottomPopupView?.arrayLiveCars = self.arrayNearbyVehicles.filter({$0.followedByMe == true})
                
            }
            
        }
        
//        for car in self.arrayNearbyVehicles{
//
//        }
    }
    
    
    
    //remove annotation that are not live now
    
    func checkOldAnnotations(oldLiveCars:[CarListDataModel]){
        
        DispatchQueue.main.async { [weak self] in
            
            if /self?.arrayNearbyVehicles.isEmpty && !(/self?.mapView.annotations?.isEmpty){
                
                self?.mapView.removeAnnotations(self?.mapView.annotations?.filter({($0 as? MBCustomMarker)?.reuseIdentifierId != "currentLocation"}) ?? [])
                
                
            }else{ //remove any one annotation removed according to new data 
                
                for car in oldLiveCars{
                    
                    if !(/self?.arrayNearbyVehicles.contains(where: {$0.id == car.id})) || /self?.arrayNearbyVehicles.isEmpty{
                        
                        if let oldAnnotation = self?.mapView.annotations?.first(where: {($0 as? MBCustomMarker)?.reuseIdentifierId == /car.id}){
                            
                            //remove from collection view horizintal list //not optimized this code
                            if /self?.bottomPopupView?.arrayLiveCars.contains(where: {$0.id == car.id}){
                                
                                self?.bottomPopupView?.arrayLiveCars = self?.arrayNearbyVehicles ?? []
                            }
                            
                            self?.mapView.removeAnnotation(oldAnnotation)
                            
                        }
                        
                    }
                    
                }
                
                
                
            }
            
        }
        
    }
    
    
}

//MARK:- Common functions

extension MBMapVC{
    
    func reloadAnnotationsSelection(){
        
        
        if currentSelectedCar == nil{
            
            self.mapView.selectedAnnotations.forEach { (annotation) in
                self.mapView.deselectAnnotation(annotation, animated: true)
            }
            
        }
        
        if isFromMyLive{
            
            self.startTimerFor(car: currentSelectedCar)
            self.selectAnnotationOf(resuseIdentifier: /currentSelectedCar?.id)
            self.bottomPopupView?.selectCarOf(id: /currentSelectedCar?.id)
            
            
        }else{
            
            self.selectAnnotationOf(resuseIdentifier: /currentSelectedCar?.id)
            self.bottomPopupView?.selectCarOf(id: /currentSelectedCar?.id)
            
        }
    }
    
    func presentWithNavigationController(vc:UIViewController){
        
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.isHidden = true
        navigationController.navigationBar.barTintColor = UIColor.clear
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    //bottom popup
    func presentLiveCarPopup(){
        
        let height = UIScreen.main.bounds.size.height/2.7
        let collapseHeight:CGFloat = /UIDevice.isIPhoneXStyle ? 80.0 : 24.0
        
        bottomPopupView = FollowingLiveCarsPopUp(frame: CGRect.init(x: 0, y: self.view.frame.maxY - collapseHeight, width: UIScreen.main.bounds.width, height: height))
        
        bottomPopupView?.selectedCar = self.selectedFromPreviousScreen
        
        bottomPopupView?.blockDidSelectCar = { [weak self] (selectedCar) in
            
            self?.isSelectedVehicleFromList = selectedCar != nil
            self?.currentSelectedCar = selectedCar
            
        }
        
        
        bottomPopupView?.isFromMyLive = self.isFromMyLive
        bottomPopupView?.arrayLiveCars = isFromMyLive ? UserDefaultsManager.shared.liveCar?.liveCars ?? [] : arrayNearbyVehicles.filter({$0.followedByMe == true})
        
        bottomPopupView?.collectionView.alpha = 0.0
        
        
        
        self.view.addSubview(bottomPopupView!)
        self.view.bringSubviewToFront(bottomPopupView!)
        
    }
    
    func removeAnnotation(reuseIdentifier:String){
        
        if let oldAnnotation = self.mapView.annotations?.first(where: {($0 as? MBCustomMarker)?.reuseIdentifierId == /reuseIdentifier}){
            
            //remove from collection view horizintal list //not optimized this code
            self.bottomPopupView?.removeCarWhere(id: reuseIdentifier)
            
            self.mapView.removeAnnotation(oldAnnotation)
            
            
            
        }
        
    }
    
    func selectAnnotationOf(resuseIdentifier:String){
        
        
        if let selectedAnnotationCar = self.mapView.annotations?.first(where: {($0 as? MBCustomMarker)?.reuseIdentifierId == /resuseIdentifier}){
            
            self.mapView.selectAnnotation(selectedAnnotationCar, moveIntoView: false, animateSelection: true)
            
            self.moveCameraToAnnotation(location: selectedAnnotationCar.coordinate)
            
        }
        
    }
    
    func moveCameraToAnnotation(location:CLLocationCoordinate2D){
        
        let camera = MGLMapCamera(lookingAtCenter: location, altitude: 4500, pitch: 15, heading: 0)
        
        // Animate the camera movement over location
        //        mapView.setCamera(camera, animated: true)
        
        mapView.fly(to: camera, withDuration: 2.0) {
            
            
        }
    }
    
    
    //move annotation to postition
    func changeAnnotationPosition(annotation:MGLPointAnnotation,location:CLLocationCoordinate2D){
        
        if annotation.coordinate.latitude != location.latitude || annotation.coordinate.longitude != location.longitude{
            
            UIView.animate(withDuration: 0.5) {
                
                annotation.coordinate = location
                
            }
            
        }
    }
}

//MARK:- Filter delegates
extension MBMapVC:FilterMapVCDelegate{
    
    func didApplyFilter(filterModel: FilterMapModal) {
        
        self.filterModel = filterModel

        self.lblFilterApplied.isHidden = filterModel.selectedFilterModels.isEmpty && filterModel.selectedFilterMakes.isEmpty && filterModel.selectedFilterSponsors.isEmpty && filterModel.selectedFilterFeatures.isEmpty && filterModel.selectedFilterColors.isEmpty
        
    }
    

    func filterAnnotations(ofCar:CarListDataModel?) -> Bool{
        
        
        //make and model
        let isExistInMakeFilter = filterModel.selectedFilterMakes.contains { (makeData) -> Bool in
            
            //make
            if makeData.arraySelectedModels == nil || /makeData.arraySelectedModels?.isEmpty{ //models all empty filter will work make(parent) other wise on selected models of that make
                
                return ofCar?.make?.first?.id == makeData.id
                
            }else{ //model
                
                let isExist = /makeData.arraySelectedModels?.contains(where: {$0.name == ofCar?.model?.first?.name})
                
                return isExist
                
            }
            
        }
        
        //feature
        let isExistInFeatureFilter = filterModel.selectedFilterFeatures.contains { (featureData) -> Bool in
            
            let isExist = /ofCar?.featureID?.contains(where: {/$0.id == /featureData.id}) || /ofCar?.modificationType?.contains(where: {/$0.modificationId == /featureData.id})
            
            return /isExist
            
        }
        
        //sponsor
        let isExistInSponsorFilter = filterModel.selectedFilterSponsors.contains { (sponsorData) -> Bool in
            
            let isExist = ofCar?.sponsorID?.contains(where: {/$0.id == /sponsorData.id})
            
            return /isExist
            
        }
        
        let isExistInColorFilter = filterModel.selectedFilterColors.contains { (filterColor) -> Bool in
            
            let isExist = /ofCar?.color == /filterColor.name
            
            return /isExist
            
        }
        
        
        //all checking
        if !(/isExistInMakeFilter) && !(/isExistInFeatureFilter) && !(/isExistInSponsorFilter) && !(/isExistInColorFilter){
            
            self.removeAnnotation(reuseIdentifier: /ofCar?.id)
            
        }
        

        return /isExistInMakeFilter || isExistInSponsorFilter || isExistInFeatureFilter || isExistInColorFilter
        
    }
}
