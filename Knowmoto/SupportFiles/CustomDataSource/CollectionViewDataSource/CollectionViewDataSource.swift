//
//  CollectionViewDataSource.swift
//  SafeCity
//
//  Created by Aseem 13 on 29/10/15.
//  Copyright © 2015 Taran. All rights reserved.
//


import UIKit

typealias ScrollViewScrolled = (UIScrollView) -> ()
typealias WillDisplay = (_ indexPath: IndexPath) -> ()
typealias DidSizeForItemAt = (_ indexPath: IndexPath) -> (CGSize)
typealias DidMoveItemTo = (_ sourceIndexPath: IndexPath,_ destinationIndexPath:IndexPath) -> ()
typealias ViewForHeaderFooterInSection = (_ indexPath: IndexPath) -> (UICollectionReusableView)

class CollectionViewDataSource: NSObject  {
  
  var items: Array<Any>?
  var cellHeight: CGFloat = 0.0
  var cellWidth : CGFloat = 0.0
  var cellIdentifier  : String?
  var headerIdentifier: String?
  var collectionView  : UICollectionView?
  var scrollViewListener  : ScrollViewScrolled?
  var configureCellBlock  : ListCellConfigureBlock?
  var aRowSelectedListener: DidSelectedRow?
  var willDisplay         : WillDisplay?
  var scrollViewEndDeclerationListener  : ScrollViewScrolled?
  var didSizeForItemAt:DidSizeForItemAt?
  var isEnableHighlightAffect:Bool = false
  var canMoveItem:Bool = false
  var didMoveItemAt: DidMoveItemTo?
  

    
    init (items: Array<Any>?  , collectionView: UICollectionView? , cellIdentifier: String? , headerIdentifier: String? , cellHeight: CGFloat ,canMoveItem:Bool = false, cellWidth: CGFloat , configureCellBlock: ListCellConfigureBlock? , aRowSelectedListener:   DidSelectedRow? , willDisplayCell: WillDisplay? , scrollViewDelegate: ScrollViewScrolled?)  {
    
    self.collectionView = collectionView
    self.items = items
    self.cellIdentifier = cellIdentifier
    self.headerIdentifier = headerIdentifier
    self.cellWidth  = cellWidth
    self.cellHeight = cellHeight
    
    self.configureCellBlock     = configureCellBlock
    self.aRowSelectedListener   = aRowSelectedListener
    self.willDisplay            = willDisplayCell
    self.scrollViewListener     = scrollViewDelegate
        self.canMoveItem = canMoveItem
 
    
  }
  
  override init() {
    super.init()
  }
}

extension CollectionViewDataSource: UICollectionViewDelegate , UICollectionViewDataSource{
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    guard let identifier = cellIdentifier else {
      fatalError("Cell identifier not provided")
    }
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as UICollectionViewCell
    
    if let block = self.configureCellBlock , let item: Any = self.items?[indexPath.row]{
      block(cell , item , indexPath)
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.items?.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    if let block = self.aRowSelectedListener, let item: Any = self.items?[(indexPath).row]{
      block(indexPath ,item)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if let block = willDisplay {
      block(indexPath)
    }
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
    if let block = self.scrollViewListener {
      block(scrollView)
    }
  }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if let block = self.scrollViewEndDeclerationListener {
            block(scrollView)
        }
    }
  
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
        
        if let cell = collectionView.cellForItem(at: indexPath),isEnableHighlightAffect{
            
            UIView.animate(withDuration: 0.4) { [weak self] in
               cell.contentView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
       
            }
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath),isEnableHighlightAffect{
            
            UIView.animate(withDuration: 0.4) {
                
                cell.contentView.transform = CGAffineTransform.identity
            }
            
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        
        return canMoveItem
        
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        didMoveItemAt?(sourceIndexPath,destinationIndexPath)
        
    }
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case .began:
            guard let selectedIndexPath = collectionView?.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            collectionView?.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView?.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView?.endInteractiveMovement()
        default:
            collectionView?.cancelInteractiveMovement()
        }
    }
    
    
}

extension CollectionViewDataSource: UICollectionViewDelegateFlowLayout{
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    if let block = didSizeForItemAt{
        return block(indexPath)
    }
    
    return CGSize(width: cellWidth, height: cellHeight)
  }
}

