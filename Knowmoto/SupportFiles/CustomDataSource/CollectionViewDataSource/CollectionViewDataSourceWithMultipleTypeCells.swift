//
//  CollectionViewDataSourceWithMultipleTypeCells.swift
//  Knowmoto
//
//  Created by Apple on 14/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation

class CollectionViewDataSourceWithMultipleTypeCells:CollectionViewDataSourceForSections{
    
    var identifiers:[String]?
    var arrayItemsDictionary:[String:Array<Any>?]
    
    
    init (arrayItemsDictionary:[String:Array<Any>?] , collectionView: UICollectionView?, cellHeight: CGFloat, cellWidth: CGFloat, identifiers: [String]? , configureCellBlock: ListCellConfigureBlock? , aRowSelectedListener:   DidSelectedRow?){
    
        self.identifiers = identifiers
        self.arrayItemsDictionary = arrayItemsDictionary
        
        super.init(items: nil, collectionView: collectionView, cellIdentifier: nil, headerIdentifier: nil, cellHeight: cellHeight, cellWidth: cellWidth, configureCellBlock: configureCellBlock, aRowSelectedListener: aRowSelectedListener, willDisplayCell: nil, scrollViewDelegate: nil)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return arrayItemsDictionary.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     
        
        return (arrayItemsDictionary[identifiers?[section] ?? ""] as? Array<Any>)?.count ?? 0
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let identifier = identifiers?[indexPath.section] else {
            fatalError("Cell identifier not provided")
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as UICollectionViewCell
        
        if let block = self.configureCellBlock , let item: Any = (self.arrayItemsDictionary[identifier] as? Array<Any>)?[indexPath.row]{
            block(cell , item , indexPath)
        }
        
        return cell
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let block = self.aRowSelectedListener, let item: Any = (self.arrayItemsDictionary[/identifiers?[indexPath.section]] as? Array<Any>)?[indexPath.item]{
            block(indexPath ,item)
        }
        
    }
    
}
