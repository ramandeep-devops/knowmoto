//
//  RecentSearchCell.swift
//  Knowmoto
//
//  Created by cbl16 on 21/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.


import UIKit

class RecentSearchCell: UITableViewCell {
    
    //MARK:- OUTLETS
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionConstraint: NSLayoutConstraint!
    
    //MARK:- PROPERTIES
    
    var collectionDataSource:CollectionViewDataSource?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // configure cell
        configureCell()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK:- CONFIGURE COLLECTION CELL
    func configureCell(){
                
        var arraySearch = ["Tesla","Lamborgini","red","Lamborghini Aventador SVJ Coupe"]
   
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        
        // set cel height and width
        let leftRightTotalPadding:CGFloat = 40.0
        //let cellSpacing:CGFloat = 16.0
        let cellHeight:CGFloat = 40
        
        // identifier and Xib registration
        let identifier = String(describing: TagCollectionViewCell.self)
        collectionView.registerNibCollectionCell(nibName: identifier)
        
        collectionDataSource = CollectionViewDataSource(items:arraySearch, collectionView: collectionView, cellIdentifier: identifier, headerIdentifier: nil
            , cellHeight: cellHeight,cellWidth:56.0, configureCellBlock:{(cell, item, indexPath) in
                
                // get cell data
                if let _cell = cell as? TagCollectionViewCell {
                    _cell.lblTagName.text = arraySearch[indexPath.row]
                    _cell.btnSelectedTag.isHidden = true
                    //_cell.btn
                }
                
        }, aRowSelectedListener:nil , willDisplayCell:nil , scrollViewDelegate:nil )
                
        collectionDataSource?.didSizeForItemAt = { [weak self] (indexPath) ->CGSize in
            
            if indexPath.section == 0{
                
                let tag = arraySearch[indexPath.row]
                
                let cellWidth = (tag.widthOfString(font: ENUM_APP_FONT.bold.size(14)) ) + leftRightTotalPadding
                
                return CGSize(width: cellWidth + 15, height: cellHeight)
            }else {
               return CGSize(width: /self?.collectionView.frame.width, height: cellHeight)
            }
        }
        
        collectionView.dataSource = collectionDataSource
        collectionView.delegate = collectionDataSource
        collectionView.reloadData()
    }
}
