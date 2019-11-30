//
//  KnowmotoHeaderView.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/8/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation

class KnowmotoHeaderView:UIView{
    
    @IBInspectable var type:String = ENUM_VIEWCONTROLLER_TYPE.commonCenterAppIcon.rawValue{
        didSet{
            self.setHeaderView(viewControllerType: ENUM_VIEWCONTROLLER_TYPE(rawValue: /type) ?? .commonCenterAppIcon)
        }
    }
    
    @IBInspectable var title:String = ""{
        didSet{
            setTitles()
        }
    }
    
    @IBInspectable var enableRightButton2:Bool = false{
        didSet{
            setTitles()
        }
    }
    
    @IBInspectable var enableRightButton:Bool = false{
        didSet{
            setTitles()
        }
    }
    
    @IBInspectable var rightButton2Title:String = ""{
        didSet{
            setTitles()
        }
    }
    
    @IBInspectable var rightButtonTitle:String = ""{
        didSet{
            setTitles()
        }
    }
    
    @IBInspectable var rightButton2TitleColor:UIColor = UIColor.clear{
        didSet{
            setTitles()
        }
    }
    
    @IBInspectable var rightButtonTitleColor:UIColor = UIColor.clear{
        didSet{
            setTitles()
        }
    }
    
    @IBInspectable var rightButton2Image:UIImage? = nil{
        didSet{
            setTitles()
        }
    }
    
    @IBInspectable var rightButtonImage:UIImage? = nil{
        didSet{
            setTitles()
        }
    }
    
    @IBInspectable var isEnableloaderView:Bool = false{
        didSet{
            setLoaderView()
        }
    }
    
    let headerView = CommonHeaderView.instanceFromNib()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        headerView.frame = self.bounds
        self.addSubview(headerView)
    }
    
    func setTitles(){
        
        
        headerView.lblTitle.text = title
        headerView.btnRight.setTitleColor(rightButtonTitleColor, for: .normal)
        headerView.btnRight.setTitle(rightButtonTitle, for: .normal)
        headerView.btnRight.setImage(rightButtonImage, for: .normal)
        
        headerView.btnRight2.setTitleColor(rightButton2TitleColor, for: .normal)
        headerView.btnRight2.setTitle(rightButton2Title, for: .normal)
        headerView.btnRight2.setImage(rightButton2Image, for: .normal)
        
        headerView.btnRight2.isHidden = !enableRightButton2
        
        
    }
    
    func setLoaderView(){
        
        self.headerView.viewPercentage.isHidden = !isEnableloaderView
        
    }
    
    func setHeaderView(headerHeight:CGFloat = 56.0,viewControllerType:ENUM_VIEWCONTROLLER_TYPE){
        
        //getting all header required detail for particular view controller
        let headerDetail = viewControllerType.getHeaderDetail()
        headerView.imageViewTitle.image = headerDetail?.1
        
        headerView.btnLeft.isHidden = headerDetail?.2 ?? false
        headerView.btnRight.isHidden = (headerDetail?.3 ?? true)
        headerView.btnRight2.isHidden = !(enableRightButton2)
        
        guard let dismissType = headerDetail?.4 else {return}
        let image = dismissType == .dismiss ? #imageLiteral(resourceName: "ic_close") : #imageLiteral(resourceName: "ic_backwd")
        
        headerView.btnLeft.setImage(image, for: .normal)
        
        headerView.didTapLeftButton = { [weak self] (_) in
            
            switch dismissType{
                
            case .dismiss:
                
                self?.topMostVC?.dismiss(animated: true, completion: nil)
                
            case .pop:
                
                self?.topMostVC?.navigationController?.popViewController(animated: true)
                
            }
        }

        
    }
    
}
