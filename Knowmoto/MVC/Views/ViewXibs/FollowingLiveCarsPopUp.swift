//
//  FollowingLiveCarsPopUp.swift
//  Knowmoto
//
//  Created by Apple on 26/09/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation

class FollowingLiveCarsPopUp:UIView{
    
    @IBOutlet weak var btnDrag: UIButton!
    @IBOutlet weak var imageViewIconLive: UIImageView!
    @IBOutlet weak var lblFollwedLiveCar: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var contentView: UIView!
    
    var collectionDataSource: CollectionViewDataSource?
    
    var isFromMyLive:Bool = false
    
    var arrayLiveCars:[CarListDataModel] = []{
        didSet{
            
            self.lblFollwedLiveCar.text = isFromMyLive ? "\(/arrayLiveCars.count) of your vehicles are live right now" : "\(/arrayLiveCars.count) of your followed vehicles are live right now"
            self.lblFollwedLiveCar.setLineSpacing(lineSpacing: 4.0)
            
            collectionDataSource?.items = arrayLiveCars
            collectionView.reloadData()
            
        }
    }
    var selectedCar:CarListDataModel?{
        didSet{
            
        }
    }
    var blockDidSelectCar:((CarListDataModel?)->())?
    var size:CGSize?
    
    func instanceFromNib() -> UIView {
        
        return UINib(nibName: "FollowingLiveCarsPopUp", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        size = frame.size
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(type(of: self).wasDragged(gestureRecognizer:)))
        
        
        Bundle.main.loadNibNamed("FollowingLiveCarsPopUp", owner: self, options: nil)
        
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        self.addSubview(contentView)
        
        
        self.addGestureRecognizer(gesture)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.configureCollectionView()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureCollectionView(){
        
        // set cell spacing
        let cellSpacing:CGFloat = 16
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 16, bottom: 0, right: 16)
        
        // set cel height and width
        let cellWidth:CGFloat = (UIScreen.main.bounds.width - ((cellSpacing * 3) + 32))/2
        let cellHeight:CGFloat = collectionView.bounds.height
        
        // identifier and Xib registration
        let identifier = String(describing: SponsorCollectionViewCell.self)
        collectionView.registerNibCollectionCell(nibName: identifier)
        
        self.selectedCar = self.selectedCar == nil && isFromMyLive ? self.arrayLiveCars.first : self.selectedCar
        self.blockDidSelectCar?(self.selectedCar)
        
        collectionDataSource = CollectionViewDataSource(items:arrayLiveCars, collectionView: collectionView, cellIdentifier: identifier, headerIdentifier: nil
            , cellHeight: cellHeight,cellWidth:cellWidth, configureCellBlock:{(cell, item, indexPath) in
                
                // get cell data
                if let _cell = cell as? SponsorCollectionViewCell {
                    //_cell.lblName.text = "Mustang"
                    _cell.clipsToBounds = false
                    _cell.configureGoLiveCell(model: item, selectedItem: self.selectedCar)
                    _cell.btnLike.isHidden = (item as? CarListDataModel)?.userID?.id == UserDefaultsManager.shared.currentUserId
                    _cell.btnRemove.isHidden = true
        
                    _cell.btnLike.tag = indexPath.item
                    _cell.btnLike.addTarget(self, action: #selector(self.actionLikeVehicle(sender:)), for: .touchUpInside)
                    
                }
                
        }, aRowSelectedListener:{ [weak self] (indexPath,item) in
            
            if /self?.selectedCar?.id != /self?.arrayLiveCars[indexPath.item].id{
                
                self?.selectedCar = self?.arrayLiveCars[indexPath.item]
//                self?.selectedCar = nil
                
            }else{
                
                self?.selectedCar = self?.arrayLiveCars[indexPath.item]
                
            }
            self?.collectionView.reloadData()
            
            self?.blockDidSelectCar?(self?.selectedCar)
            
            
            } , willDisplayCell:nil , scrollViewDelegate:nil )
        
        collectionView.dataSource = collectionDataSource
        collectionView.delegate = collectionDataSource
        collectionView.reloadData()
    }
    
    @objc func actionLikeVehicle(sender:UIButton){
    
    
        if /self.arrayLiveCars[sender.tag].likeByMe{
           
            self.arrayLiveCars[sender.tag].likeByMe = !(/self.arrayLiveCars[sender.tag].likeByMe)
            self.likeVehicleOf(id: /self.arrayLiveCars[sender.tag].id)
            
        }else{
            
            if KontaktBeaconDataSource.shared.checkBeaconAndStartDiscovering(alertMessage: "Please on your bluetooth, need to like the vehicle".localized){
                
                KontaktBeaconDataSource.shared.searchBeaconOf(loaderMessage:"Locating Vehicle",alertMessage:"No vehicle found in your 3m approximity, you should be close to the vehicle".localized,id: /arrayLiveCars[sender.tag].beaconID?.first?.beaconId) { [weak self] (isFound) in
                    
                    if isFound{
                        
                        self?.arrayLiveCars[sender.tag].likeByMe = !(/self?.arrayLiveCars[sender.tag].likeByMe)
                        self?.likeVehicleOf(id: /self?.arrayLiveCars[sender.tag].id)
                        
                    }
                    
                }
                
            }
            
        }
        
        
        
    }
    
    func likeVehicleOf(id:String){
        
        EP_Car.like_dislike(id: id, type: 2).request(success:{ (response) in
            
            self.collectionView.reloadData()
            
        })
        
    }
    
    func removeCarWhere(id:String){
        
        self.arrayLiveCars.removeAll(where: {$0.id == id})
        let newArray = self.arrayLiveCars
        self.arrayLiveCars = newArray
        //        collectionDataSource?.items = self.arrayLiveCars
        //        self.collectionView.reloadData()
        
    }
    
    func selectCarOf(id:String){
        
        if let selectedCar = self.arrayLiveCars.first(where:{$0.id == id}){
            
            if self.collectionView.numberOfItems(inSection: 0) > 0{
                
                self.selectedCar = selectedCar
                self.collectionView.reloadData()
                
            }
            
        }else{
            
            self.selectedCar = nil
            self.collectionView.reloadData()
            
        }
        
    }
    
    
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        
        let velocity = gestureRecognizer.velocity(in: self)
        var currentDirection: Int = 0
        
        debugPrint(velocity)
        
        if velocity.y > 600 {
            print("panning down")
            self.actionDrag(isOpen: false)
            return
        } else if velocity.y < -600 {
            
            self.actionDrag(isOpen: true)
            print("panning up")
            return
        }
        
        let distanceFromBottom = UIScreen.main.bounds.height - gestureRecognizer.view!.center.y
        
        if gestureRecognizer.state == UIGestureRecognizer.State.began || gestureRecognizer.state == UIGestureRecognizer.State.changed {
            
            let translation = gestureRecognizer.translation(in: self)
            debugPrint((distanceFromBottom - translation.y))
            if((distanceFromBottom - translation.y) > -40) && (distanceFromBottom - translation.y) < 112{
                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x, y: gestureRecognizer.view!.center.y + translation.y)
                gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self)
            }
        }
        
        
        
        self.collectionView.alpha = distanceFromBottom/110
        debugPrint("distance from bottom",distanceFromBottom)
        
        if gestureRecognizer.state == UIGestureRecognizer.State.ended{
            if distanceFromBottom > 25{
                self.actionDrag(isOpen: true)
                //                openOptionsPanel()
            }else{
                
                self.actionDrag(isOpen: false)
                //                closeOptionsPanel()
            }
        }
    }
    
    
    func actionDrag(isOpen:Bool){
        
        let collapseHeight:CGFloat = /UIDevice.isIPhoneXStyle ? 80.0 : 24.0

        let height:CGFloat = isOpen ? /self.size?.height : collapseHeight
        
        UIView.animate(withDuration: 0.2, animations: { [unowned self] in
            
            self.layoutIfNeeded()
            self.layoutSubviews()
            
            self.frame = CGRect(x: 0, y: /self.superview?.frame.maxY - height, width: UIScreen.main.bounds.width, height: /self.size?.height)
            
            self.collectionView.alpha = /isOpen ? 1.0 : 0.0
            
            self.layoutSubviews()
            
        }) { (_) in
            
            
        }
        
    }
    
}
