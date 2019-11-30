//
//  CarDetailHeaderVC.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/21/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class CarDetailHeaderVC: BaseVC {

    @IBOutlet weak var btnLive: UIButton!
    @IBOutlet weak var imageViewLiveTag: UIImageView!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var lblLike: UILabel!
    @IBOutlet weak var lblLikeVehicleTitle: UILabel!
    @IBOutlet weak var imageViewLikeVehicle: UIImageView!
    @IBOutlet weak var mainContainerStackView: UIStackView!
    
    
    //MARK:- Outlets
    
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var lblLikes: UILabel!
    @IBOutlet weak var btnFollow: UIButton!
    
    //owner
    @IBOutlet weak var imageViewOwner: KnowmotoUIImageView!
    @IBOutlet weak var lblOwnerName: UILabel!
    
    //views
    @IBOutlet weak var viewFeaturedCar: UIView!
    @IBOutlet weak var viewOwner: UIStackView!
    @IBOutlet weak var viewSponsors: UIStackView!
    @IBOutlet weak var viewBeaconLinked: UIStackView!
    @IBOutlet weak var viewLike: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //beacon
    @IBOutlet weak var lblBeaconCompany: UILabel!
    @IBOutlet weak var lblBeaconId: UILabel!
    
    //car
    @IBOutlet weak var imageViewCar: KnowmotoUIImageView!
    @IBOutlet weak var lblCarName: UILabel!
    
    //MARK:- Properties
    
    var dataSourceCollectionView:CollectionViewDataSource?
    var carData:CarListDataModel?
    var isFromMyProfile:Bool = false
    var isFollowed:Bool = false{
        didSet{
            
            carData?.followedByMe = isFollowed
            btnFollow.setTitle(/carData?.followedByMe ? "Following".localized : "Follow".localized, for: .normal)
           
            
        }
    }
    var isLikeByMe:Bool = false{
        didSet{
            
            carData?.likeByMe = isLikeByMe
            self.setLikeButtonWhen(isSelected: isLikeByMe)
            
            
        }
    }
    var delegate:SegementedVCsDelegate?
    
    //MARK:- View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initialSetup()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if isFirstTime{
            delegate?.didChangeHeaderVCHeight(height: mainContainerStackView.frame.size.height)
        }
        
        super.viewDidAppear(true)
     
    }
    
    func initialSetup(){
        
        setData()
        setupUI()
    }
    
    @IBAction func didTapLive(_ sender: UIButton) {
    
        let vc = ENUM_STORYBOARD<MBMapVC>.map.instantiateVC()
        vc.isFromMyLive = carData?.userID?.id == UserDefaultsManager.shared.currentUserId
        vc.selectedFromPreviousScreen = carData
        vc.presentWithNavigationController()
        
    }
    
    
    @IBAction func didTapLike(_ sender: UIButton) {
        
        likeCar()
        
    }
    
    func likeCar(){
        
//        if /carData?.followedByMe{
        
            if /carData?.likeByMe{
                
                self.likeVehicleOf(id: /self.carData?.id)
                
            }else{
                
                if KontaktBeaconDataSource.shared.checkBeaconAndStartDiscovering(alertMessage: "Please on your bluetooth, need to like the vehicle".localized){
                    
                    KontaktBeaconDataSource.shared.searchBeaconOf(loaderMessage:"Locating Vehicle",alertTitle:"Vehicle Not Found",alertMessage:"No vehicle found in your 3m approximity, you should be close to the vehicle".localized,id: /carData?.beaconID?.first?.beaconId) { [weak self] (isFound) in
                        
                        if isFound{
                            
                            self?.likeVehicleOf(id: /self?.carData?.id)
                            
                        }
                        
                    }
                    
                }
            }
            
//        }else{
//
//            self.alertBoxOk(message: "You must have follow this vehicle and you should be nearby your beacon and vehicle to like this vehicle".localized, title: "Alert!", ok: {})
//
//        }
        
        
    }
    
    
    func likeVehicleOf(id:String){
        
        EP_Car.like_dislike(id: id, type: 2).request(success:{ [weak self] (response) in
            
            self?.isLikeByMe = !(self?.isLikeByMe ?? false)
            self?.carData?.totalLikes = /self?.isLikeByMe ? (/self?.carData?.totalLikes + 1) : (/self?.carData?.totalLikes - 1)
            self?.lblLikes.text = /self?.carData?.totalLikes?.toString
            
        })
        
    }
    
    func setLikeButtonWhen(isSelected:Bool){
        
        btnLike.setTitle(isSelected ? "Trophy Point Awarded".localized : "Award Trophy Point".localized, for: .normal)
        btnLike.setImage(#imageLiteral(resourceName: "ic_trophy_colored"), for: .normal)
        lblLike.text = isSelected ? "Awarded".localized : "Award".localized
    }
    
    func setData(){
        
        let carImage = /carData?.image?.first?.thumb
        let ownerImage = /carData?.userID?.image?.thumb
        let beaconCompany = /carData?.beaconID?.first?.beaconCompany
        let beaconId = /carData?.beaconID?.first?.beaconId
        let ownerName = /carData?.userID?.userName
        
        //car data
        imageViewCar?.loadImage(key: carImage, cacheKey: carData?.image?.first?.thumbImageKey)
        lblCarName.attributedText = NSAttributedString(string: /carData?.displayAppName) 
        lblCarName?.setLineSpacing(lineSpacing: 8.0)
        
        //beacon data
        lblBeaconId?.text = "Beacon ID : \(beaconId)"
        lblBeaconCompany?.text = beaconCompany
        
        //Likes
        lblLikes.text = carData?.totalLikes?.toString
        lblFollowers.text = carData?.totalFollowers?.toString
        
        //owner data
        imageViewOwner?.loadImage(key: ownerImage, isLoadWithSignedUrl: true, cacheKey: carData?.userID?.image?.thumbImageKey)
        lblOwnerName?.text = ownerName
        
        isFollowed = carData?.followedByMe ?? false
        
        isLikeByMe = carData?.likeByMe ?? false
        
    }
    
    func setupUI(){
        
        let isHaveBeacon = (!(/carData?.beaconID?.isEmpty) && carData?.beaconID != nil)
        let isCurrentUserCar = /userData?.id == /carData?.userID?.id
        
        let isHaveSponsor = !(/carData?.sponsorID?.isEmpty) && carData?.sponsorID != nil
        
        viewBeaconLinked?.isHidden = !((isHaveBeacon && isFromMyProfile))
        
        viewSponsors?.isHidden = !isHaveSponsor
        
        viewOwner?.isHidden = isCurrentUserCar && isFromMyProfile
        
        btnFollow.isHidden = isFromMyProfile || isCurrentUserCar || userData?.id == nil
        
        viewLike.isHidden = isCurrentUserCar || userData?.id == nil
        
        if !(/viewSponsors?.isHidden){
            
            configureSponsorCollectionView()
            
        }
        
        imageViewOwner.addTapGesture(target: self, action: #selector(self.didTapUser(sender:)))
        lblOwnerName.addTapGesture(target: self, action: #selector(self.didTapUser(sender:)))
        
        btnLive.isHidden = !(/carData?.isLive)
    }
    
    @objc func didTapUser(sender:UIButton){
        
        debugPrint("user profile")
        self.redirectToOUserProfielDetailVC(item: carData?.userID)
     
    }
    
    func configureSponsorCollectionView(){ //Configuring collection View cell
        
        
        let identifier = String(describing: SponsorCollectionViewCell.self)
        collectionView?.registerNibCollectionCell(nibName: identifier)

        let cellWidth:CGFloat = 80.0
        
        let cellHeight:CGFloat = cellWidth + 36.0
        
        dataSourceCollectionView = CollectionViewDataSource(items: carData?.sponsorID ?? [], collectionView: collectionView, cellIdentifier: identifier, headerIdentifier: nil, cellHeight: cellHeight, cellWidth: cellWidth, configureCellBlock: { [weak self] (_cell, item, indexPath) in
            
            
            let cell = _cell as? SponsorCollectionViewCell
            cell?.btnRemove.isHidden = true
            cell?.configureSponsorCell(indexPath: indexPath, item: item)
            
            
            }, aRowSelectedListener: { [weak self] (indexPath, item) in
                
                
                
            }, willDisplayCell: nil, scrollViewDelegate: nil)
        
        
        collectionView.dataSource = dataSourceCollectionView
        collectionView.delegate = dataSourceCollectionView
        self.collectionView.reloadData()
        
    }
 
    //MARK:- Button action
    
    @IBAction func didTapFollow(_ sender: UIButton) { // same for unfollow backend side checking
        
        if isFollowed{
            
            self.alertBox(message: "Do you really want to Unfollow?".localized, title: "Unfollow?".localized) { [weak self] in
                
                self?.apiFollowUnfollow()
                
            }
            
        }else{
            
            apiFollowUnfollow()
            
        }
        
    }
    
    func apiFollowUnfollow(){
        
        
        EP_Car.followUnfollow(id: /carData?.id, type: 1).request(loaderNeeded: true, successMessage: nil, success: { [weak self] (response) in
            
            self?.isFollowed = !(/self?.isFollowed)
            self?.carData?.totalFollowers = /self?.isFollowed ? (/self?.carData?.totalFollowers + 1) : (/self?.carData?.totalFollowers - 1)
            self?.lblFollowers.text = /self?.carData?.totalFollowers?.toString
            
        }) { (error) in
            
            
        }
        
    }
    
    
}
