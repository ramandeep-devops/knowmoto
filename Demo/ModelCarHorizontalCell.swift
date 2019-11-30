//
//  ModelCarHorizontalCell.swift
//  Knowmoto
//
//  Created by cbl16 on 18/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.


import UIKit

class ModelCarHorizontalCell: UITableViewCell {
    
    //MARK:- OUTLETS
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK:- PROPERTIES
    
    var collectionDataSource:CollectionViewDataSource?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        
            self.configureCell()
            
        }
    
    }

    
    //MARK:- CONFIGURE COLLECTION CELL
    func configureCell(){
        
        // set cell spacing
        let cellSpacing:CGFloat = 16
          collectionView.contentInset = UIEdgeInsets(top: 0, left: 18, bottom: 30, right: 0)

        // set cel height and width
        let cellWidth:CGFloat = (UIScreen.main.bounds.width - ((cellSpacing * 2) + 42.0))/2
        let cellHeight:CGFloat = self.collectionView.bounds.height - 24
        
        
        // identifier and Xib registration
        let identifier = String(describing: CarsListCollectionViewCell.self)
        collectionView.registerNibCollectionCell(nibName: identifier)
        
        collectionDataSource = CollectionViewDataSource(items:["","",""], collectionView: collectionView, cellIdentifier: identifier, headerIdentifier: nil
            , cellHeight: cellHeight,cellWidth:cellWidth, configureCellBlock:{(cell, item, indexPath) in
              
                // get cell data 
                if let _cell = cell as? CarsListCollectionViewCell {
                    _cell.lblLikesSubtitle.isHidden = true
                    _cell.lblTitle.text = "Model S"
                }
                
        }, aRowSelectedListener:nil , willDisplayCell:nil , scrollViewDelegate:nil )
        
        collectionView.dataSource = collectionDataSource
        collectionView.delegate = collectionDataSource
        collectionView.reloadData()
    }
}
