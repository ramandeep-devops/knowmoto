//
//  SavesVC.swift
//  Knowmoto
//
//  Created by cbl16 on 22/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class SavesVC: UIViewController {
    
    //MARK:-OUTLETS
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Properties
    
    var dataSourceSavesTableView:TableViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureCarsListTableView()
    }
    
    //MARK:-Configuring Table View
    func configureCarsListTableView(){
        
//        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 32, right: 0)
        
        let identifier = String(describing: SavesFollowedAndLikedCell.self)
        tableView.registerNibTableCell(nibName: identifier)
        
        dataSourceSavesTableView = TableViewDataSource(items:["","","","","","",""] , tableView: tableView, cellIdentifier: identifier, cellHeight: UITableView.automaticDimension, configureCellBlock: { (cell, item, indexPath) in
            
        }) { (indexPath, item) in
            
        }
        
        tableView.delegate = dataSourceSavesTableView
        tableView.dataSource = dataSourceSavesTableView
        tableView.reloadData()
    }
    
}
