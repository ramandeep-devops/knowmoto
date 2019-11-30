//
//  PostVC.swift
//  Knowmoto
//
//  Created by Amandeep tirhima on 2019-08-16.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class PostVC: UIViewController {

    
    //MARK:- OUTLETS
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK:-PROPERTIES
    
    var collectionDataSource:CollectionViewDataSource?
    
    
    //MARK:-LIFE CYCLE METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
         self.configureCell()
        
    }
    
    //MARK:- ACTIONS
    
    @IBAction func didTapAttachCar(_ sender: Any) {
    }
    
    @IBAction func didTapAddLocation(_ sender: Any) {
    }
    
    //MARK:- EXTRA FUNCTIONS
    
    func configureCell(){
        
        let identifier = String(describing: PostCollectionCell.self)
        
        let cellHeight:CGFloat = collectionView.frame.height - 50
        let cellWidth:CGFloat = collectionView.frame.width - 100
        
        collectionDataSource = CollectionViewDataSource(items:["","",""], collectionView: collectionView, cellIdentifier: identifier, headerIdentifier: nil
            , cellHeight:cellHeight,cellWidth:cellWidth, configureCellBlock:{(cell, item, indexPath) in
                
        }, aRowSelectedListener:nil , willDisplayCell:nil , scrollViewDelegate:nil )
        
        collectionView.dataSource = collectionDataSource
        collectionView.delegate = collectionDataSource
        collectionView.reloadData()
    }
    
    
}
