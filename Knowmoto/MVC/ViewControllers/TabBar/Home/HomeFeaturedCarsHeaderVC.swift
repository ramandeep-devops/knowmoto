//
//  HomeFeaturedCarsHeaderVC.swift
//  Knowmoto
//
//  Created by Apple on 30/07/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

extension UITableView {
    func reloadData(completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() })
        { _ in completion() }
    }
}

protocol HeaderFeaturedCarsProtocol:class {
    
    func didGetHeaderHeight(height:CGFloat)
    
}

struct CarListDummyDataModel {
    var name:String?
    var image:UIImage?
}

class HomeFeaturedCarsHeaderVC: BaseVC {
    
    struct SectionHeaderViewModel {
        var title:String?
        var image:UIImage?
    }

    
    //MARK:- Outlets
    @IBOutlet weak var lblSectionTitle: UILabel!
    @IBOutlet weak var bottomSeparatorView: UIView!
    @IBOutlet var sectionHeaderView: UIView!
    @IBOutlet weak var lblCarsLiveStatus: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:-Properties
    
    var dataSourceCarsTableView:TableViewDataSourceWithHeader?
    var arraySectionHeaderData:[SectionHeaderViewModel] = []
    var arrayCarsListType = [[Any]](){
        didSet{
//            var isDataEmpty:Bool = false
//            for cars in arrayCarsListType{
//               isDataEmpty = cars.isEmpty
//            }
//            isDataEmpty ? setTableViewBackgroundView(tableview: tableView, noDataFoundText: "No data found".localized) : (tableView.backgroundView = nil)
        }
    }
    var delegate:HeaderFeaturedCarsProtocol?
    var cellHeight:CGFloat? = nil
    var isGuestUser:Bool{
        return UserDefaultsManager.isGuestUser
    }
    var layoutDelegate:SegementedVCsDelegate?
    
    
    //MARK:- View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if isGuestUser{
//            tableView.tableHeaderView = nil
//        }
        
//        bottomSeparatorView.isHidden = isGuestUser
  
        arraySectionHeaderData = [SectionHeaderViewModel.init(title: "Featured Vehicles", image: #imageLiteral(resourceName: "ic_featured"))]//isGuestUser ? [SectionHeaderViewModel.init(title: "Featured Vehicles", image: #imageLiteral(resourceName: "ic_featured")),SectionHeaderViewModel.init(title: "Recent Added Vehicles", image: #imageLiteral(resourceName: "ic_most_liked"))] : [SectionHeaderViewModel.init(title: "Featured Vehicles", image: #imageLiteral(resourceName: "ic_featured"))]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if isFirstTime{
            layoutDelegate?.didChangeHeaderVCHeight(height: tableView.contentSize.height)
        }
    }
    
    
    //MARK:- Button actions
    
    @IBAction func didTapOpenLiveCars(_ sender: UIButton) {
        
        let vc = ENUM_STORYBOARD<MBMapVC>.map.instantiateVC()
        vc.presentWithNavigationController()
//        self.present(vc, animated: true, completion: nil)
    
    }
    
 
    func reloadData(response:Any?){
        
        let featuredCars = (response as? HomeDataList)?.featured ?? []
        let recentCars = (response as? HomeDataList)?.recent ?? []
        let list = featuredCars.isEmpty ? [] : [[featuredCars]]//isGuestUser ? [[featuredCars],[recentCars]] : featuredCars.isEmpty ? [] : [[featuredCars]]
        
        //total live cars
        let totalLiveCars = (response as? HomeDataList)?.totalLiveCars
        lblCarsLiveStatus?.text = (/totalLiveCars == 0) ? "No vehicles are live right now" : "\(/totalLiveCars) vehicles are live right now. Locate them."
        lblCarsLiveStatus?.setLineSpacing(lineSpacing: 4.0)
        
        arrayCarsListType = list
        
    
        if dataSourceCarsTableView == nil {
            
            configureCarsListTableView()
           
        }
        
        self.dataSourceCarsTableView?.items = self.arrayCarsListType
        
        self.tableView?.reloadData { [weak self] in
   
            self?.layoutDelegate?.didChangeHeaderVCHeight(height: /self?.tableView.contentSize.height > 360 ? 363 : /self?.tableView.contentSize.height)
            
        }
        
    }
    
    //MARK:-Configuring Table View

    
    func configureCarsListTableView(){
        // bottom: isGuestUser ? 84 : 0.0
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0.0, right: 0)
        tableView?.isScrollEnabled = false//isGuestUser
        
        func calculateCellHeight(){
            
            //Inset bottom 84 is because container view in storyboard bottom constraint is in -(minus) value
            
            //for display 2 section getting height
            let tabbarHeight:CGFloat = 104 //72
            let tableHeaderViewHeight:CGFloat = 93//headerView.bounds.height
            let sectionHeaderViewHeight:CGFloat = sectionHeaderView.bounds.height * 2 // for display 2 section in one screen
            let totalHeight:CGFloat = tabbarHeight + tableHeaderViewHeight + sectionHeaderViewHeight
            let _cellHeightForTwoSections = (/tableView?.bounds.height - totalHeight)/2
            
            cellHeight = UIScreen.main.bounds.height > 568.0 ? _cellHeightForTwoSections > 182.0 ? _cellHeightForTwoSections : 182 : 156
            
            //182 -> iphone x and
            //156 -> iphone 5 and SE
        }
        
        if cellHeight == nil{
            
            calculateCellHeight()
        }
        
        let identifier = String(describing: CarsListTableViewCell.self)
        tableView?.registerNibTableCell(nibName: identifier)
        
      
//        let defaultItems:[String] = arrayCarsListType //isGuestUser ? [[""],[""]] : [[""]]
        dataSourceCarsTableView = TableViewDataSourceWithHeader(items: arrayCarsListType, tableView: tableView, cellIdentifier: identifier, cellHeight: cellHeight, headerHeight: 56, configureCellBlock: { [weak self] (cell, item, indexPath) in
            
            let _cell = cell as? CarsListTableViewCell
            _cell?.arrayCarListItems = self?.arrayCarsListType[indexPath.section][indexPath.row] as! [Any]
           
            
        }, viewForHeader: { [weak self] (section) -> UIView? in
            
            let sectionHeader = SectionHeaderView.instanceFromNib()
            sectionHeader.lblName.text = self?.arraySectionHeaderData[section].title
            sectionHeader.imageViewOfName.image = self?.arraySectionHeaderData[section].image
            sectionHeader.imageViewOfName.isHidden = false
            return sectionHeader
            
        }, viewForFooter: nil, aRowSelectedListener: nil, willDisplayCell: nil)
        
        dataSourceCarsTableView?.heightForRowAt = { [weak self] (indexPath) -> CGFloat in
            
            return /(self?.arrayCarsListType[indexPath.section][indexPath.row] as? [Any])?.isEmpty ? 0.0 : /self?.cellHeight
        }
        
        dataSourceCarsTableView?.heightForHeaderInSection = { [weak self] (section) ->CGFloat in
            
            let itemsInSection = ((self?.dataSourceCarsTableView?.items as? [[Any]])?[section].first as? Array<Any>)
         
            return /self?.arrayCarsListType.isEmpty ? 0.0 : /itemsInSection?.isEmpty ? 0.0 : 56.0
            
        }
        
        tableView?.delegate = dataSourceCarsTableView
        tableView?.dataSource = dataSourceCarsTableView
        
        
    }
 
}


