//
//  TrendingCarCollectionViewCell.swift
//  Knowmoto
//
//  Created by cbl16 on 21/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class TrendingCarCollectionViewCell: UITableViewCell {
    
    //MARK:- OUTLETS
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK:- PROPERTIES
    
    var collectionDataSource:CollectionViewDataSource?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureCell()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    //MARK:- CONFIGURE COLLECTION CELL
    func configureCell(){
        
        // set cell spacing
        let cellSpacing:CGFloat = 16
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 18, bottom: 10, right: 0)
        
        // set cel height and width
        let cellWidth:CGFloat = (UIScreen.main.bounds.width - ((cellSpacing * 3) + 4))/2
        let cellHeight:CGFloat = collectionView.frame.width/2 - 10
        
        
        // identifier and Xib registration
        let identifier = String(describing: CarsListCollectionViewCell.self)
        collectionView.registerNibCollectionCell(nibName: identifier)
        
        collectionDataSource = CollectionViewDataSource(items:["","",""], collectionView: collectionView, cellIdentifier: identifier, headerIdentifier: nil
            , cellHeight: cellHeight,cellWidth:cellWidth, configureCellBlock:{(cell, item, indexPath) in
                
                // get cell data
                if let _cell = cell as? CarsListCollectionViewCell {
                    _cell.lblTitle.text = "Model S"
                }
                
        }, aRowSelectedListener:nil , willDisplayCell:nil , scrollViewDelegate:nil )
        
        collectionView.dataSource = collectionDataSource
        collectionView.delegate = collectionDataSource
        collectionView.reloadData()
    }
    
}