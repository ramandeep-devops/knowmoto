//
//  InterestModelVC.swift
//  Knowmoto
//
//  Created by Apple on 09/10/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class InterestModelVC: BaseVC {
    
    @IBOutlet weak var imageViewTitleLogo: KnowmotoUIImageView!
    @IBOutlet weak var btnRemove: KnomotButton!
    @IBOutlet weak var tableView: UITableView!
    
    var dataSourceTableView:TableViewDataSource?
    var makeData:ModelSelectedInterestedMakes?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        
    }
    
    func initialSetup(){
        
        configureTableView()
        imageViewTitleLogo.loadImage(key: /makeData?.makeId?.image?.first?.thumb, cacheKey: /makeData?.makeId?.image?.first?.thumbImageKey)
        lblTitle.text = /makeData?.makeId?.name
   
    }
    
    @IBAction func didTapRemove(_ sender: UIButton) {
        
        
        
    }
    
    @IBAction func didTapAddMore(_ sender: UIButton) {
        
        let vc = ENUM_STORYBOARD<SelectMakeOrBrandOrModelVC>.car.instantiateVC()
        
        vc.vcType = ENUM_CAR_SELECTION_TYPE.model
        vc.selectedData = makeData?.modelIds
        vc.makeDataOfEditInterest = makeData?.makeId
        vc.isFromEditInterest = true
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func configureTableView(){
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0.0, right: 0)
        
        tableView.registerNibTableCell(nibName: String(describing: TextTableViewCell.self))
        
        dataSourceTableView = TableViewDataSource(items: makeData?.modelIds ?? [], tableView: tableView, cellIdentifier: String(describing: TextTableViewCell.self), cellHeight: 48, configureCellBlock: { (cell, item, indexPath) in
            
            let _cell = cell as? TextTableViewCell
            _cell?.lblTitle.text = /(item as? BrandOrCarModel)?.name
            
        }, aRowSelectedListener: { (indexPath, item) in
            
            
        })
        
        tableView.delegate = dataSourceTableView
        tableView.dataSource = dataSourceTableView
        tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            
            /self?.makeData?.modelIds?.isEmpty ? self?.setTableViewBackgroundView(tableview: (self?.tableView)!, noDataFoundText: "No models selected!".localized) : (self?.tableView.backgroundView = nil)
            
        }
        
        
        
    }
    
    
}
