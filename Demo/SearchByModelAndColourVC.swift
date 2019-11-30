//
//  SearchByModelAndColourVC.swift
//  Knowmoto
//
//  Created by cbl16 on 21/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

struct Headers {
    var image:UIImage?
    var headerName:String?
    var headerHieght:CGFloat? = 23
    
    init(image:UIImage?,headerName:String?,headerHieght:CGFloat?) {
        self.image = image
        self.headerName = headerName
        self.headerHieght = headerHieght
    }
}

class SearchByModelAndColourVC: UIViewController {
    
    //MARK:- OUTLETS
    
    @IBOutlet weak var tableview: UITableView!
    
    //MARK:- PROPERTIES
    
    var arrayHeader = [Headers(image: UIImage(named: "ic_history_white"), headerName:"Tranding search",headerHieght:60),
                       Headers(image: UIImage(named: "ic_trending"), headerName:"Tranding Brands" ,headerHieght:40),
                       Headers(image: UIImage(named: "ic_trending"), headerName:"Tranding Cars",headerHieght:20 )
    ]    
    
    var customDataSource: TableViewDataSourceWithMultipleTypeCells?
    var identifiers:[TableCellLayoutModel] = []
    var arrayItemsDictionary:[[String]] = []
    
    var trendingCarCollectionViewCell = String(describing: TrendingCarCollectionViewCell.self)
    var trendingBrandCollectionsCell = String(describing: TrendingBrandCollectionsCell.self)
    var recentSeachCollectionCell = String(describing:RecentSearchCell.self )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        // Do any additional setup after loading the view.
    }
    

    //MARK: CONFIGURE TABLE VIEW CELL
    func configureTableView(){ // configuring tableview
        
      identifiers = [
            TableCellLayoutModel(identifier: recentSeachCollectionCell, cellHeight: UITableView.automaticDimension, cellHeaderheight: 50, arrayItems: [""],headerName:"Recent search"),
            TableCellLayoutModel(identifier: trendingBrandCollectionsCell, cellHeight: 150, cellHeaderheight: 40, arrayItems: [""],headerName:"Tranding Brands"),
            TableCellLayoutModel(identifier: trendingCarCollectionViewCell, cellHeight: 240, cellHeaderheight: 40, arrayItems: [""],headerName:"Tranding Cars")
        ]
                
        customDataSource = TableViewDataSourceWithMultipleTypeCells(arrayItemsDictionary: arrayItemsDictionary, identifiers:identifiers, tableView: tableview, headerHeight: nil, configureCellBlock:{ (cell, item, indexPath) in
            
            
            // get cell of every section
            if  let _cell = cell as? RecentSearchCell{
                
                // getting the size of collection content
                _cell.frame = self.tableview.bounds
                _cell.layoutIfNeeded()
                _cell.collectionView.reloadData()
                _cell.collectionConstraint.constant = _cell.collectionView.contentSize.height

            } else if let _cell = cell as? ModelCarHorizontalCell {
                
            }
            
        }, viewForHeader:{ (section) -> UIView? in
            
            // set  section header
            let sectionHeader = SectionHeaderView.instanceFromNib()
            sectionHeader.lblName.text = self.arrayHeader[section].headerName
            sectionHeader.imgTrending.image = self.arrayHeader[section].image
            
            sectionHeader.lblName.textColor = UIColor.SubtitleLightGrayColor
            sectionHeader.backgroundColor = UIColor.backGroundHeaderColor
            return sectionHeader
            
        }, viewForFooter: nil, aRowSelectedListener: nil)
        // set tableview hieght
        customDataSource?.heightForRowAt = { [weak self] (indexPath) ->CGFloat in
            return  self?.identifiers[indexPath.section].cellHeight ?? 0.0
          
        }
        
        // set header height
        customDataSource?.heightForHeaderInSection = { [weak self] (section) ->CGFloat in
            return  self?.arrayHeader[section].headerHieght ?? 0.0
        }
//
        tableview.delegate = customDataSource
        tableview.dataSource = customDataSource
        tableview.reloadData()
    }
   

}
