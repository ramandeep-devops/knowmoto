
//  TableViewDataSourceWithMultipleTypeCells.swift
//  Knowmoto

//  Created by Dhan Guru Nanak on 8/15/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.

import Foundation

struct TableCellLayoutModel{
    var identifier:String?
    var cellHeight:CGFloat?
    var cellHeaderheight:CGFloat? = UITableView.automaticDimension
    var arrayItems:Any?
    var headerName:String?
    
    init(identifier:String?,arrayItems:Any?) {
        self.identifier = identifier
        self.arrayItems = arrayItems
        
    }
        
    init(identifier:String?,cellHeight:CGFloat?,arrayItems:Any?) {
        self.identifier = identifier
        self.cellHeight = cellHeight
        self.arrayItems = arrayItems
    }
    
    init(identifier:String?,cellHeight:CGFloat?,cellHeaderheight:CGFloat?,arrayItems:Any?,headerName:String?) {
        self.identifier = identifier
        self.cellHeight = cellHeight
        self.cellHeaderheight = cellHeaderheight
        self.arrayItems = arrayItems
        self.headerName = headerName
        
    }
}


class TableViewDataSourceWithMultipleTypeCells2:TableViewDataSourceWithHeader{
    var dataItems:[TableCellLayoutModel]?
    var arrayItemsDictionary:[[String]]
    
    init (arrayItemsDictionary:[[String]], identifiers: [TableCellLayoutModel]?,tableView: UITableView?,headerHeight:CGFloat?,configureCellBlock: ListCellConfigureBlock?,viewForHeader:ViewForHeaderInSection?,viewForFooter:ViewForHeaderInSection?, aRowSelectedListener: DidSelectedRow?){
        
        self.dataItems = identifiers
        self.arrayItemsDictionary = arrayItemsDictionary
        
        super.init(items: nil, tableView: tableView, cellIdentifier: nil, cellHeight: nil, headerHeight: headerHeight, configureCellBlock: configureCellBlock, viewForHeader: viewForHeader, viewForFooter: viewForFooter, aRowSelectedListener: aRowSelectedListener, willDisplayCell: nil)
    }
    
    required init(items: Array<Any>?, tableView: UITableView?, cellIdentifier: String?, cellHeight: CGFloat?, headerHeight: CGFloat?, configureCellBlock: ListCellConfigureBlock?, viewForHeader: ViewForHeaderInSection?, viewForFooter: ViewForHeaderInSection?, aRowSelectedListener: DidSelectedRow?, willDisplayCell: WillDisplayCell?) {
    fatalError("init(items:tableView:cellIdentifier:cellHeight:headerHeight:configureCellBlock:viewForHeader:viewForFooter:aRowSelectedListener:willDisplayCell:) has not been implemented")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataItems?.count ?? 0}
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dataItems?[section].arrayItems as? [String])?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let identifier = dataItems?[indexPath.section].identifier else {
            fatalError("Cell identifier not provided")
        }
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier:dataItems?[indexPath.section].identifier ?? "", for: indexPath)
        cell.selectionStyle = .none
        
        if let block = configureCellBlock , let item:Any = (dataItems?[indexPath.section].arrayItems){
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
