//
//  TableViewDataSource.swift
//  SafeCity
//
//  Created by Aseem 13 on 29/09/15.
//  Copyright (c) 2015 Taran. All rights reserved.
//


import UIKit

typealias  ListCellConfigureBlock = (_ cell: Any , _ item: Any? , _ indexpath: IndexPath) -> ()
typealias  DidSelectedRow = (_ indexPath: IndexPath , _ cell: Any) -> ()
typealias  ViewForHeaderInSection = (_ section: Int) -> UIView?
typealias  ViewForFooterInSection = (_ section: Int) -> UIView?
typealias  WillDisplayCell = (_ indexPath: IndexPath,_ cell:UITableViewCell) -> ()
typealias  ScrollViewScroll = (_ scrollView: UIScrollView) -> ()
typealias DirectionForScroll = (_ direction: Direction) -> ()
typealias MoveRowAtIndexPath = (_ indexPath: IndexPath,_ destinationIndexPath:IndexPath) -> ()

enum Direction {
    case up
    case down
}

class TableViewDataSource: NSObject  {
    
    var items: Array<Any>?
    var cellIdentifier: String?
    var tableView : UITableView?
    
    var configureCellBlock: ListCellConfigureBlock?
    var aRowSelectedListener: DidSelectedRow?
    var scrollViewScroll:  ScrollViewScroll?
    var willDisplayCell:WillDisplayCell?
    var direction: DirectionForScroll?
    var moveRowToIndexPath:MoveRowAtIndexPath?
    var footerInSection:ViewForFooterInSection?
    var heightForRowAt:HeightForRowAt?
    var cellHeight: CGFloat?
    
    init (items: Array<Any>? , tableView: UITableView? , cellIdentifier: String?, cellHeight:CGFloat?, configureCellBlock: ListCellConfigureBlock?, aRowSelectedListener: DidSelectedRow? ) {
        
        self.tableView = tableView
        self.items = items
        self.cellIdentifier = cellIdentifier
        self.configureCellBlock = configureCellBlock
        self.aRowSelectedListener = aRowSelectedListener
        self.cellHeight = cellHeight
    }
    
    override init() {
        super.init()
    }
}

extension TableViewDataSource: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let identifier = cellIdentifier else {
            fatalError("Cell identifier not provided")
        }
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier , for: indexPath) as UITableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        if let block = self.configureCellBlock , let item: Any = self.items?[indexPath.row] { 
            block(cell , item , indexPath)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let block = self.aRowSelectedListener, case let cell as Any = tableView.cellForRow(at: indexPath){
            block(indexPath , cell)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let block = heightForRowAt{
            return block(indexPath)
        }
        return /cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let block = willDisplayCell{
            block(indexPath,cell)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard let block = footerInSection else { return nil }
        return block(section)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollViewScroll?(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        switch velocity {
        case _ where velocity.y < 0:
            // swipes from top to bottom of screen -> down
            if let dir = direction {
                dir(Direction.down)
            }
        case _ where velocity.y > 0:
            // swipes from bottom to top of screen -> up
            if let dir = direction {
                dir(Direction.up)
            }
        default: break
        }
    }
    
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        moveRowToIndexPath?(sourceIndexPath, destinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
        
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}
