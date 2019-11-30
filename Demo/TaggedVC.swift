//
//  TaggedVC.swift
//  Knowmoto
//
//  Created by cbl16 on 22/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class TaggedVC: UIViewController {

    //MARK:- Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK:- Properties
    
    var taggedCollectionViewDataSource:CollectionViewDataSource?
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }

    
    func configureCollectionView(){ //Configuring collection View cell
        
        let cellHeight:CGFloat = 256
        let cellWidth:CGFloat = (UIScreen.main.bounds.width)
        
        let identifier = String(describing: PostCarsCollectionViewCell.self)
        collectionView.registerNibCollectionCell(nibName: identifier)
        
        taggedCollectionViewDataSource = CollectionViewDataSource(items: ["","","",""], collectionView: collectionView, cellIdentifier: identifier, headerIdentifier: nil, cellHeight: cellHeight, cellWidth: cellWidth, configureCellBlock: { (_cell, item, indexPath) in
            
           // let cell = _cell as? CarsListCollectionViewCell
            
            
        }, aRowSelectedListener: { (indexPath, item) in
            
            
        }, willDisplayCell: nil, scrollViewDelegate: nil)
        
        collectionView.dataSource = taggedCollectionViewDataSource
        collectionView.delegate = taggedCollectionViewDataSource
        collectionView.reloadData()
        
    }

}
