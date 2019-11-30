//
//  CollectionViewDataSourceForSections.swift
//  Knowmoto
//
//  Created by Apple on 12/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit
typealias DidSizeForSectionAt = (_ section: Int) -> (CGSize)

class CollectionViewDataSourceForSections: CollectionViewDataSource {

    var headerFooterInSection:ViewForHeaderFooterInSection?
    var headerHeight:CGFloat? = 0.0
    var footerHeight:CGFloat? = 0.0
    var headerHeightForSectionAt:DidSizeForSectionAt?
    var footerHeightForSectionAt:DidSizeForSectionAt?
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (items as? Array<Any>)?.count ?? 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return ((items)?[section] as? Array<Any>)?.count ?? 0
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let identifier = cellIdentifier else {
            fatalError("Cell identifier not provided")
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as UICollectionViewCell
        if let block = self.configureCellBlock , let item: Any = (self.items?[indexPath.section] as? Array<Any>)?[indexPath.item]{
            block(cell , item , indexPath)
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            
            if let block = self.headerFooterInSection {
                
                
                return block(indexPath)
            }
            
            
            break
        case UICollectionView.elementKindSectionFooter:
            
            if let block = self.headerFooterInSection {
                
                
                return block(indexPath)
            }
            
        default:
            assert(false, "Unexpected element kind")
            
            
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if let block = footerHeightForSectionAt{
            return block(section)
        }
        return CGSize(width: collectionView.frame.width, height: footerHeight ?? 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if let block = headerHeightForSectionAt{
            return block(section)
        }
        return CGSize(width: collectionView.frame.width, height: headerHeight ?? 0.0)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let block = self.aRowSelectedListener, let item: Any = self.items?[(indexPath).section]{
            block(indexPath ,item)
        }
        
    }
    
}
