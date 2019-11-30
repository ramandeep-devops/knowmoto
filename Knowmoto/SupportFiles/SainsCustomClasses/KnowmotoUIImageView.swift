//
//  KnowmotoUIImageView.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/8/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation
import AWSS3
//MARK:- UIIMage View

class KnowmotoUIImageView:UIImageView{
    
    //IBInspectables
    
    @IBInspectable var enablePhotoSelctionButton:Bool = false{
        didSet{
            if enablePhotoSelctionButton{
                configurePhotoSelectionButton()
            }
        }
    }
    
    @IBInspectable var photoSelectionButtonImage:UIImage = #imageLiteral(resourceName: "ic_add_photo") {
        didSet{
            
            if enablePhotoSelctionButton{
                configurePhotoSelectionButton()
            }
            btnPhotoSelection.setImage(photoSelectionButtonImage, for: .normal)
            
            
        }
    }
    
    @IBInspectable var placholderImage:UIImage? = nil{
        didSet{
            self.setPlaceHolder()
        }
    }
    
    @IBInspectable var blurLoadingEffect:Bool = false
    
    
    
    //activity indicator
    lazy var activityIndicator = UIActivityIndicatorView()
    
    //blur effectView
    lazy var blurEffectView:UIVisualEffectView = {
        
       return UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
        
    }()
    
    
    //indicator container view
    private lazy var indicatorContainerView:UIView = UIView()
    
    //photo selection button
    lazy var btnPhotoSelection:UIButton = UIButton()
    
    var didSelectPhoto:((UIButton)->())?
    
    
    var isImageLoaded:Bool{
        get{
            return !activityIndicator.isAnimating
        }
    }
    
    
  //Initialization
    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        
        
        
    }
    
    private func setPlaceHolder(){
        
        self.image = placholderImage
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    
    //Load image with key or url
    func loadImage(nameInitial:String? = nil,key:String,isLoadWithSignedUrl:Bool = false,cacheKey:String? = nil,placeholder:UIImage? = nil,completion:((UIImage)->())? = nil){ //key->(url or image nam)
        
        self.contentMode = .scaleAspectFill
        
        if key.isEmpty && nameInitial == nil && placeholder == nil{
            return
        }
        
        if blurLoadingEffect && !(/key.isEmpty){
            self.addBlurLoadingEffect(with: nil)
        }
//
//        if isLoadWithSignedUrl{
//
//            S3BucketHelper.shared.setupForS3Bucket()
//            let getPreSignedURLRequest = AWSS3GetPreSignedURLRequest()
//            getPreSignedURLRequest.bucket = AWSConstants.S3BucketName
//            getPreSignedURLRequest.key = key
//            getPreSignedURLRequest.httpMethod = .GET
//            getPreSignedURLRequest.expires = Date(timeIntervalSinceNow: 3600)  // Change the value of the expires time interval as required
//            AWSS3PreSignedURLBuilder.default().getPreSignedURL(getPreSignedURLRequest).continueWith { [unowned self] (task:AWSTask<NSURL>) -> Any? in
//
//
//                if let error = task.error as NSError? {
//                    print("Error: \(error)")
//
//                    self.image = placeholder
//                    self.loadImage(nameInitialImage:nameInitial,placeHolder:placeholder,url: "",indicator: !(self.blurLoadingEffect ?? false), cacheKey: key) { [weak self] (image, error) in
//
//                        if let image = image{
//                        completion?(image)
//                        }
//
//                        if /self?.blurLoadingEffect{
//
//                            self?.removeLoadingBlurEffect()
//
//                        }
//
//                    }
//
//                    return nil
//                }
//                if let presignedURL = task.result {
//                    DispatchQueue.main.async {
//
//
//                        self.loadImage(placeHolder:placeholder,url: /presignedURL.absoluteString,indicator: !(self.blurLoadingEffect ), cacheKey: key) { [weak self] (image, error) in
//
//
//                            if let image = image{
//                                completion?(image)
//                            }
//
//                            if /self?.blurLoadingEffect{
//
//                                self?.removeLoadingBlurEffect()
//
//                            }
//
//                        }
//
//
//                    }
//                }
//                return nil
//            }
//
//        }else{
        
            self.loadImage(nameInitialImage:nameInitial,placeHolder:placeholder,url: key, indicator: !blurLoadingEffect, cacheKey:cacheKey ?? key) { [weak self] (image, error) in
                
                
                if /self?.blurLoadingEffect{
                    
                    self?.removeLoadingBlurEffect()
                    
                }
                
                
            }
            
            
//        }
        
        
    }
    
    
    func addBlurLoadingEffect(with frame:CGRect?){ //loader with blur effect
        
        blurEffectView.removeFromSuperview()
        indicatorContainerView.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        //adding blur effect
//        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        blurEffectView.alpha = 0.8
        blurEffectView.frame = frame ?? self.bounds
        self.addSubview(blurEffectView)
        
        
        //Adding containerview for indicator view
        indicatorContainerView.frame = self.bounds
        indicatorContainerView.backgroundColor = UIColor.clear
        indicatorContainerView.isUserInteractionEnabled = true
        
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        activityIndicator.style = .white
        activityIndicator.center = indicatorContainerView.center
        
        self.addSubview(indicatorContainerView)
        
        OperationQueue.main.addOperation { [weak self] in
            
            self?.indicatorContainerView.addSubview((self?.activityIndicator)!)
            self?.activityIndicator.startAnimating()
            self?.isUserInteractionEnabled = false
        }
        
        btnPhotoSelection.bringSubviewToFront(self)
        
    }
    
    func removeLoadingBlurEffect(){
        
        OperationQueue.main.addOperation { [weak self] in
            
            UIView.animate(withDuration: 0.2, animations: {
                
            self?.btnPhotoSelection.setImage(self?.photoSelectionButtonImage ?? UIImage(), for: .normal)
                self?.activityIndicator.stopAnimating()
                self?.indicatorContainerView.removeFromSuperview()
                self?.blurEffectView.removeFromSuperview()
                self?.isUserInteractionEnabled = true
            })
            
            
        }
        
    }
    
    func setRetryLoadView(){
        
        DispatchQueue.main.async { [weak self] in
            
            self?.activityIndicator.stopAnimating()
            self?.indicatorContainerView.removeFromSuperview()
            self?.configurePhotoSelectionButton(image: UIImage(named: "ic_history_white"))
            
        }
        

    }
    
    
    func getImageUrl(fileName:String,completion:@escaping (String)->()){
        
        EP_Login.getImageSignedUrl(file_name: fileName).request(success:{ (response) in
            
            completion(/(response as? ImageUrlModel)?.url)
            
        })
        
    }
    
}

//Photo picker button
extension KnowmotoUIImageView{
    
    func configurePhotoSelectionButton(image:UIImage? = nil){
        
        
            self.isUserInteractionEnabled = true
            btnPhotoSelection.removeFromSuperview()
            
            btnPhotoSelection.backgroundColor = UIColor.backGroundHeaderColor?.withAlphaComponent(0.4)
            btnPhotoSelection.frame = bounds
            btnPhotoSelection.isUserInteractionEnabled = true
            self.addSubview(btnPhotoSelection)
            btnPhotoSelection.setImage(image, for: .normal)
            btnPhotoSelection.addTarget(self, action: #selector(self.actionPhotoSelectionButton(sender:)), for: .touchUpInside)
        
        
    }
    
    //button for open picker photo selection
    @objc func actionPhotoSelectionButton(sender:UIButton){
        
        didSelectPhoto?(sender)// block of selection Button
    }
    
}
