//
//  ManageInterestVC.swift
//  Knowmoto
//
//  Created by cbl16 on 10/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.

import UIKit

class ManageInterestVC: BaseVC {
    
    //MARK:- OUTLETS
    
    @IBOutlet weak var collectionTable: UICollectionView!
    
    //MARK:- PROPERTIES
    
    var arrayInterests:[Any] = []{
        didSet{
            collectionDataSource?.items = [arrayInterests]
            collectionTable.reloadData()
        }
    }
    var collectionDataSource:CollectionViewDataSourceForSections?
    
    //MARK:- LIFE CYCL METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if isFirstTime{
            
            self.configureCollectionView()
            isFirstTime = false
        }
        
        setData()
    }
    
    func setData(){
        
        arrayInterests = userData?.interestedMakes ?? []
        
    }
    
    
    //MARK:- FUNCTIONS
    
    func configureCollectionView(){
        
        //cell register
        let identifier = String(describing: ManageInterstCollectionCell.self)
        collectionTable.registerNibCollectionCell(nibName: identifier)
        
        //Footer view register
        let footerIdentifier = String(describing: AddMoreButtonCollectionReusableView.self)
        collectionTable.register(UINib(nibName: footerIdentifier, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerIdentifier)
        
        //layout configuration
        let cellSpacing:CGFloat = 16.0
        
        let cellWidth:CGFloat = (collectionTable.frame.width - (cellSpacing * 3.0))/2
        let cellHeight:CGFloat = cellWidth - 68.0
        
        collectionDataSource = CollectionViewDataSourceForSections(items:[arrayInterests], collectionView: collectionTable, cellIdentifier: identifier, headerIdentifier: nil, cellHeight: cellHeight,cellWidth:cellWidth, configureCellBlock:{(cell, item, indexPath) in
            
            let _cell = cell as? ManageInterstCollectionCell
            _cell?.manageInterestData = item
            
            
        }, aRowSelectedListener:{ [weak self] (indexPath,item) in
            
            //            let vc = ENUM_STORYBOARD<SelectMakeOrBrandOrModelVC>.car.instantiateVC()
            //
            //            vc.vcType = ENUM_CAR_SELECTION_TYPE.model
            //            vc.selectedData = (item as? [ModelSelectedInterestedMakes])?[indexPath.row].modelIds ?? []
            //            vc.makeDataOfEditInterest = (item as? [ModelSelectedInterestedMakes])?[indexPath.row].makeId
            //            vc.isFromEditInterest = true
            //
            //            self?.navigationController?.pushViewController(vc, animated: true)
            
            let vc = ENUM_STORYBOARD<InterestModelVC>.car.instantiateVC()
            vc.makeData = self?.arrayInterests[indexPath.row] as? ModelSelectedInterestedMakes
            
            self?.navigationController?.pushViewController(vc, animated: true)
            
            
            }, willDisplayCell:nil , scrollViewDelegate:nil )
        
        collectionDataSource?.footerHeight = 48.0
        
        collectionDataSource?.headerFooterInSection = { [weak self] (indexPath) -> UICollectionReusableView in
            
            let footerView = self?.collectionTable.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerIdentifier, for: indexPath) ?? UICollectionReusableView()
            
            let addMoreButton = (footerView as? AddMoreButtonCollectionReusableView)?.viewWithTag(1) as? UIButton
            addMoreButton?.setTitle("+ Add more".localized, for: .normal)
            
            addMoreButton?.addTarget(self, action: #selector(self?.actionAddMore), for: .touchUpInside)
            
            return footerView
        }
        
        
        collectionTable.dataSource = collectionDataSource
        collectionTable.delegate = collectionDataSource
        collectionTable.reloadData()
    }
    
    @objc func actionAddMore(){
        
        let vc = ENUM_STORYBOARD<SelectMakeOrBrandOrModelVC>.car.instantiateVC()
        vc.vcType = ENUM_CAR_SELECTION_TYPE.make
//        vc.selectedData = userData?.interestedMakes
        vc.arrayRemoveFromList = userData?.interestedMakes?.map({$0.makeId!})
        vc.isFromEditInterest = true
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}


//MARK:- API
extension ManageInterestVC{
    
    
    
}
