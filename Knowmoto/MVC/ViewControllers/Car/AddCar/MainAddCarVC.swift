//
//  BaseAddCarVC.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/15/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class AddEditCarViewModel:NSObject,NSCopying{
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = AddEditCarViewModel.init(makeId: makeId, modificationType: modificationType,beaconId:beaconId)
        return copy
    }
    
    
    var arrayFeatures:[FeaturesListModel]?
    var arraySponsors:[FeaturesListModel]?
    var id:String?
    var name: String?
    var makeName:String?
    var modelName:String?
    var typeOrSubmodel:String?
    var color:String?
    var makeId: BrandOrCarModel?
    var year: Int?
    var country, nickName, beaconId: String?
    var modificationType: [ModificationType]?
    var image: [ImageUrlModel]?
    var featureId, sponsorId: [String]?
    var location: [Int]?
    var selectedMakeModel:BrandOrCarModel?
    var arrayBasicInfo:[BasicInfoModel]?
    var uiImages:[UIImage]?
    var jsonMakeId:Any?
    
    override init() {
    }
    
    init(carData:CarListDataModel?) {

        self.makeName = carData?.make?.first?.name
        self.modelName = carData?.model?.first?.name
        self.typeOrSubmodel = /carData?.subModel?.first?.name
        self.color = /carData?.subModel?.first?.color?.first
        self.year = carData?.year
        self.country = nil
        self.nickName = carData?.nickName

        self.arrayFeatures = carData?.featureID
        self.arraySponsors = carData?.sponsorID
        self.image = carData?.image
        self.modificationType = carData?.modificationType

    }
    
    init(makeId:BrandOrCarModel?) {
        self.makeId = makeId
    }
    init(makeId: BrandOrCarModel?,modificationType: [ModificationType]?,beaconId:String?) {
        self.beaconId = beaconId
        self.makeId = makeId
        self.modificationType = modificationType
    }
}

class MainAddCarVC: BaseVC {
    
    enum FlowRedirection{
        case back
        case next
    }
    
    @IBOutlet weak var containerViewNext: UIView!
    
    //closure for shared next button
    static var didTapNext:((UIButton)->())?
    
    var loadingWidth:CGFloat = 56.0
    var loadingValue:CGFloat = 0.0
    
    var screenNo:Int = 0
    var totalNoOfScreens:Int = 7
    
    static var headerView: KnowmotoHeaderView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        initialSetup()
        
    }
    
    func initialSetup(){
        
        headerView.headerView.btnRight?.isHidden = true
        
        loadingWidth = UIScreen.main.bounds.width/CGFloat(totalNoOfScreens)
        
        MainAddCarVC.headerView = headerView
        
        btnNext?.isExclusiveTouch = true
        
        self.setLoaderView(type: .next)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didTapAddNext(_:)), name: .UPDATE_LOADING, object: nil)
        
        
        actionBackButtonBlock()
        
    }
    
    func setEditCarData(){
        
    }
    
    func actionBackButtonBlock(){
        
        guard let navigationControllerOfContainerView = (self.children.first as? UINavigationController) else {return}
        
        headerView.headerView.didTapLeftButton = {  [weak self] (sender) in
            
            self?.headerView.headerView.btnLeft?.isUserInteractionEnabled = false
            
            
            if (/self?.screenNo <= 1){
                
                self?.navigationController?.popViewController(animated: true)
                self?.headerView.headerView.btnLeft?.isUserInteractionEnabled = true
                
                return
            }
            
            navigationControllerOfContainerView.popViewController(animated: true, completion: {
                
                self?.headerView.headerView.btnLeft?.isUserInteractionEnabled = true
                
                self?.setLoaderView(type: .back)
                
            })
            
        }
    }

    
    @IBAction func didTapAddNext(_ sender: UIButton) {
     
        //shared property of loading and next
        
        if (self.screenNo >= totalNoOfScreens){
            return
        }
     
        setLoaderView(type: .next)
        
    }
    
    func setLoaderView(type:FlowRedirection){
        
    
        self.loadingValue = type == .next ? self.loadingValue +  self.loadingWidth : self.loadingValue - self.loadingWidth
        
        headerView.headerView.widthConstraintPercentageView?.constant = self.loadingValue
        
        
        self.screenNo = type == .next ? self.screenNo + 1 : self.screenNo - 1
        
        debugPrint(self.screenNo)
        
        self.containerViewNext?.isHidden = self.screenNo == 1
        
        
      
        //animate loading
        UIView.animate(withDuration: 0.4) { [weak self] in
            
            self?.view.layoutIfNeeded()
            
        }
        
        
        
    }
    
    
}
