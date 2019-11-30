//
//  TableViewDataSourceWithHeader.swift
//  Auttle
//
//  Created by CodeBrew on 8/30/17.
//  Copyright © 2017 CodeBrew. All rights reserved.
//

import UIKit

typealias HeightFoHeaderInSection = (_ indexPath:Int)-> (CGFloat)
typealias HeightForRowAt = (_ indexPath:IndexPath)-> (CGFloat)

class TableViewDataSourceWithHeader: TableViewDataSource {
  
  var viewforHeaderInSection: ViewForHeaderInSection?
  var viewForFooterInSection: ViewForHeaderInSection?
  var headerHeight: CGFloat?
  var footerHeight: HeightFoHeaderInSection?
  var heightForHeaderInSection:HeightFoHeaderInSection?
  
  init (items: Array<Any>? , tableView: UITableView? , cellIdentifier: String?,cellHeight:CGFloat?,headerHeight:CGFloat?,configureCellBlock: ListCellConfigureBlock?,viewForHeader:ViewForHeaderInSection?,viewForFooter:ViewForHeaderInSection?, aRowSelectedListener: DidSelectedRow?,willDisplayCell: WillDisplayCell?) {
    
    self.viewforHeaderInSection = viewForHeader
    self.headerHeight = headerHeight
    self.viewForFooterInSection = viewForFooter
    
    super.init(items: items, tableView: tableView, cellIdentifier: cellIdentifier, cellHeight: cellHeight, configureCellBlock: configureCellBlock, aRowSelectedListener: aRowSelectedListener)
  }
  
  override init() {
    super.init()
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return items!.count;
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    guard let identifier = cellIdentifier else {
      fatalError("Cell identifier not provided")
    }
    
    let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    cell.selectionStyle = .none
    
    if let block = configureCellBlock , let item:Any = (items)?[indexPath.section]{
      
    block(cell, item, indexPath)
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return (items?[section] as AnyObject).count
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let block = viewforHeaderInSection else { return nil }
    return block(section)
  }
  
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return ((heightForHeaderInSection?(section)) ?? headerHeight) ?? 32.0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
    guard let block = viewForFooterInSection else { return nil }
    return block(section)
        
  }
  
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return footerHeight?(section) ?? 0.0
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    return (self.heightForRowAt?(indexPath)) ?? /cellHeight
  }
  
  
}
