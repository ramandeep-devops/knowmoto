//
//  PhotosVC.swift
//  CSFHealth
//
//  Created by Rohit Prajapati on 22/07/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import Photos

protocol PhotosVCDelegate:class {
    func didRemovePic(newArray:Any?)
}

class PhotosVC: BaseVC,PhotosVCDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    
    //MARK: Property
    var arrayGallery:PHFetchResult<PHAsset>!{
        didSet{
            arrayGallery.count == 0 ? self.setCollectionViewBackgroundView(collectionView: photosCollectionView, noDataFoundText: "No Photos found!".localized) : (self.photosCollectionView.backgroundView = nil)
        }
    }
    var selectedImages:[ImageUpload] = []
    
    var phMediaType: PHAssetMediaType?
    let dispatchGroup = DispatchGroup()
    var maxNumberOfPhotos:Int = 5
    var selectedPhotosCount:Int{
        return /self.photosCollectionView.indexPathsForSelectedItems?.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        intialSetup()
        
    }
    
    func intialSetup(){
        
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
        
        checkGalleryPermission()
        configureExploreCV()
        
        actionDismiss()
        actionBlockNext()
    }
    
    
    func checkGalleryPermission(){
        
        
        CheckPermission.shared.permission(For: PermissionType.photos, completion: { [weak self] (isGranted) in
            
            DispatchQueue.main.async {
                
                if isGranted {
                    
                    self?.stackViewPermission.isHidden = true
                    self?.grabPhotos(mediaType: .image)
                    
                } else {
                    
                    self?.stackViewPermission.isHidden = false
                    
                    //                    self?.openAlertForSettings(for: .photos)
                    
                }
                
            }
        })
        
    }
    
    
    func didRemovePic(newArray: Any?) {
        
        //        self.selectedImages = (newArray as? [ImageUpload]) ?? []
        //        self.photosCollectionView.reloadData()
        
    }
}

//MARK: Functions
extension PhotosVC {
    
    func actionDismiss(){
        
        headerView.headerView.didTapLeftButton = { [weak self] (sender) in
            
            self?.navigationController?.popViewController(animated: true, completion: {[weak self] in
                self?.switchTab(tab: lastSelectedTab)
            })
            
            //            self?.dismiss(animated: true, completion: { [weak self] in
            //
            //                self?.switchTab(tab: lastSelectedTab)
            //
            //            })
        }
        
    }
    
    func actionBlockNext(){
        
        headerView.headerView.didTapRightButton = { [weak self] (sender) in
            
            self?.selectedImages = []
            
            let selectedIndexPaths = (self?.photosCollectionView.indexPathsForSelectedItems ?? []).map({$0.item})
            let selectedAssets = self?.arrayGallery.objects(at: IndexSet(selectedIndexPaths))
            
            self?.startAnimateLoader()
            
            for asset in selectedAssets ?? []{
                
                self?.dispatchGroup.enter()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    
                    asset.getOrginalImage(complition: { [weak self] (image) in
                        
                        self?.dispatchGroup.leave()
                        
                        self?.selectedImages.append(ImageUpload.init(image: image))
                        
                        
                    })
                    
                })
                
                
            }
            
            self?.dispatchGroup.notify(queue: .main, execute: {
                
                self?.stopAnimating()
                
                let vc = ENUM_STORYBOARD<PostVC>.post.instantiateVC()
                vc.arrayPics = self?.selectedImages ?? []
                vc.delegate = self
                self?.navigationController?.pushViewController(vc, animated: true)
                
            })
            
            
        }
        
    }
    
    func setSelectedCount(){
        
        let imageArrayCount = self.photosCollectionView.indexPathsForSelectedItems ?? []
        
        headerView.headerView.btnRight?.isHidden = imageArrayCount.isEmpty
        
        headerView.headerView.lblTitle?.text = imageArrayCount.isEmpty ? "" : imageArrayCount.count == 1 ? [imageArrayCount.count.toString,"pic selected".localized].joined(separator: " ") : [imageArrayCount.count.toString,"pics selected".localized].joined(separator: " ")
        
    }
    
    
    func configureExploreCV() {
        
        let identifier = String(describing: ImageCollectionViewCell.self)
        
        photosCollectionView.allowsMultipleSelection = true
        photosCollectionView.registerNibCollectionCell(nibName: identifier)
        
    }
    
    
}

//MARK:- Get gallery photos

extension PhotosVC{
    
    func grabPhotos(mediaType: PHAssetMediaType) {
        
        let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        if let fetchResult : PHFetchResult = PHAsset.fetchAssets(with: mediaType, options: fetchOptions) {
            
            self.arrayGallery = fetchResult
            
            DispatchQueue.main.async {
                
                self.photosCollectionView.reloadData()
                
            }
            
        }
        
    }
    
}

extension PhotosVC:UICollectionViewDataSource,UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let photos = self.arrayGallery{
            return photos.count
        }
        return 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier = String(describing: ImageCollectionViewCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! ImageCollectionViewCell
        
        cell.galleryData = self.arrayGallery.object(at: indexPath.row)
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        if selectedPhotosCount == maxNumberOfPhotos{
            Toast.show(text: "Maximum limit reached".localized, type: .error)
        }
        
        return /self.photosCollectionView.indexPathsForSelectedItems?.count < maxNumberOfPhotos
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if /self.photosCollectionView.indexPathsForSelectedItems?.count <= maxNumberOfPhotos{
            
            self.setSelectedCount()
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        self.setSelectedCount()
        
    }
    
}

extension PhotosVC: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellSpacing:CGFloat = 16
        let noOfCellsInRow:CGFloat = 3
        let cellWidth = (UIScreen.main.bounds.width - (cellSpacing * (noOfCellsInRow + 1.0)))/noOfCellsInRow
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
