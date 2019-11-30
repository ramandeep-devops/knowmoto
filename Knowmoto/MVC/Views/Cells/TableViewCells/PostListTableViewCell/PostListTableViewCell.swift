//
//  PostListTableViewCell.swift
//  Knowmoto
//
//  Created by Apple on 31/07/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

enum ENUM_ALLOW_ON_WALL:Int{
    case rejected = 0
    case pending = 1
    case accepted = 2
}

enum ENUM_POST_MORE_OPTIONS:String{
    case report = "Report"
    case reported = "Reported"
    case edit = "Edit"
    case delete = "Delete"
    case share = "Share"
}

class PostListTableViewCell: UITableViewCell {
    
    //MARK:- Outlets
    
    @IBOutlet weak var btnAllowOnWall: KnomotButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var lblTimeSince: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imageViewUserProfilePic: KnowmotoUIImageView!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblPostTitle: UILabel!
    
    
    //Mark:- Properties
    
    var carsCollectionViewDataSource:CollectionViewDataSource?
    var model:Any?{
        didSet{
            self.configureCell()
        }
    }
    private var pics:[ImageUrlModel]?{
        didSet{
            
            pageControl.isHidden = /self.pics?.count < 2
            pageControl.numberOfPages = self.pics?.count ?? 0
            carsCollectionViewDataSource?.items = pics
            collectionView.reloadData()
        }
    }
    var isFromAllowPostOnWall:Bool = false
    var isListingView:Bool = false
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        
        setupUI()
    }
    
    func setupUI(){
        
        if carsCollectionViewDataSource == nil{
            
            self.configureCollectionView()
            
        }
        
        
        if !isListingView{
            
            imageViewUserProfilePic.addTapGesture(target: self, action: #selector(self.didTapUser(sender:)))
            lblUserName.addTapGesture(target: self, action: #selector(self.didTapUser(sender:)))
            
        }
    }
    
    @objc func didTapUser(sender:UIButton){
        
        debugPrint("user profile")
        self.redirectToOUserProfielDetailVC(item: (model as? PostList)?.user)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        
        imageViewUserProfilePic.image = nil
        
    }
    
    private func configureCell(){
        
        if let post = model as? PostList{
            
            self.pics = post.image
            lblLocation.text = post.place
            lblUserName.text = post.user?.userName
            lblPostTitle.text = post.title
            lblTimeSince.text = post.createdAt?.toDate().timeAgoSince()
            
            imageViewUserProfilePic.loadImage(nameInitial:/post.user?.userName,key: /post.user?.image?.thumb,isLoadWithSignedUrl:false,cacheKey:/post.user?.image?.thumbImageKey)
            lblPostTitle.addTapGesture(target: self, action: #selector(self.actionCarDetail))
            
            
            
        }
        
    }
    
    public func setStateOfAllowButton(state:ENUM_ALLOW_ON_WALL){
        
        switch state {
            
        case .accepted:
        
            btnAllowOnWall.backgroundColor = UIColor.RedColor!
            btnAllowOnWall.setTitle("Remove from wall", for: .normal)
            
        case .pending,.rejected:
            
            btnAllowOnWall.backgroundColor = UIColor.BlueColor!
            btnAllowOnWall.setTitle("Allow on wall", for: .normal)
        }
        
    }
    
    @objc func actionCarDetail(){
        
        let vc = ENUM_STORYBOARD<CarDetailSegmentedVC>.car.instantiateVC()
        vc.vehicleId = (model as? PostList)?.vehicleID?.id
        vc.isFromCarDetail = true
        self.topMostVC?.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func configureCollectionView(){ //Configuring collection View cell
        
        let cellHeight:CGFloat = 256
        let cellWidth:CGFloat = (UIScreen.main.bounds.width)
        
        let identifier = String(describing: PostCarsCollectionViewCell.self)
        collectionView.registerNibCollectionCell(nibName: identifier)
        
        carsCollectionViewDataSource = CollectionViewDataSource(items: pics, collectionView: collectionView, cellIdentifier: identifier, headerIdentifier: nil, cellHeight: cellHeight, cellWidth: cellWidth, configureCellBlock: { (_cell, item, indexPath) in
            
            let cell = _cell as? PostCarsCollectionViewCell
            cell?.isLoadThumb = false
            cell?.model = item
            
            
        }, aRowSelectedListener: { [weak self] (indexPath, item) in
            
            self?.showImagePreview(intial: indexPath.item)
            
            }, willDisplayCell: nil, scrollViewDelegate: { [weak self] (scrollView) in
                
                guard let indexPath = self?.collectionView.getVisibleIndexOnScroll() else {return}
                self?.pageControl.currentPage = indexPath.item
                
        })
        
        collectionView.dataSource = carsCollectionViewDataSource
        collectionView.delegate = carsCollectionViewDataSource
        collectionView.reloadData()
        
    }
    
    func showImagePreview(intial:Int){
        
        var arr = [INSPhoto]()
        
        for image in pics ?? []{
            
            arr.append(INSPhoto.init(imageURL: URL.init(string: /image.original), thumbnailImageURL: URL.init(string: /image.thumb),cacheKey:image.originalImageKey))
            
        }
        
        let galleryPreview = INSPhotosViewController(photos: arr, initialPhoto: arr[intial], referenceView: topMostVC?.view)
        
        topMostVC?.present(galleryPreview, animated: true, completion: nil)
        
    }
    
}
