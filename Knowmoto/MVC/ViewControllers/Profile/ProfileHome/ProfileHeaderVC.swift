//
//  ProfileHeaderVC.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/9/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class ProfileHeaderVC: BaseVC {
    
    //MARK:- Outlet
    
    @IBOutlet weak var lblAddCarInButton: UILabel!
    @IBOutlet weak var btnAddANewCarDotted: UIButton!
    @IBOutlet weak var containerViewDottedAddNewCar: UIView!
    @IBOutlet weak var viewManageBeacons: UIView!
    @IBOutlet weak var viewAddCar: UIView!
    @IBOutlet weak var viewMangeInterest: UIView!
    @IBOutlet weak var collectionViewAddCar: UICollectionView!
    
    //MARK:- Properties
    
    var userType:ENUM_APP_USERS = .basicUser
    var dataSourceCollections:CollectionViewDataSource?
    var arrayMyCars:[CarListDataModel] = []{
        didSet{
            
            self.dataSourceCollections?.items = arrayMyCars
            self.collectionViewAddCar?.reloadData()
        }
    }
    var delegate:SegementedVCsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            
            self?.btnAddANewCarDotted.addDottedBorder(cornerRadius: 8, color: UIColor.HighlightSkyBlueColor!)
            self?.configureCollectionView()
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        setLayout()
//        apiGetCars()
    }
    
    func setLayout(){
        
    
        viewAddCar.isHidden = userType == .beaconOwnerOrCarsAdded
        viewManageBeacons.isHidden = userType == .basicUser
        
    }
    
    func configureCollectionView(){ //Configuring collection View cell
        
        let cellSpacing:CGFloat = 16
        let cellWidth:CGFloat = (collectionViewAddCar.bounds.width - ((cellSpacing * 3)))/2
        let cellHeight:CGFloat = collectionViewAddCar.bounds.height
        
        
        let identifier = String(describing: CarsCollectionViewCell.self)
        collectionViewAddCar.registerNibCollectionCell(nibName: identifier)
        
        
        dataSourceCollections = CollectionViewDataSource(items: arrayMyCars, collectionView: collectionViewAddCar, cellIdentifier: identifier, headerIdentifier: nil, cellHeight: cellHeight, cellWidth: cellWidth, configureCellBlock: { (_cell, item, indexPath) in
            
            let cell = _cell as? CarsCollectionViewCell
            cell?.model = item
            
            
        }, aRowSelectedListener: { [unowned self] (indexPath, item) in
            
            let vc = ENUM_STORYBOARD<CarDetailSegmentedVC>.car.instantiateVC()
            
            vc.carData = self.arrayMyCars[indexPath.row]
            vc.isFromMyProfile = true
            
            self.navigationController?.pushViewController(vc, animated: true)
            
            
            }, willDisplayCell: nil, scrollViewDelegate: nil)
        
        collectionViewAddCar.dataSource = dataSourceCollections
        collectionViewAddCar.delegate = dataSourceCollections
        collectionViewAddCar.reloadData()
        
    }
    
    
    @IBAction func didTapAddCar(_ sender: UIButton) {
        
        //***** cleint requirement to add car without beacon beacause if they don't have beacon how can add car if beacon required.
        
        if userData?.role == 1{

            didTapAddAnotherBeacon()

        }else{
        
            redirectToAddCarFlow()
            
        }
        
    }
    
    func redirectToAddCarFlow(){
        let vc = ENUM_STORYBOARD<MainAddCarVC>.car.instantiateVC()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    func didTapAddAnotherBeacon(){
        
        let view = AddBeaconPopup(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 48, height: 271))
        
        view.delegates = self
        view.openPopUp()
    }
    
    @IBAction func didTapInterests(_ sender: UIButton) {
        
        let vc = ENUM_STORYBOARD<ManageInterestVC>.profile.instantiateVC()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func didTapManageBeacons(_ sender: UIButton) {
        
        let vc = ENUM_STORYBOARD<ManageBeaconVC>.profile.instantiateVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ProfileHeaderVC:AddBeaconDelegate{
    
    func didBeaconAdded(model: Any) {
        
        //this is temporary instance to send beacond id to add car flow
        let addEditCarViewModel = AddEditCarViewModel()
        addEditCarViewModel.beaconId = (model as? BeaconlistModel)?.id
        
        let userdata = UserDefaultsManager.shared.loggedInUser//beacon owner role set here we added our first beacon
        userdata?.role = 2
        UserDefaultsManager.shared.loggedInUser = userdata
        
        UserDefaultsManager.shared.addCarViewModel = addEditCarViewModel
        redirectToAddCarFlow()
        
    }
    
}

//MARK:-API
extension ProfileHeaderVC{
    
    
    
}
