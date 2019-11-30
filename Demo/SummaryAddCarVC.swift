//
//  SummaryAddCarVC.swift
//  Knowmoto
//
//  Created by cbl16 on 14/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.

import UIKit

class SummaryAddCarVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Properties
    var customDataSource:SummaryCarTableViewDataSource?
    
    //MARK:- View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure table
         configureTableView()
        // Do any additional setup after loading the view.
    }
    
    func configureTableView(){ // configuring tableview
        
        // data array
        var ArrayHeaderLabel =  ["Basic info & details","Special Attributes","Modifications"]
        let arrayItem = [
            ["", "", "" ,"","","",""],
            ["Infotainment Display", "Heated Seats", "Backup Assist","Paddle shifters"],
            [""]
        ]
        
        // Identifiers array
        let identifiers =  ["BasicInfoAndDetailCell","SpecialAttributeCell","ModificationCell"]
        
        let identifier = String(describing: SummaryCarTableViewDataSource.self)
        // register Xib's
        tableView.registerNibTableCell(nibName: "BasicInfoAndDetailCell")
        tableView.registerNibTableCell(nibName: "SpecialAttributeCell")
        tableView.registerNibTableCell(nibName: "ModificationCell")
        
        customDataSource = SummaryCarTableViewDataSource(items:["","",""], tableView: tableView, cellIdentifier: identifier, cellHeight: UITableView.automaticDimension, headerHeight: 55, configureCellBlock: { (cell, item, indexPath) in
            
            if let cell = cell as? BasicInfoAndDetailCell{
                
              
            }else if let cell = cell as? SpecialAttributeCell{
                
                
                
                cell.lblBasicInfo.text = arrayItem[indexPath.section][indexPath.row]
                
             
            }else if let cell = cell as? ModificationCell{
           
            }
            
        }, viewForHeader:{(section) in
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "SummaryCarHeaderCell") as! SummaryCarHeaderCell
                        
            cell.lblHeader.text = ArrayHeaderLabel[section]
            return cell
        }, viewForFooter: nil, aRowSelectedListener: nil, willDisplayCell: nil)
      
        customDataSource?.itemArray = arrayItem
        customDataSource?.sectionIdentifiers = identifiers
        tableView.delegate = customDataSource
        tableView.dataSource = customDataSource
    }
  
}
