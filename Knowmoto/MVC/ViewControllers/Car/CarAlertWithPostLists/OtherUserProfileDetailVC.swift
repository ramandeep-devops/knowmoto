//
//  OtherUserProfileDetailVC.swift
//  Knowmoto
//
//  Created by Apple on 24/10/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit


class OtherUserProfileDetailVC: BaseVC {
    
    @IBOutlet weak var viewVehicles: UIView!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSourceCollections:CollectionViewDataSource?
    var arrayCars:[CarListDataModel] = []{
        didSet{
            
            self.viewVehicles.isHidden = arrayCars.isEmpty
            self.dataSourceCollections?.items = arrayCars
            self.collectionView?.reloadData()
        }
    }
    
    var ouserData:UserData?
    var didGetNewHeaderHeight:((CGFloat)->())?
 
    override func viewDidLoad() {
        super.viewDidLoad()

        initialSetup()
        
    }
    
    func initialSetup(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.apiGetCars), name: .PROFILE_UPDATE, object: nil)
        
        apiGetCars()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.configureCollectionView()
        }
        
        imageViewUser.loadImage(key: /ouserData?.image?.thumb, isLoadWithSignedUrl: false, cacheKey: /ouserData?.image?.thumbImageKey)
        lblName.text = /ouserData?.userName
    }
    
    //MARK:- Collection view configuration
    
    func configureCollectionView(){ //Configuring collection View cell
        
        let cellSpacing:CGFloat = 16
        let cellWidth:CGFloat = (collectionView.bounds.width - ((cellSpacing * 3)))/2
        let cellHeight:CGFloat = collectionView.bounds.height
        
        let identifier = String(describing: CarsCollectionViewCell.self)
        collectionView.registerNibCollectionCell(nibName: identifier)
        
        dataSourceCollections = CollectionViewDataSource(items: arrayCars, collectionView: collectionView, cellIdentifier: identifier, headerIdentifier: nil, cellHeight: cellHeight, cellWidth: cellWidth, configureCellBlock: { (_cell, item, indexPath) in
            
            let cell = _cell as? CarsCollectionViewCell
            cell?.model = item
            
            
        }, aRowSelectedListener: { [unowned self] (indexPath, item) in
            
            let vc = ENUM_STORYBOARD<CarDetailSegmentedVC>.car.instantiateVC()
            
            vc.carData = self.arrayCars[indexPath.row]
            vc.isFromCarDetail = self.ouserData?.id != self.userData?.id
            vc.isFromMyProfile = self.ouserData?.id == self.userData?.id
            
            self.navigationController?.pushViewController(vc, animated: true)
            
            
            }, willDisplayCell: nil, scrollViewDelegate: nil)
        
        collectionView.dataSource = dataSourceCollections
        collectionView.delegate = dataSourceCollections
        collectionView.reloadData()
        
    }

    //MARK:- button actions
    
    @IBAction func didTapBookmarks(_ sender: UIButton) {
        
        let vc = ENUM_STORYBOARD<BookMarkCarsSegementedVC>.profile.instantiateVC()
        vc.ouserData = ouserData
        vc.presentWithNavigationController()
    }
    
    //MARK:- API
    
    @objc func apiGetCars(){
        
        EP_Car.get_car_feeds(id: nil, userId: ouserData?.id ?? userData?.id, loggedInUserId: userData?.id).request(loaderNeeded: true, successMessage: nil, success: { [weak self] (response) in
            
            let _response = (response as? [CarListDataModel]) ?? []
            self?.arrayCars = _response
            
            defer{
                if /self?.arrayCars.isEmpty{
                    self?.didGetNewHeaderHeight?(216)
                }
            }
            
        }) { (error) in
            
            debugPrint(error)
        }
        
    }
}
