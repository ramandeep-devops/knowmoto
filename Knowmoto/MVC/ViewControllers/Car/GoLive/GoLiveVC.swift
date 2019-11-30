//
//  GoLiveVC.swift
//  Knowmoto
//
//  Created by cbl16 on 22/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class GoLiveVC: BaseGoLiveVC {
    
    //MARK:- OUTLETS

    @IBOutlet weak var stackViewLiveCars: UIStackView!
    @IBOutlet weak var collectionViewLiveCars: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK:-PROPERTIES
    
    var collectionDataSource: CollectionViewDataSource?
    var collectionDataSourceLiveCars: CollectionViewDataSource?
    
    var arrayCars:[CarListDataModel] = []
    
    var arraySelectVehicle:[CarListDataModel]{ //filtering from array cars
        
        let vehicles = arrayCars.filter({/$0.beaconID?.isEmpty == false && /$0.liveExpiryTimeStamp?.toDate().isPast == true})
        self.selectedCar = vehicles.first
        
        vehicles.isEmpty ? self.setCollectionViewBackgroundView(collectionView: collectionView, noDataFoundText: "No vehicles found to go live!".localized,textColor:UIColor.SubtitleLightGrayColor!) : (self.collectionView.backgroundView = nil)
        
        return vehicles
    }
    
    var arrayLiveCars:[CarListDataModel]{ //filtering from array cars
        
        let liveCars = arrayCars.filter({$0.liveExpiryTimeStamp?.toDate().isPast == false})
       
        return liveCars
    }
    
    var selectedTimeFrameInSeconds:Int = 3600
    
    //MARK:- LIFE CYCLE METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            
            self?.configureCollectionView()
            self?.configureCollectionViewLiveCars()
        }
    }
    
    private func setupUI(){
        
       hideUnhideLiveCarCollectionView()
        
    }
    
    
    //MARK:- CONFIGURE COLLECTION CELL
    func configureCollectionView(){ //can go live
        
        // set cell spacing
        let cellSpacing:CGFloat = 16
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 16, bottom: 0, right: 16)
        
        // set cel height and width
        let cellWidth:CGFloat = (UIScreen.main.bounds.width - ((cellSpacing * 3) + 32))/2
        let cellHeight:CGFloat = collectionView.bounds.height
        
        // identifier and Xib registration
        let identifier = String(describing: SponsorCollectionViewCell.self)
        collectionView.registerNibCollectionCell(nibName: identifier)
        
        collectionDataSource = CollectionViewDataSource(items:arraySelectVehicle, collectionView: collectionView, cellIdentifier: identifier, headerIdentifier: nil
            , cellHeight: cellHeight,cellWidth:cellWidth, configureCellBlock:{(cell, item, indexPath) in
                
            // get cell data
            if let _cell = cell as? SponsorCollectionViewCell {
                    //_cell.lblName.text = "Mustang"
                _cell.clipsToBounds = false
                _cell.configureGoLiveCell(model: item, selectedItem: self.selectedCar)
                
            }
                
        }, aRowSelectedListener:{ [weak self] (indexPath,item) in
        
            self?.selectedCar = self?.arraySelectVehicle[indexPath.item]
            self?.collectionView.reloadData()
            
            
        
        } , willDisplayCell:nil , scrollViewDelegate:nil )
        
        collectionView.dataSource = collectionDataSource
        collectionView.delegate = collectionDataSource
        collectionView.reloadData()
    }
    
    //Live cars
    func configureCollectionViewLiveCars(){
        
        // set cell spacing
        let cellSpacing:CGFloat = 16
        collectionViewLiveCars?.contentInset = UIEdgeInsets(top: 10, left: 16, bottom: 0, right: 16)
        
        // set cel height and width
        let cellWidth:CGFloat = (UIScreen.main.bounds.width - ((cellSpacing * 3) + 32))/2
        let cellHeight:CGFloat = collectionViewLiveCars.bounds.height
        
        // identifier and Xib registration
        let identifier = String(describing: SponsorCollectionViewCell.self)
        collectionViewLiveCars.registerNibCollectionCell(nibName: identifier)
    
        
        collectionDataSourceLiveCars = CollectionViewDataSource(items:arrayLiveCars, collectionView: collectionViewLiveCars, cellIdentifier: identifier, headerIdentifier: nil
            , cellHeight: cellHeight,cellWidth:cellWidth, configureCellBlock:{(cell, item, indexPath) in
                
                // get cell data
                if let _cell = cell as? SponsorCollectionViewCell {
                    //_cell.lblName.text = "Mustang"
                    _cell.clipsToBounds = false
                    _cell.configureActiveLiveCars(model: item)
                    
                }
                
        }, aRowSelectedListener:{ [weak self] (indexPath,item) in
            
            let vc = ENUM_STORYBOARD<MBMapVC>.map.instantiateVC()
            vc.isFromMyLive = true
            vc.delegate = self
            vc.selectedFromPreviousScreen = self?.arrayLiveCars[indexPath.item]
            vc.presentWithNavigationController()
//            self?.topMostVC?.present(vc, animated: true, completion: nil)
  
            } , willDisplayCell:nil , scrollViewDelegate:nil )
        
        collectionViewLiveCars.dataSource = collectionDataSourceLiveCars
        collectionViewLiveCars.delegate = collectionDataSourceLiveCars
        collectionViewLiveCars.reloadData()
    }
 
    
//    override func didEndLiveSessionOf(vehicle: CarListDataModel) {
//
//        //set time stamp of car to zero to reload current screen
//        self.arrayCars.first(where: {/$0.id == /vehicle.id})?.liveExpiryTimeStamp = 0
//
//        reloadLiveCars()
//
//        reloadSelectedCarsToLive()
//
//    }
    
}

//MARK:- MBMA
extension GoLiveVC{

    func reloadDataOf(vehicle: CarListDataModel) {
        
        self.arrayCars.first(where: {/$0.id == /vehicle.id})?.liveExpiryTimeStamp = 0
        
        reloadLiveCars()
        
        reloadSelectedCarsToLive()
    }
    
    func reloadLiveCars(){
        
        hideUnhideLiveCarCollectionView()
        self.collectionDataSourceLiveCars?.items = self.arrayLiveCars
        self.collectionViewLiveCars.reloadData()
    }
    
    func reloadSelectedCarsToLive(){
        //selected vehicle reloading
        self.collectionDataSource?.items = self.arraySelectVehicle
        self.collectionView.reloadData()
    }
    
    func hideUnhideLiveCarCollectionView(){
        
        stackViewLiveCars.isHidden = arrayLiveCars.isEmpty
    }
    
}
