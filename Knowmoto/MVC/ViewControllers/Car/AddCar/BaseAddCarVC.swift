//
//  BaseAddCarVC.swift
//  Knowmoto
//
//  Created by Apple on 29/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

protocol BaseAddCarDelegate:class {
    func reloadCarDetail(data:Any?)
}

class BaseAddCarVC: BaseVC {
    
    //MARK:- Outlet
    
    @IBOutlet weak var containerViewNext: UIView!
    
    //MARK:- Properties
    
    var isFromEditCar:Bool = false
    var viewModel:AddEditCarViewModel?
    var carData:CarListDataModel?
    
    
    //MARK:- View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        
    }
    
    func setUpUI(){
        
        btnNext?.setTitle(isFromEditCar ? "Update".localized : "Next".localized, for: .normal)
        headerView?.isHidden = !isFromEditCar
        containerViewNext.isHidden = !isFromEditCar && carData != nil
        
    }
    
    
}

//MARK:- API
extension BaseAddCarVC{
    
    func apiAddAndEditCar(){
        
        //setting api data
        var jsonModificationType:Any?
        var makeId:Any?
        var pics:Any?
        var jsonCustomSponsors:Any?
        var jsonCustomFeatures:Any?
        
        if let makeData = viewModel?.makeId{
            
            let makeIdApiModel = Make(id: makeData.id, modelId: Model.init(id: makeData.modelId?.id, submodel: SubModel.init(color: makeData.modelId?.subModel?.color, id: makeData.modelId?.subModel?.id)))
            
            makeId = JSONHelper<Make>().toDictionary2(model: makeIdApiModel)
        }
        
        if let viewModelCopy = viewModel?.copy(),let modificationData = (viewModelCopy as? AddEditCarViewModel)?.modificationType{
            
            modificationData.forEach({ (model) in
                
                model.brandData = nil
                model.modificationData = nil
                
            })
            
            jsonModificationType = JSONHelper<[ModificationType]>().toDictionary(model: modificationData)
        }
        
        if let picsData = viewModel?.image{
            pics = JSONHelper<[ImageUrlModel]>().toDictionary(model: picsData)
        }
        
        //custom sponsors
        let sponsorsManuallyAdded = viewModel?.arraySponsors?.filter({$0.id == nil})
        var apiSponsors = [FeaturesListModel]()
        sponsorsManuallyAdded?.forEach({apiSponsors.append(FeaturesListModel.init(name: $0.name, image: $0.image?.first ?? ImageUrlModel()))})
        
        jsonCustomSponsors = apiSponsors.isEmpty ? nil : JSONHelper<[FeaturesListModel]>().toDictionary(model: apiSponsors)
        
        //custom features
        let featuresManuallyAdded = viewModel?.arrayFeatures?.filter({$0.id == nil})
        var apiFeatures = [FeaturesListModel]()
        featuresManuallyAdded?.forEach({apiFeatures.append(FeaturesListModel(feature: $0.feature))})
        
        jsonCustomFeatures = apiFeatures.isEmpty ? nil : JSONHelper<[FeaturesListModel]>().toDictionary(model: apiFeatures)
        
        
        let year = viewModel?.year
        let country = viewModel?.country
        let nickName = viewModel?.nickName
        let beaconId = viewModel?.beaconId
        let featureIds = viewModel?.featureId?.filter({$0.trimmed() != ""}).toJsonString()
        let sponsorIds = viewModel?.sponsorId?.filter({$0.trimmed() != ""}).toJsonString()
        
        let coordinate = LocationManager.shared.currentLocation?.coordinate
        let jsonLocation = [coordinate?.longitude ?? 75.857277,coordinate?.latitude ?? 30.900965].toJsonString()
        
        EP_Car.add_edit_car(id: carData?.id, name: nil, makeId: makeId, year: year, country: country, nickName: nickName, beaconId: beaconId, modificationType: jsonModificationType, image: pics, featureId: featureIds, sponsorId: sponsorIds, sponsors: jsonCustomSponsors, location: jsonLocation, features: jsonCustomFeatures, isLiveExpiry: nil).request(loaderNeeded: true, successMessage: nil, success: { [weak self] (response) in
            
            if /self?.isFromEditCar{
                
                NotificationCenter.default.post(name: .PROFILE_UPDATE, object: nil)
                
                for vc in self?.navigationController?.viewControllers ?? []{
                    
                    if vc.isKind(of: SummaryAddCarVC.self){
                        
                        self?.navigationController?.popToViewController(vc, animated: true)
   
                        (vc as? SummaryAddCarVC)?.apiGetCar(isReloadCardetail: true)
                  
                    }
                    
                }
                
                
                
            }else{
                
                for vc in self?.topMostVC?.navigationController?.viewControllers ?? []{
                    
                    if vc.isKind(of: ProfileHomeSegementedVC.self){
                        
                        self?.topMostVC?.navigationController?.popToViewController(vc, animated: true)
                        
                        NotificationCenter.default.post(name: .PROFILE_UPDATE, object: nil)
                        
                        Toast.show(text: "Vehicle added successfully.".localized, type: .success)
                        
                    }
                }
                
            }
            
        }) { (error) in
            
            debugPrint(error)
            
        }
        
    }
    
    
    
}
