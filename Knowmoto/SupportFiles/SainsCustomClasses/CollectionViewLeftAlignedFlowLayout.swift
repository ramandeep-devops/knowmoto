//
//  CollectionViewLeftAlignedFlowLayout.swift
//  Knowmoto
//
//  Created by Apple on 13/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation

class CollectionViewLeftAlignedFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let attributesForElementsInRect = super.layoutAttributesForElements(in: rect)
        var newAttributesForElementsInRect = [UICollectionViewLayoutAttributes]()
        
        var leftMargin: CGFloat = 16.0;
        var yAxis:CGFloat = 16.0
        
        for attributes in attributesForElementsInRect! {
            
            if (attributes.frame.origin.x == self.sectionInset.left) {
                leftMargin = self.sectionInset.left
            } else {
                var newLeftAlignedFrame = attributes.frame
                leftMargin = yAxis != newLeftAlignedFrame.origin.y ? 16.0 : leftMargin
                newLeftAlignedFrame.origin.x = leftMargin
                attributes.frame = newLeftAlignedFrame
            }
            leftMargin += attributes.frame.size.width + 8
            newAttributesForElementsInRect.append(attributes)
            yAxis = attributes.frame.origin.y
        }
        
        return newAttributesForElementsInRect
    }
}

class CollectionViewKnowMotoLayout:UICollectionViewFlowLayout{
    
    private let numberOfColumns = 3
    private let cellPadding: CGFloat = 6
    
    // 3
    private var cache: [UICollectionViewLayoutAttributes] = []
    
    // 4
    private var contentHeight: CGFloat = 0
    
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    // 5
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        
        collectionView?.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 16.0, right: 0.0)
        
        self.scrollDirection = .vertical
        
        let cellSpacing:CGFloat = 16.0
        let leftInset:CGFloat = 16.0
        let rightInset:CGFloat = 16.0
        var xOffset:CGFloat = 16.0
        var yOffset:CGFloat = 16.0
        
        let noOfColumns:CGFloat = 3
        let startingIndexNo = 2
        let smallBottomIndexNo = 3
        var currentCheckDifferenceValue = 10
        let differnceBetweenSmallBottomIndexNo = 9
        var sizeChangeAtPostion = startingIndexNo + currentCheckDifferenceValue
        var sizeChangeAtPositionForSmallBottom = smallBottomIndexNo + 9
        var isChangeLine:Bool = false
        
        for item in 0..<(/collectionView?.numberOfItems(inSection: 0)){
            
            let indexPath = IndexPath(item: item, section: 0)
            
            var widthOfCell:CGFloat = (/UIScreen.main.bounds.width - ((noOfColumns + 1) * cellSpacing))/noOfColumns
            var heightOfCell:CGFloat = widthOfCell
            
            if abs((sizeChangeAtPostion - (item + 1))) == currentCheckDifferenceValue{
                
                debugPrint("sizeChangeAtPostion before:-",sizeChangeAtPostion)
                
                sizeChangeAtPostion = item + 1
                
                debugPrint("sizeChangeAtPostion after:-",sizeChangeAtPostion)
                
                xOffset = currentCheckDifferenceValue == 8 ? leftInset : (widthOfCell + cellSpacing + leftInset)
             
                if currentCheckDifferenceValue == 8{
                    yOffset = yOffset + heightOfCell + cellSpacing
                }
              
                currentCheckDifferenceValue = currentCheckDifferenceValue == 8 ? 10 : 8
         
                widthOfCell = widthOfCell + widthOfCell + cellSpacing ///(UIScreen.main.bounds.width) - (leftInset + rightInset + cellSpacing + widthOfCell)
                
                heightOfCell = widthOfCell
             
                debugPrint(widthOfCell)
                debugPrint(heightOfCell)
                
            }else{
                
                let lastCellWidth = /cache.last?.bounds.width
                let lastCellOriginX = /cache.last?.frame.origin.x
                
                if lastCellWidth > widthOfCell && lastCellOriginX > leftInset{ //if last right big cell
                    
                     if abs((sizeChangeAtPositionForSmallBottom - (item + 1))) == differnceBetweenSmallBottomIndexNo{
                        
                        sizeChangeAtPositionForSmallBottom = item + 1
                        
                    }
                    
                    xOffset = leftInset //initaliaze from starting
                    yOffset = yOffset + heightOfCell + (cellSpacing)
                    isChangeLine = true
                    
                }else if lastCellWidth > widthOfCell && lastCellOriginX == leftInset{ //last left big cell
                    
                    debugPrint("left Big cell")
                    xOffset = lastCellOriginX + lastCellWidth + cellSpacing
                    
                }else{
                    
                    
                    
                    if abs((sizeChangeAtPositionForSmallBottom - (item + 1))) == differnceBetweenSmallBottomIndexNo{
                        
                        sizeChangeAtPositionForSmallBottom = item + 1
                        
                        let lastcellFrame = cache.last?.frame

                            yOffset = yOffset + /lastcellFrame?.height + cellSpacing

                        isChangeLine = true //for next row
                        
                    }else{
                        
                        let lastcellFrame = cache.last?.frame
                        if item > 0{
                            xOffset = xOffset + widthOfCell + cellSpacing //increasing x to get next line
                        }
                        let isNextRow = isChangeLine || isNextNextRow(currentXOffset: xOffset)
                        
                        if isNextRow && item > 0{
                            
                            xOffset = leftInset
                            yOffset = yOffset + /lastcellFrame?.height + cellSpacing
                            
                        }
                        isChangeLine = false
                        
                    }
    
                }
      
                
            }
            
            
            
            let insetFrame = CGRect(x: xOffset, y: yOffset, width: widthOfCell, height: heightOfCell)
            
            
            contentHeight = max(contentHeight, insetFrame.maxY)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            debugPrint(cache.first)
        }
    }
    
    func isNextNextRow(currentXOffset:CGFloat)->Bool{

        let lastcellFrame = cache.last?.frame
        
        if currentXOffset > UIScreen.main.bounds.width - 56.0{
            return true
        }else{
            return false
        }
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect)
        -> [UICollectionViewLayoutAttributes]? {

            var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []

            // Loop through the cache and look for items in the rect
            for attributes in cache {
                if attributes.frame.intersects(rect) {

                    visibleLayoutAttributes.append(attributes)
                }
            }
            return visibleLayoutAttributes

    }

    
    override func layoutAttributesForItem(at indexPath: IndexPath)
        -> UICollectionViewLayoutAttributes? {
            return cache[indexPath.item]
    }
    
    
    
}
