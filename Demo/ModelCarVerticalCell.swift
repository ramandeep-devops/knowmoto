
//  ModelCarVerticalCell.swift
//  Knowmoto
//  Created by cbl16 on 18/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.

import UIKit

class ModelCarVerticalCell: UITableViewCell {
    
    //MARK:- OUTLETS
    
    @IBOutlet weak var collectionConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK:- PROPERTIES
    
    var collectionHieght:CGFloat?
    var collectionViewDataSource: CollectionViewDataSource?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //set collectionView
        self.configureCollectionView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    //MARK:- CELL CONFIGURATIONS
    
    func configureCollectionView(){ //Configuring collection View cell
        
        // set cell spacing
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 14, bottom: 20, right: 16)
        
        // set cell hieght and width
        let cellSpacing:CGFloat = 16
        let cellWidth:CGFloat = (UIScreen.main.bounds.width - ((cellSpacing * 4)))/3 - 2
        let cellHeight:CGFloat = cellWidth
        
        // set identifier and xib registration
        let identifier = String(describing: PostCarsCollectionViewCell.self)
        collectionView.registerNibCollectionCell(nibName: identifier)
        
        // send data for collection cell
        collectionViewDataSource = CollectionViewDataSource(items: ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""], collectionView: collectionView, cellIdentifier: identifier, headerIdentifier: nil, cellHeight: cellHeight, cellWidth: cellWidth, configureCellBlock: { (_cell, item, indexPath) in
            
            // get cell data
            if  let cell = _cell as? PostCarsCollectionViewCell {
                // set images  corner radius
//                cell.imgPostCar.layer.cornerRadius = 4
//                cell.imgPostCar.clipsToBounds = true
            }
            
        }, aRowSelectedListener: { [weak self] (indexPath, item) in
            
            }, willDisplayCell: nil, scrollViewDelegate: nil)
        
        collectionHieght =  collectionView.contentSize.height
        collectionView.dataSource = collectionViewDataSource
        collectionView.delegate = collectionViewDataSource
        self.collectionView.reloadData()
    }
}
