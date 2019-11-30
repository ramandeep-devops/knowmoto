//
//  TableViewDataSourceWithMultipleTypeCells.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/15/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation

class TableViewDataSourceWithMultipleTypeCells:TableViewDataSourceWithHeader{
    
    var identifiers:[String]?
    var arrayItemsDictionary:Any?
    
    
    init (arrayItemsDictionary:Any?, identifiers: [String]?,tableView: UITableView?,headerHeight:CGFloat?,configureCellBlock: ListCellConfigureBlock?,viewForHeader:ViewForHeaderInSection?,viewForFooter:ViewForHeaderInSection?, aRowSelectedListener: DidSelectedRow?){
        
        self.identifiers = identifiers
        self.arrayItemsDictionary = arrayItemsDictionary
        
        
        super.init(items: nil, tableView: tableView, cellIdentifier: nil, cellHeight: nil, headerHeight: headerHeight, configureCellBlock: configureCellBlock, viewForHeader: viewForHeader, viewForFooter: viewForFooter, aRowSelectedListener: aRowSelectedListener, willDisplayCell: nil)
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return (arrayItemsDictionary as? [String:Any])?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ((arrayItemsDictionary as? [String:Any])?[/identifiers?[section]] as? Array<Any>)?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let identifier = identifiers?[indexPath.section] else {
            fatalError("Cell identifier not provided")
        }
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.selectionStyle = .none
        
        if let block = configureCellBlock , let item:Any = ((arrayItemsDictionary as? [String:Any])?[/identifiers?[indexPath.section]] as? Array<Any>){
            
            block(cell, item, indexPath)
        }
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
                if let block = self.aRowSelectedListener, case let cell as Any = tableView.cellForRow(at: indexPath){
        
                    block(indexPath , cell)
        
                }
        
    }

    
    
}
