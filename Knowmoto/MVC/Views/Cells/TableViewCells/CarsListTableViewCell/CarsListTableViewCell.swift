//
//  CarsListTableViewCell.swift
//  Knowmoto
//
//  Created by Apple on 31/07/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class CarsListTableViewCell: UITableViewCell {
    
    //MARK:- Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK:- Properties

    var isLoadWithSignedUrl:Bool = false
    var numberOfcellInRow:Int = 2
    var carsCollectionViewDataSource:CollectionViewDataSource?
    var arrayCarListItems = [Any](){
        didSet{
            
//            if carsCollectionViewDataSource == nil{
                self.configureCarsListCollectionView()
//            }else{
//            self.carsCollectionViewDataSource?.items = arrayCarListItems
//            self.collectionView.reloadData()
//            }
        }
    }
    var arrayPicsListItems = [Any](){
        didSet{
            if carsCollectionViewDataSource == nil{
                self.configurePicsListCollectionView()
            }else{
                self.carsCollectionViewDataSource?.items = arrayPicsListItems
                self.collectionView.reloadData()
            }
        }
    }
    
    var arrayMakeListItems = [Any](){
        didSet{
//            if carsCollectionViewDataSource == nil{
                self.configureMakeListCollectionView()
//            }else{
//                self.carsCollectionViewDataSource?.items = arrayMakeListItems
//                self.collectionView.reloadData()
//            }
        }
    }
    
    
    
    //MARK:-UItableview cell lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configurePicsListCollectionView(){
        
        let cellSpacing:CGFloat = 16
        
        let cellWidth:CGFloat = (UIScreen.main.bounds.width - ((cellSpacing * 3) + 4))/CGFloat(numberOfcellInRow)
        let cellHeight:CGFloat = cellWidth //184
        
        let identifier = String(describing: PostCarsCollectionViewCell.self)
        collectionView.registerNibCollectionCell(nibName: identifier)
        
        carsCollectionViewDataSource = CollectionViewDataSource(items: arrayPicsListItems, collectionView: collectionView, cellIdentifier: identifier, headerIdentifier: nil, cellHeight: cellHeight, cellWidth: cellWidth, configureCellBlock: { [weak self] (_cell, item, indexPath) in
            
            if let cell = _cell as? PostCarsCollectionViewCell{
                
                cell.isLoadWithSignedUrl = self?.isLoadWithSignedUrl ?? false
                cell.model = item
                cell.imageViewCar.layer.cornerRadius = 8
                cell.imageViewCar.clipsToBounds = true
            }
            
            
        }, aRowSelectedListener: { (indexPath, item) in
            
            self.showImagePreview(intial: indexPath.item)
            
        }, willDisplayCell: nil, scrollViewDelegate: nil)
        
        collectionView.dataSource = carsCollectionViewDataSource
        collectionView.delegate = carsCollectionViewDataSource
        collectionView.reloadData()
        
    }
    
    func showImagePreview(intial:Int){
        
        var arr = [INSPhoto]()
        
        for image in arrayPicsListItems as? [ImageUrlModel] ?? []{
            
            arr.append(INSPhoto.init(imageURL: URL.init(string: /image.original), thumbnailImageURL: URL.init(string: /image.original),cacheKey:image.original))
            
        }
        
        let galleryPreview = INSPhotosViewController(photos: arr, initialPhoto: arr[intial], referenceView: topMostVC?.view)
        
        topMostVC?.present(galleryPreview, animated: true, completion: nil)
        
    }
    
    
    func configureCarsListCollectionView(){ //Configuring car list collection View
        
        let cellSpacing:CGFloat = 16
        let cellHeight:CGFloat = self.contentView.bounds.height //184
        let cellWidth:CGFloat = (UIScreen.main.bounds.width - ((cellSpacing * 3) + 4))/CGFloat(numberOfcellInRow)
        
        let identifier = String(describing: CarsListCollectionViewCell.self)
        collectionView.registerNibCollectionCell(nibName: identifier)
        
        carsCollectionViewDataSource = CollectionViewDataSource(items: arrayCarListItems, collectionView: collectionView, cellIdentifier: identifier, headerIdentifier: nil, cellHeight: cellHeight, cellWidth: cellWidth, configureCellBlock: { (_cell, item, indexPath) in
            
            if let cell = _cell as? CarsListCollectionViewCell{
                
                cell.model = item
                
            }
           
            
        }, aRowSelectedListener: { (indexPath, item) in
            
            let vc = ENUM_STORYBOARD<CarDetailSegmentedVC>.car.instantiateVC()
            
            vc.carData = self.arrayCarListItems[indexPath.row] as? CarListDataModel
            vc.isFromCarDetail = true
 
            self.topMostVC?.navigationController?.pushViewController(vc, animated: true)
            
        }, willDisplayCell: nil, scrollViewDelegate: nil)
        
        carsCollectionViewDataSource?.isEnableHighlightAffect = true
        
        collectionView.dataSource = carsCollectionViewDataSource
        collectionView.delegate = carsCollectionViewDataSource
        collectionView.reloadData()
        
    }
    
    func configureMakeListCollectionView(){ //Configuring car list collection View
        
        let cellSpacing:CGFloat = 16
        let cellHeight:CGFloat = self.contentView.bounds.height //184
        let cellWidth:CGFloat = (UIScreen.main.bounds.width - ((cellSpacing * 3) + 4))/CGFloat(numberOfcellInRow)
        
        let identifier = String(describing: CarsCollectionViewCell.self)
        collectionView.registerNibCollectionCell(nibName: identifier)
        
        carsCollectionViewDataSource = CollectionViewDataSource(items: arrayMakeListItems, collectionView: collectionView, cellIdentifier: identifier, headerIdentifier: nil, cellHeight: cellHeight, cellWidth: cellWidth, configureCellBlock: { (_cell, item, indexPath) in
            
            if let cell = _cell as? CarsCollectionViewCell{
                
                cell.isMake = true
                cell.model = item
                
            }
       
        }, aRowSelectedListener: { (indexPath, item) in

            let searchData = SearchDataModel.init(data: self.arrayMakeListItems[indexPath.item] as! CarListDataModel)
            self.redirectToMakeModelListVC(item: searchData)

            
        }, willDisplayCell: nil, scrollViewDelegate: nil)
        
        carsCollectionViewDataSource?.isEnableHighlightAffect = true
        
        collectionView.dataSource = carsCollectionViewDataSource
        collectionView.delegate = carsCollectionViewDataSource
        collectionView.reloadData()
        
    }
    
    //redirect to make modal list
    func redirectToMakeModelListVC(item:SearchDataModel){
        
        let vc = ENUM_STORYBOARD<MakeModelPostListsSegmentedVC>.car.instantiateVC()
        vc.searchData = item
       topMostVC?.navigationController?.pushViewController(vc, animated: true)
    }
    
}
