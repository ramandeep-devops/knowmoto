//
//  PostsListVC.swift
//  Knowmoto
//
//  Created by Apple on 30/07/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

protocol PostListVCDelegate:class {
    
    func didReloadData()
    func didAllowPostOnWall(postId:String?)
    
}

extension PostListVCDelegate{
    func didReloadData(){}
    func didAllowPostOnWall(postId:String?){}
}

class PostsListVC: BaseVC {
    
    //MARK:- Outlets
    @IBOutlet weak var heightConstraintHeaderView: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Properties
    var dataSourcePostTableView:TableViewDataSource?
    
    var arrayPosts = [PostList](){
        didSet{
            
            arrayPosts.isEmpty ? self.setTableViewBackgroundView(tableview: tableView, noDataFoundText: "No Posts found!".localized) : (tableView?.backgroundView = nil)
            
        }
    }
    var isHideHeaderView:Bool = true //header title
    
    var postType:ENUM_GET_POST_TYPE = .all
    
    //paging
    var limit:Int = 10
    var skip:Int = 0
    
    var isFromAllowPostOnWall:Bool = false //from notification to show allow button
    
    weak var delegate:PostListVCDelegate?
    
    var isAllowPostStatus:Int = 0
    var postId:String?
    var taggedId:String? //for allow post
//    var notificationData:NotificationData?
    var type:Int?
    
    var userId:String? //user posts
    var vehicleId:String? //post according to vehicle
    var makeId:String? //post according to make
    var notificationData:NotificationData?
    
    var selectedPostIndex:Int? //to scroll post at selected index from previous screen
    //MARK:- View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
    func initialSetup(){
        
        heightConstraintHeaderView.constant = isHideHeaderView ? 0 : 56.0
        
        if selectedPostIndex == nil{
            
            apiGetPosts()
            
        }else{
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                
                self?.scrollToPost(postIndex: /self?.selectedPostIndex)
                
            }
            
            
        }
        
        configureCarsListTableView()
        
        if self.isHideHeaderView{
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.reloadFromNotification), name: .DELETE_POST, object: nil)
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadFromNotification), name: .RELOAD_POST, object: nil)
    }
    
    func scrollToPost(postIndex:Int?){
        
        if postIndex != nil{
            
            self.tableView.scrollToRow(at: IndexPath.init(item: /postIndex, section: 0), at: .top, animated: false)
            
        }
        
    }
    
    func configureTableHeaderFooterRefresh(){
        
        //pull to refresh is handled in parent segemented controller working with dispatch group
        
        //footer refresh
        
        self.tableView.es.addInfiniteScrolling { [weak self] in
            
            self?.skip += /self?.limit
            self?.apiGetPosts()
            
        }
        
    }
    
    func reloadPullToRefreshFromParent(){
        
        self.skip = 0
        self.apiGetPosts { [unowned self] in
            self.delegate?.didReloadData()
        }
        
    }
    
    @objc func reloadFromNotification(){
        
        self.skip = 0
        self.apiGetPosts()
    }
    
    //MARK:-Configuring Table View
    func configureCarsListTableView() {
        
        configureTableHeaderFooterRefresh()
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: isHideHeaderView ? 56.0 : 0.0, right: 0)
        
        let identifier = String(describing: PostListTableViewCell.self)
        tableView.registerNibTableCell(nibName: identifier)
        
        dataSourcePostTableView = TableViewDataSource(items: arrayPosts, tableView: tableView, cellIdentifier: identifier, cellHeight: UITableView.automaticDimension, configureCellBlock: { [weak self] (cell, item, indexPath) in
            
            let cell = cell as? PostListTableViewCell
            

            cell?.isListingView = !(/self?.isHideHeaderView)
            cell?.btnAllowOnWall.isHidden = !((self?.type ?? 1) == 2)
            cell?.setStateOfAllowButton(state: ENUM_ALLOW_ON_WALL(rawValue: /self?.isAllowPostStatus) ?? .pending)
            
            cell?.model = item
            cell?.btnMore.tag = indexPath.row
            cell?.btnMore.addTarget(self, action: #selector(self?.actionMore(sender:)), for: .touchUpInside)
        
            cell?.btnAllowOnWall.tag = indexPath.row
            cell?.btnAllowOnWall.addTarget(self, action: #selector(self?.actionAllowPostOnWall(sender:)), for: .touchUpInside)
            
            
        }) { (indexPath, item) in
            
            
        }
        
        tableView.delegate = dataSourcePostTableView
        tableView.dataSource = dataSourcePostTableView
        tableView.reloadData()
        
    }
    
    @objc func actionAllowPostOnWall(sender:UIButton){
        
        let state = ENUM_ALLOW_ON_WALL(rawValue: isAllowPostStatus) ?? .pending
        let title = (state == .pending || state == .rejected) ? "This post will be display on your feed".localized : "Do you really want to remove post from your wall?".localized
        let buttonTitle = (state == .pending || state == .rejected) ? "Allow".localized : "Remove".localized
        
        UtilityFunctions.showActionSheetWithStringButtons(backgroundColor: UIColor.white, title: title, buttons: [buttonTitle]) { [weak self] (str) in
            
            let isApproved = (state == .pending || state == .rejected) ? 2 : 1
            
            EP_Notification.approve_tag_request(id: self?.taggedId, isApproved: isApproved).request(loaderNeeded: true, successMessage: nil, success: { (response) in
                
                self?.delegate?.didAllowPostOnWall(postId: /self?.arrayPosts[sender.tag].id)
                self?.notificationData?.taggedId?.isApproved = isApproved
                self?.navigationController?.popViewController(animated: true)
                
                
                
            }, error: { (error) in
                
            })
            
        }
        
    }
    
    @objc func actionMore(sender:UIButton){
        
        let currentUserId = UserDefaultsManager.shared.currentUserId
        let isMyPost = /arrayPosts[sender.tag].user?.id == currentUserId
        let isAlreadyReported = /arrayPosts[sender.tag].reportedBy
        let actionButtons = !isMyPost ? [/isAlreadyReported ? ENUM_POST_MORE_OPTIONS.reported.rawValue : ENUM_POST_MORE_OPTIONS.report.rawValue,ENUM_POST_MORE_OPTIONS.share.rawValue] : [ENUM_POST_MORE_OPTIONS.delete.rawValue,ENUM_POST_MORE_OPTIONS.share.rawValue]
        
        UtilityFunctions.showActionSheetWithStringButtons(backgroundColor:UIColor.white,buttons: actionButtons) { [weak self] (string) in
            
            let selectionType = ENUM_POST_MORE_OPTIONS.init(rawValue: string) ?? .report
            
            switch selectionType{
                
            case .delete:
                
                self?.apiDeletePost(index: sender.tag)
                break
                
            case .edit:
                break
                
            case .report:
                
                if UserDefaultsManager.isGuestUser{
                    self?.handleGuestUser()
                }else{
                    
                    self?.apiReportPost(index: sender.tag)
                    
                }
                break
                
                
            case .reported:
          
                break
            case .share:
                
                "\(APIBasePath.firebaseDynamicBasePath)/\(/ENUM_DYNAMIC_LINK_TYPE.postId.rawValue)/\(/self?.arrayPosts[sender.tag].id)".share(from: self!, title: /self?.arrayPosts[sender.tag].title, desc: /self?.arrayPosts[sender.tag].place, imgurl: URL.init(string: AWSConstants.baseUrl + /self?.arrayPosts[sender.tag].image?.first?.thumbImageKey), image: nil)
                
                break
            }
            
        }
        
    }
    
}

