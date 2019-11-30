//
//  NewsVC.swift
//  Knowmoto
//
//  Created by Apple on 30/07/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

struct NewsData{
    
    var title:String?
    var content:String?
    var date:String?
    var imageUrl:String?
    var link:String?
}


class NewsTabVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var arrayNews:[NewsData] = []
    var dataSourceTableView:TableViewDataSource?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        configureNewsTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        apiGetNews()
        lastSelectedTab = .news
    }
    

    func configureNewsTableView(){
        
        let identifier = String(describing: NewsTableViewCell.self)
        
        dataSourceTableView = TableViewDataSource(items: arrayNews, tableView: tableView, cellIdentifier: identifier, cellHeight: UITableView.automaticDimension, configureCellBlock: { (cell, item, indexPath) in
            
            let _cell = cell as? NewsTableViewCell
            _cell?.configureCell(model: item)
            
        }, aRowSelectedListener: { [weak self] (indexPath, item) in
            
            guard let url = URL(string: /self?.arrayNews[indexPath.row].link) else { return }
            UIApplication.shared.open(url)
            
        })
        
        tableView.delegate = dataSourceTableView
        tableView.dataSource = dataSourceTableView
        tableView.reloadData()
        
    }
    
}

//MARK:- News api

extension NewsTabVC{

    func apiGetNews(){
        
//        http://knowmoto.com/blog/wp-json/wp/v2/posts/?categories=2&per_page=10&_embed
        
        EP_Home.news(categories: 2, per_page: 10).request(loaderNeeded:false,success: { [weak self] (response) in
        
            do {
                
                let json = try JSONSerialization.jsonObject(with: response as! Data, options: []) as? [String:AnyObject]
                
                self?.arrayNews = []
                
                for news in json?["data"] as? [[String:AnyObject]] ?? []{
                    
                    
                    let title = news["title"]?["rendered"] as? String
                    let content = news["excerpt"]?["rendered"] as? String
                    let date = news["date"] as? String
                    let link = news["link"] as? String
                    let imageUrl = (((((news["_embedded"] as? [String:Any])?["wp:featuredmedia"] as? [[String:Any]])?.first?["media_details"] as? [String:Any])?["sizes"] as? [String:Any])?["medium"] as? [String:Any])?["source_url"] as? String
                    
                    let newsModel = NewsData.init(title: title, content: content, date: date, imageUrl: imageUrl,link:link)
                    
                    self?.arrayNews.append(newsModel)
                    
                }
                
                self?.dataSourceTableView?.items = self?.arrayNews
                self?.tableView.reloadData()
                
               debugPrint(json)
                
            }catch let error{
                
            }

            
        })
        
        
    }
    
}
