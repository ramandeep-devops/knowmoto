//
//  NewsTableViewCell.swift
//  Knowmoto
//
//  Created by Apple on 18/10/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit
import Kingfisher

class NewsTableViewCell: UITableViewCell {
    
    //MARK:- Outlets
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imageViewNews: UIImageView!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(model:Any){
        
        if let news = model as? NewsData{
            
            lblTitle.text = /news.title
            lblSubtitle.text = /news.content?.html2String
            lblSubtitle.setLineSpacing(lineSpacing: 4.0)
            
            lblDate.text = news.date?.stringToDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss")?.toString(format: "MMM/yy")
            
            imageViewNews.kf.indicatorType = .activity
            
            
            
            let modifier = AnyModifier { request in
                var r = request
                r.timeoutInterval = 300
                return r
            }
            
            if let url = URL(string: /news.imageUrl){
                
                let resource = ImageResource(downloadURL: url, cacheKey: /news.imageUrl)
                imageViewNews.kf.setImage(with: resource)
                
                imageViewNews.kf.setImage(with: resource, placeholder: nil, options: [.requestModifier(modifier)], progressBlock: nil) { (image, error, cache, url) in
                    
                    
                    
                }
                
            }
            
            
        }
       
        
    }

  
}
