//
//  TagTableViewCell.swift
//  Knowmoto
//
//  Created by Apple on 12/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

protocol TagTableViewCellDelegate:class {
    func didSelectDeselectTag(model:BrandOrCarModel?)
}

class TagTableViewCell: UITableViewCell {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK:- Properties
    
    var collectionViewDataSource:CollectionViewDataSource?
    var items = [Any](){
        didSet{
            if collectionViewDataSource == nil{
                self.configureCollectionView()
            }else{
                self.collectionViewDataSource?.items = items
                self.collectionView.reloadData()
            }
        }
    }
    var delegate:TagTableViewCellDelegate?
    var isHideCrossButton:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        
        self.layoutIfNeeded()
        collectionView.layoutIfNeeded()
        
        let contentSize = collectionView.collectionViewLayout.collectionViewContentSize
        let padding:CGFloat = 0.0
        return CGSize(width: contentSize.width, height: contentSize.height + padding)
    }
    
    func configureCollectionView(){ //Configuring collection View cell
        
        //        flowLayout?.estimatedItemSize = CGSize(width: 80.0, height: 56.0)
        flowLayout?.sectionInset = UIEdgeInsets(top: 4.0, left: 16, bottom: 0, right: 16.0)
        flowLayout?.minimumLineSpacing = 8.0
        flowLayout?.minimumInteritemSpacing = 16.0
        
        
        let identifier = String(describing: TagCollectionViewCell.self)
        collectionView.registerNibCollectionCell(nibName: identifier)
        let cellHeight:CGFloat = 44.0
        let leftRightTotalPadding:CGFloat = 40.0
        
        collectionViewDataSource = CollectionViewDataSource(items: items, collectionView: collectionView, cellIdentifier: identifier, headerIdentifier: nil, cellHeight: cellHeight, cellWidth: 56.0, configureCellBlock: { (_cell, item, indexPath) in
            
            
            let cell = _cell as? TagCollectionViewCell
            cell?.recentTag = item
            
        }, aRowSelectedListener: { [weak self] (indexPath, item) in
            
            guard let model = self?.items[indexPath.row] as? SearchDataModel else {return}
        
            let searchType = ENUM_MAIN_SEARCH_TYPE(rawValue: /model.type) ?? .make
            
            switch searchType{
                
            case .color:
                
                self?.redirectToCarsList(item: model)
                
                break
                
            case .feature: // as tag
                
                self?.redirectToCarsList(item: model)
                
                break
                
            case .make,.model:
                
                self?.redirectToMakeModelListVC(item: model)
                
                break
                
            case .vehicle:
                
                self?.redirectToVehicleDetail(item: model)
                
                break
                
            case .sponsors:
                
                self?.redirectToCarsList(item: model)
                break
                
            default:
                break
                
            }
            
            
//            //unselect previous selected cell
//            if let index = self?.items.firstIndex(where: {/$0.isSelected == true}){
//
//                self?.items[index].isSelected = false
//
//                self?.delegate?.didSelectDeselectTag(model: self?.items[index])
//
//                let cell = (self?.collectionView.cellForItem(at: IndexPath.init(item: index, section: 0)) as? TagCollectionViewCell) //accessing direct cell
//
//                if let model = self?.items[index]{
//
//                    cell?.model = model
//                }
//
//
//
//                if indexPath.item == index{
//                    return
//                }
//
//
//            }
//
//            //selecting new selected cell
//            guard let model = item as? BrandOrCarModel else {return}
//
//            model.isSelected = !(/model.isSelected) // set selected
//
//            let cell = (self?.collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell) //accessing direct cell
//
//            cell?.model = model
//            self?.delegate?.didSelectDeselectTag(model: model)
        

            
        }, willDisplayCell: nil, scrollViewDelegate: nil)
        
  
        collectionViewDataSource?.didSizeForItemAt = { [weak self] (indexPath) ->CGSize in
            
            let leftIconPadding:CGFloat = 32.0
            
            if let text = ((self?.items[indexPath.item]) as? SearchDataModel)?.tagName{ //as modal type handling
                
                let cellWidth = (text.widthOfString(font: ENUM_APP_FONT.bold.size(14))) + leftRightTotalPadding + leftIconPadding
                
                return CGSize(width: cellWidth, height: cellHeight)
                
            }else if let text = (self?.items[indexPath.item]) as? String{ //as string type handling
                
                let cellWidth = (text.widthOfString(font: ENUM_APP_FONT.bold.size(14))) + leftRightTotalPadding + leftIconPadding
                
                return CGSize(width: cellWidth, height: cellHeight)
                
            }
            
            return CGSize(width: 56.0, height: 56.0)
        }
        
        collectionView.dataSource = collectionViewDataSource
        collectionView.delegate = collectionViewDataSource
        self.collectionView.reloadData()
        
    }
    
    func redirectToVehicleDetail(item:SearchDataModel){
        
        let vc = ENUM_STORYBOARD<CarDetailSegmentedVC>.car.instantiateVC()
        
        vc.vehicleId = item.id
        vc.isFromCarDetail = true
        
        topMostVC?.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    //redirect to custom layout cars list
    func redirectToCarsList(item:SearchDataModel){
        
        let vc = ENUM_STORYBOARD<VehiclesCollectionLayoutListVC>.car.instantiateVC()
        vc.searchData = item
        topMostVC?.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    //redirect to make modal list
    func redirectToMakeModelListVC(item:SearchDataModel){
        
        let vc = ENUM_STORYBOARD<MakeModelPostListsSegmentedVC>.car.instantiateVC()
        vc.searchData = item
        
        topMostVC?.navigationController?.pushViewController(vc, animated: true)
    }
    
}
