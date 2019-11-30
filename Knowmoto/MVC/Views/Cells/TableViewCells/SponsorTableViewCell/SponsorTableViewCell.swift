//
//  SponsorTableViewCell.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/14/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

protocol SponsorTableViewCellDelegate:class {
    
    func didRemoveSponsor(index:Int)
    
}

class SponsorTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK:- Properties
    
    var isFromCarDetail:Bool = false
    var isHideRemoveButton:Bool = false
    var delegate:SponsorTableViewCellDelegate?
    var dataSourceCollectionView:CollectionViewDataSource?
    var items = [FeaturesListModel](){
        didSet{
            
            if dataSourceCollectionView == nil{
                
            self.configureCollectionView()
                
            }else{
                
                dataSourceCollectionView?.items = items
                self.collectionView.reloadData()
                
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
          self.configureCollectionView()
    }

    
    func configureCollectionView(){ //Configuring collection View cell
        
        
        let identifier = String(describing: SponsorCollectionViewCell.self)
        collectionView.registerNibCollectionCell(nibName: identifier)
        
        let cellSpacing:CGFloat = 16.0
        let additional4thCellWidth:CGFloat = 32.0
        let cellWidth:CGFloat = (UIScreen.main.bounds.width - ((cellSpacing * 3) + additional4thCellWidth))/3
        
        let cellHeight:CGFloat = cellWidth + 36.0
        
        dataSourceCollectionView = CollectionViewDataSource(items: items, collectionView: collectionView, cellIdentifier: identifier, headerIdentifier: nil, cellHeight: cellHeight, cellWidth: cellWidth, configureCellBlock: { [weak self] (_cell, item, indexPath) in
            
            
            let cell = _cell as? SponsorCollectionViewCell
            
            cell?.collectionView = self?.collectionView
            cell?.isFromCarDetail = /self?.isFromCarDetail
            cell?.btnRemove.isHidden = /self?.isHideRemoveButton
            cell?.btnRemove.addTarget(self, action: #selector(self?.actionRemoveSponsor(sender:)), for: .touchUpInside)
            cell?.configureSponsorCell(indexPath: indexPath, item: item)
       
            
        }, aRowSelectedListener: { [weak self] (indexPath, item) in

            
            
            }, willDisplayCell: nil, scrollViewDelegate: nil)
        
        
        collectionView.dataSource = dataSourceCollectionView
        collectionView.delegate = dataSourceCollectionView
        self.collectionView.reloadData()
        
    }
    
    @objc func actionRemoveSponsor(sender:UIButton){
   
        self.collectionView.performBatchUpdates({
            
            self.items.remove(at: sender.tag)
            self.dataSourceCollectionView?.items = self.items
            self.collectionView.deleteItems(at: [IndexPath.init(item: sender.tag, section: 0)])
            
        }) { (_) in
            
            self.collectionView.reloadData()
            self.delegate?.didRemoveSponsor(index: sender.tag)
            
        }

        
    }
    
    
}
