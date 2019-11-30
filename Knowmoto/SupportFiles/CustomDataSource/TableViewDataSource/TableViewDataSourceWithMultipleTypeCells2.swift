
//  TableViewDataSourceWithMultipleTypeCells.swift
//  Knowmoto

//  Created by Dhan Guru Nanak on 8/15/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.

import Foundation

enum ENUM_TABLE_HEADER_NAMES:String{
    case recentSearches = "Recent Searches"
    case trendingMakes = "Trending Makes"
    case trendingCars = "Trending Vehicles"
    case basicInfoAndDetail = "Basic info & details"
    case otherDetails = "Other details"
    case specialAttributes = "Special Features"
    case modifications = "Modifications"
    case sponsors = "Sponsors"
    case models = "Models"
}

struct TableCellLayoutModel{
    
    var identifier:String? // for all cells same type in one section
    var cellHeight:CGFloat?
    var cellHeaderheight:CGFloat? = 56.0
    var arrayItems:Array<Any>?
    var collectionCellItems:Array<Any>?
    var headerName:ENUM_TABLE_HEADER_NAMES?
    var headerIcon:UIImage?
    
    init(identifier:String?,arrayItems:Array<Any>?) {
        self.identifier = identifier
        self.arrayItems = arrayItems
        
    }
    
    init(identifier:String?,cellHeight:CGFloat?,arrayItems:Array<Any>?) {
        self.identifier = identifier
        self.cellHeight = cellHeight
        self.arrayItems = arrayItems
    }
    
    init(identifier:String?,cellHeight:CGFloat?,cellHeaderheight:CGFloat? = 56.0,arrayItems:Array<Any>?,headerName:ENUM_TABLE_HEADER_NAMES?,collectionCellItems:Array<Any>? = nil,headerIcon:UIImage? = nil) {
        
        self.identifier = identifier
        self.cellHeight = cellHeight
        self.cellHeaderheight = cellHeaderheight
        self.arrayItems = arrayItems
        self.headerName = headerName
        self.collectionCellItems = collectionCellItems
        self.headerIcon = headerIcon
        
    }
    
}


class TableViewDataSourceWithMultipleTypeCells2:TableViewDataSourceWithHeader{
    
    var dataItems:[TableCellLayoutModel]?
    
    init (arrayItemsLayoutModel:[TableCellLayoutModel]?,tableView: UITableView?,headerHeight:CGFloat?,configureCellBlock: ListCellConfigureBlock?,viewForHeader:ViewForHeaderInSection?,viewForFooter:ViewForHeaderInSection?, aRowSelectedListener: DidSelectedRow?){
        
        self.dataItems = arrayItemsLayoutModel
        
        super.init(items: nil, tableView: tableView, cellIdentifier: nil, cellHeight: nil, headerHeight: headerHeight, configureCellBlock: configureCellBlock, viewForHeader: viewForHeader, viewForFooter: viewForFooter, aRowSelectedListener: aRowSelectedListener, willDisplayCell: nil)
    }
    
    required override init(items: Array<Any>?, tableView: UITableView?, cellIdentifier: String?, cellHeight: CGFloat?, headerHeight: CGFloat?, configureCellBlock: ListCellConfigureBlock?, viewForHeader: ViewForHeaderInSection?, viewForFooter: ViewForHeaderInSection?, aRowSelectedListener: DidSelectedRow?, willDisplayCell: WillDisplayCell?) {
        fatalError("init(items:tableView:cellIdentifier:cellHeight:headerHeight:configureCellBlock:viewForHeader:viewForFooter:aRowSelectedListener:willDisplayCell:) has not been implemented")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataItems?.count ?? 0}
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dataItems?[section].arrayItems as? [Any])?.count ?? 0
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