//MARK:- API
extension PostsListVC{
    
    func apiDeletePost(index:Int){
        
        
        self.setLoaderMessage(message: "Deleting...".localized)
        EP_Profile.delete(id: arrayPosts[index].id, type: 8).request(loaderNeeded: true, successMessage: nil, success: { [weak self] (response) in
            
            DispatchQueue.main.async {
                
                self?.arrayPosts.remove(at: index)
                self?.dataSourcePostTableView?.items = self?.arrayPosts
                
                self?.tableView.performBatchUpdates({
                    
                    self?.tableView.deleteRows(at: [IndexPath.init(item: index, section: 0)], with: .automatic)
                    
                }, completion: { (_) in
                    
                    self?.tableView.reloadData()
                    
                })
                
                if !(/self?.isHideHeaderView){
                    
                    NotificationCenter.default.post(name: .DELETE_POST, object: nil)
                    
                }
                
            }
            
            
        }) { (error) in
            
            
        }
        
    }
    
    func apiReportPost(index:Int){
        
        EP_Post.report(id: arrayPosts[index].id, type: 2).request(loaderNeeded: true, successMessage: nil, success: { [weak self] (response) in
            
            self?.arrayPosts[index].reportedBy = true
            Toast.show(text: "Reported successfully".localized, type: .success)
            
            
        }) { (error) in
            
            
        }
        
    }
    
    
    @objc func apiGetPosts(completion:(()->())? = nil){
        
        let currentUserId = UserDefaultsManager.shared.currentUserId
        
        EP_Post.get_post_data(id:postId, type:postType.rawValue, userId:userId, search:nil, limit:limit, skip:skip, vehicleId: vehicleId, loggedInUserId: currentUserId, makeId: makeId).request(loaderNeeded: false, successMessage: nil, success: { [weak self] (response) in
            
            let list = (response as? [PostList]) ?? []
            
            if self?.skip == 0{
                
                self?.arrayPosts = list
                self?.dataSourcePostTableView?.items = self?.arrayPosts
                self?.tableView.reloadData()
                
            }else{ //paging
                
                self?.arrayPosts += list
                
                for post in list{
                    
                    self?.dataSourcePostTableView?.items?.append(post)
                    self?.tableView.insertRows(at: [IndexPath.init(row: /self?.dataSourcePostTableView?.items?.count - 1, section: 0)], with: .none)
                    
                }
                
                
            }
            completion?()
            self?.stopLoaders()
            
            
            
        }) { [weak self] (error) in
            
            completion?()
            self?.stopLoaders()
            
        }
        
    }
    
    func stopLoaders(){
        
        self.tableView.es.stopLoadingMore()
        self.tableView.es.stopPullToRefresh()
        
    }
    
}

//Giving tableview for offset change to scroll to header for segemented controller
extension PostsListVC:SJSegmentedViewControllerViewSource{
    
    func viewForSegmentControllerToObserveContentOffsetChange() -> UIView {
        return tableView
    }
    
}
