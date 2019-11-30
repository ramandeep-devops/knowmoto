//
//  NotificationsVC.swift
//  Knowmoto
//
//  Created by Apple on 30/07/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class NotificationsTabVC: UIViewController {
    
    //MARK:- OUTLET
    @IBOutlet weak var tableview: UITableView!
    
    //MARK:- PROPERTIES
    
    var customDataSource:TableViewDataSource?
    
    var arrayNotifications = [
        "","","",""
    ]
    
    //MARK:- LIFE CYCLE METHODS

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configureTableView()
        tableview.tableFooterView = UIView(frame: .zero) 

        
        // Do any additional setup after loading the view.
    }
    
    
    func configureTableView(){ // configuring tableview
        
        let identifier = String(describing: NotoficatioTabCell.self)
        
        customDataSource = TableViewDataSource(items: arrayNotifications, tableView: tableview, cellIdentifier: identifier, cellHeight: UITableView.automaticDimension, configureCellBlock: { (cell, item, indexPath) in
            
            if let cell =  cell as? NotoficatioTabCell{
                
                if indexPath.row == 3{
                    cell.viewAllaowButton.isHidden = false
                }else {
                    cell.viewAllaowButton.isHidden = true
                }
            }
            
        }, aRowSelectedListener: { (indexPath, cell) in
            
        })
        
        tableview.delegate = customDataSource
        tableview.dataSource = customDataSource
        
    }

}
