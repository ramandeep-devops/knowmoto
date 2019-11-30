//
//  PostVC.swift
//  Knowmoto
//
//  Created by Amandeep tirhima on 2019-08-16.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class PostVC: UIViewController,BookMarkCarsListVCDelegate {
    
    @IBOutlet weak var btnPost: KnomotButton!
    @IBOutlet weak var btnChangeAttachedCar: UIButton!
    @IBOutlet weak var btnChangeLocation: UIButton!
    
    @IBOutlet weak var btnAttachLocation: UIButton!
    @IBOutlet weak var btnAttachCar: UIButton!
    
    @IBOutlet weak var lblLocationAddress: UILabel!
    @IBOutlet weak var lblAttachedCar: UILabel!
    //MARK:- OUTLETS
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK:-PROPERTIES
    
    var collectionDataSource:CollectionViewDataSource?
    
    var arrayPics:[ImageUpload] = []
    var delegate:PhotosVCDelegate?
    
    var attachedCar:CarListDataModel?{
        didSet{
            
            btnAttachCar.setImage(nil, for: .normal)
            btnChangeAttachedCar.isHidden = false
            lblAttachedCar.text = attachedCar?.displayAppName
            btnPost.enableButton = attachedCar != nil && location != nil
            
        }
    }
    var location:LocationAddress?{
        didSet{
            
            btnAttachLocation.setImage(nil, for: .normal)
            btnChangeLocation.isHidden = false
            lblLocationAddress.text = /location?.address
            btnPost.enableButton = attachedCar != nil && location != nil
            
        }
    }

    //MARK:-LIFE CYCLE METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.btnChangeLocation.isHidden = true
        self.btnChangeAttachedCar.isHidden = true
        self.configureCollectionView()
    }
    
    
    
    //MARK:- ACTIONS
    
    @IBAction func didTapAttachCar(_ sender: Any) {
        
        let vc = ENUM_STORYBOARD<BookMarkCarsSegementedVC>.profile.instantiateVC()
        
        vc.delegate = self
        vc.selectedCar = self.attachedCar
        vc.isFromCreatePost = true
        vc.presentWithNavigationController()
        
    }
    
    @IBAction func didTapAddLocation(_ sender: Any) {
        
        
        let placePickerVC = ENUM_STORYBOARD<PlacePickerVC>.miscelleneous.instantiateVC()
        placePickerVC.selectedAddress = location?.address
        placePickerVC.searchType = [.district,.place]
        
        placePickerVC.didGetLocation = { [weak self] (location) in
            
            self?.location = location
            
        }
        
        self.present(placePickerVC, animated: true, completion: nil)
        
    }
    
    @IBAction func didTapPost(_ sender: UIButton) {
        
        var images:[ImageUrlModel] = []
        let jsonLocation = [location?.longitude,location?.latitude].toJsonString()
        let place = location?.address
        let vehicleId:String? = attachedCar?.id
        let displayName = attachedCar?.displayAppName
        
        let dispatchGroup = DispatchGroup()
     
        var uploadedCount = 1
        
        self.startAnimateLoader()
        self.setLoaderMessage(message: "Uploading Pics \(/uploadedCount) of \(/self.arrayPics.count)")
        
        for imageData in self.arrayPics{
            
            if let image = imageData.image{
                
                dispatchGroup.enter()
                
                _ = S3BucketHelper.shared.uploadImage(image: image) { (originalUrl, thumbnailUrl) in
               
//                    DispatchQueue.main.async {
                    
                        images.append(ImageUrlModel.init(original: originalUrl.getImageKey(), thumb: thumbnailUrl.getImageKey()))
                        
                        uploadedCount += 1
   
                        if uploadedCount <= /self.arrayPics.count{
                            
                            self.setLoaderMessage(message: "Uploading Pics \(/uploadedCount) of \(/self.arrayPics.count)")
                            
                        }
                    
                    defer{
                        dispatchGroup.leave()
                    }
                    
//                    }
                
                }
                
            }
            
        }
   
        
        dispatchGroup.notify(queue: .main) {
            
            self.setLoaderMessage(message: "Posting...".localized)
            
            debugPrint("Images uploaded")
            let jsonImages = JSONHelper<[ImageUrlModel]>().toDictionary(model: images)
            
            
            EP_Post.add_edit_post(id: nil, title: displayName, location: jsonLocation, place: place, image: jsonImages, vehicleId: vehicleId).request(loaderNeeded: false, successMessage: nil, success: { (response) in
                
                NotificationCenter.default.post(name: .RELOAD_POST, object: nil)
                self.stopAnimating()
                self.navigationController?.popToRootViewController(animated: true)
                
                
            }, error: ({ (error) in
                
                self.stopAnimating()
                
            }))
            
            
        }
        
        
        
        

        
    }
    
    //MARK:- EXTRA FUNCTIONS
    
    func configureCollectionView(){
        
        let identifier = String(describing: ImageCollectionViewCell.self)
        self.collectionView.registerNibCollectionCell(nibName: identifier)
        
        let cellHeight:CGFloat = collectionView.frame.height - 50
        let cellWidth:CGFloat = (UIScreen.main.bounds.width - (/arrayPics.count == 1 ? 28 : 60))
        
        collectionDataSource = CollectionViewDataSource(items:arrayPics, collectionView: collectionView, cellIdentifier: identifier, headerIdentifier: nil
            , cellHeight:cellHeight,cellWidth:cellWidth, configureCellBlock:{ [weak self] (cell, item, indexPath) in
                
                let _cell = cell as? ImageCollectionViewCell
                
                _cell?.btnRemove.isHidden = false
                _cell?.btnRemove.tag = indexPath.item
                _cell?.btnRemove.addTarget(self, action: #selector(self?.actionRemoveImage(sender:)), for: .touchUpInside)
                _cell?.imageViewPhoto.image = (item as? ImageUpload)?.image
                
        }, aRowSelectedListener:nil , willDisplayCell:nil , scrollViewDelegate:nil)
        
        collectionView.dataSource = collectionDataSource
        collectionView.delegate = collectionDataSource
        collectionView.reloadData()
    }
    
    @objc func actionRemoveImage(sender:UIButton){
        
        
        arrayPics.remove(at: sender.tag)
        self.collectionDataSource?.items = arrayPics
        
        
        self.collectionView.performBatchUpdates({ [weak self] in
            
            self?.collectionView.deleteItems(at: [IndexPath.init(item: sender.tag, section: 0)])
            
            if /self?.arrayPics.isEmpty{
                
                self?.navigationController?.popViewController(animated: true)
     
            }

        }) { [weak self] (_) in
            
            self?.delegate?.didRemovePic(newArray: self?.arrayPics)
           
            self?.collectionView.reloadData()
            
        }
        
        
    }
    
    func didSelectCar(car: Any?) {
        
        self.attachedCar = car as? CarListDataModel
        
        debugPrint(car)
        
    }
    
}
