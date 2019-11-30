//
//  NotoficatioTabCell.swift
//  Knowmoto
//
//  Created by Amandeep tirhima on 2019-08-16.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var btnAllowOnWall: UIButton!
    @IBOutlet weak var imageViewNotification: KnowmotoUIImageView!
    @IBOutlet weak var lblATimeAgo: UILabel!
    @IBOutlet weak var viewAllaowButton: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    
    var modal:NotificationData?{
        didSet{
            configureNotificationCell()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        
        self.imageViewNotification.image = nil
        
    }
    
    func configureNotificationCell(){
        
        let notificationType = ENUM_NOTIFICATION_TYPE.init(rawValue: /modal?.type)
        
        switch notificationType ?? .taggedCar {
            
        case .taggedCar:
            
            viewAllaowButton.isHidden = false//!(modal?.taggedId?.isApproved != 2 && modal?.taggedId != nil)
            
            let tagBy = /modal?.notificationFrom?.name
            let tagged = "tagged your car"
            let carName = modal?.postId?.title // this title is car name we are sending title from frontend side by making car name with ->(year,make,model(nickName))
            
            let attributedText = UtilityFunctions.GetAttributedString(arrStrings: [/tagBy,/tagged,/carName], arrColor: [UIColor.white,UIColor.white,UIColor.white], arrFont: [ENUM_APP_FONT.book.fullFontName,ENUM_APP_FONT.book.fullFontName,ENUM_APP_FONT.xbold.fullFontName], arrSize: [14.0,14.0,15.0], arrNextLineCheck: [false,false,false])
            
            
            lblMessage.attributedText = attributedText
            
            
            
        default:
            
            viewAllaowButton.isHidden = true
            lblMessage.text = modal?.message
            lblMessage.setLineSpacing(lineSpacing: 4.0)
            
            break
        
        }
        
        imageViewNotification.loadImage(key: /modal?.vehicleId?.image?.first?.thumb, cacheKey: /modal?.vehicleId?.image?.first?.thumbImageKey)
        
        lblATimeAgo.text = modal?.createdAt?.toDate().timeAgoSince()
    }
    
   

}
