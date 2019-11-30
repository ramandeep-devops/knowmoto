//
//  MBCustomUserLocation.swift
//  Knowmoto
//
//  Created by Apple on 24/09/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation
import Mapbox
import Kingfisher
import AWSS3

class MBCustomUserLocationMarker:MGLUserLocationAnnotationView{
    
    let sizeOfCustomMarker: CGFloat = 56
    var image:UIImage? = nil
    
    var customCurrentLocationLayer:CALayer!
    var subImageLayer:CALayer!
    
    var urlOfImage:String?
    
    init(url:String) {
        
        super.init(reuseIdentifier: "")
        
        self.urlOfImage = url
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update() {
        
        if frame.isNull {
            
            frame = CGRect(x: 0, y: 0, width: sizeOfCustomMarker, height: sizeOfCustomMarker)
            return setNeedsLayout()
            
        }
        
        self.setupLayers()
        self.loadImageFromUrl()
        
    }
    
    private func setupLayers(){
        
        if customCurrentLocationLayer == nil {
            
            //custom current location layer
            customCurrentLocationLayer = CALayer()
            
            //setting bounds of view
            customCurrentLocationLayer.bounds = CGRect(x: 0, y: 0, width: sizeOfCustomMarker, height: sizeOfCustomMarker + 8)
            customCurrentLocationLayer.frame.origin.y = -sizeOfCustomMarker
            
            //bubble image layer
            customCurrentLocationLayer.contents = #imageLiteral(resourceName: "ic_car_pin_big").cgImage
            customCurrentLocationLayer.contentsScale = UIScreen.main.scale
            
            //add bubble image layer
            layer.addSublayer(customCurrentLocationLayer)
            
            //add circle custom image layer on top
            
        }
    }
    
    func loadImageFromUrl(){
        
        let imageView = UIImageView()
        imageView.loadImage(url: /urlOfImage, cacheKey: /urlOfImage) { [weak self] (image, nil) in
            
            DispatchQueue.main.async {
                
                if self?.subImageLayer == nil{
                    
                    self?.subImageLayer = CALayer()
                    
                    self?.subImageLayer.contents = image?.cgImage
                    
                    self?.subImageLayer.frame = CGRect(x: /self?.customCurrentLocationLayer.frame.origin.x + 4, y: /self?.customCurrentLocationLayer.frame.origin.y + 3, width: /self?.sizeOfCustomMarker - 8, height: /self?.sizeOfCustomMarker - 8)
                    
                    self?.subImageLayer.cornerRadius = (self?.subImageLayer.bounds.height ?? 0.0)/2
                    self?.subImageLayer.masksToBounds = true
                    
                    self?.layer.insertSublayer((self?.subImageLayer)!, above: self?.customCurrentLocationLayer)
                    
                }
                
            }
            
        }
    }
    
}


class MBCustomAnnotationView:MGLAnnotationView{
    
    var url:String?
    var highlightedSizeOfMarker:CGFloat = 72
    var sizeOfCustomMarker: CGFloat = 48
    var image:UIImage? = nil{
        didSet{
            self.subImageLayer.contents = image?.cgImage
            super.layoutSublayers(of: self.subImageLayer)
        }
    }
    var isLoadFromSignedUrl:Bool = true
    var customCurrentLocationLayer:CALayer!
    var subImageLayer:CALayer!
    var cacheKey:String?
    var isSelectedAnnotation:Bool = false
    
    
    init(annotation:MGLAnnotation?,resuseIdentifier:String?,url:String?,size:CGSize,isLoadFromSignedUrl:Bool,cacheKey:String?,isSelected:Bool) {
        
        super.init(annotation: annotation, reuseIdentifier: resuseIdentifier)
        
        self.isLoadFromSignedUrl = isLoadFromSignedUrl
        self.sizeOfCustomMarker = size.height
        self.cacheKey = cacheKey
        self.url = url
        self.isSelectedAnnotation = isSelected
        
        self.setupLayers()
        self.loadImageFromUrl()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected{
            
            self.setBubbleLayerFrame(isSelected: selected)
            self.setSubImageLayer(isSelected: selected)
            
        }else{
            
            self.setBubbleLayerFrame(isSelected: selected)
            self.setSubImageLayer(isSelected: selected)
            
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayers(){
        
        if customCurrentLocationLayer == nil {
            
            
            self.layer.anchorPoint = CGPoint(x: 0, y: 0)
            
            self.frame.size.height = 56.0
            self.frame.size.width = 56.0
            
            //custom current location layer
            customCurrentLocationLayer = CALayer()
            
            //setting bounds of view
            self.setBubbleLayerFrame(isSelected: isSelected)
            self.setSubImageLayer(isSelected: isSelected)
            
            //bubble image layer
            customCurrentLocationLayer.contents = #imageLiteral(resourceName: "ic_car_pin_big").cgImage
            customCurrentLocationLayer.contentsScale = UIScreen.main.scale
            
            //add bubble image layer
            layer.addSublayer(customCurrentLocationLayer)
            
//            self.subImageLayer?.perform(#selector(self.handleTap))
            
            //add circle custom image layer on top
            
        }
    }
    
    func loadImageFromUrl(){
        
        let imageView = UIImageView()
        
        if isLoadFromSignedUrl{
            
            imageView.loadImageFromSignedUrl(cacheKey: /cacheKey, key: /url) { [weak self] (image) in
                
                DispatchQueue.main.async {
                    
                    if self?.subImageLayer == nil{
                        
                        self?.setSubImageLayer(isSelected: /self?.isSelected)
                        
                    }
                    
                    self?.image = image
                    
                }
                
            }
        }else{
            
            imageView.loadImage(url: /url, cacheKey: /cacheKey, completion: { [weak self] (image, error) in
                
                DispatchQueue.main.async {
                    
                    if self?.subImageLayer == nil{
                        
                        self?.setSubImageLayer(isSelected: /self?.isSelected)
                        
                    }
                    
                    self?.image = image
                    
                }
                
            })
        }
        
        
    }
    
    func setSubImageLayer(isSelected:Bool){
        
        DispatchQueue.main.async {
            
            if self.subImageLayer == nil{
                
                self.subImageLayer = CALayer()
                
                self.subImageLayer.masksToBounds = true
                
                self.layer.insertSublayer((self.subImageLayer), above: self.customCurrentLocationLayer)
            }
            
            let sizeOfMarker = isSelected ? self.highlightedSizeOfMarker : self.sizeOfCustomMarker
            
            if self.image != nil{
                
                self.subImageLayer.contents = self.image?.cgImage
            }
            
            self.subImageLayer.frame = CGRect(x: /self.customCurrentLocationLayer.frame.origin.x + 4, y: /self.customCurrentLocationLayer.frame.origin.y + 3, width: /sizeOfMarker - 8, height: /sizeOfMarker - (isSelected ? 12 : 8))
            
            self.subImageLayer.cornerRadius = (self.subImageLayer.bounds.height)/2
            
            super.layoutSublayers(of: self.subImageLayer)
            
        }
        
    }
    
    func setBubbleLayerFrame(isSelected:Bool){
        
        let sizeOfMarker = isSelected ? highlightedSizeOfMarker : sizeOfCustomMarker
        
        customCurrentLocationLayer.bounds = CGRect(x: self.layer.frame.origin.x, y: self.layer.frame.origin.y, width: sizeOfMarker, height: sizeOfMarker + 8)
        
        customCurrentLocationLayer.frame.origin.y = -sizeOfMarker
        
        super.layoutSublayers(of: customCurrentLocationLayer)
        
       
        
    }
    
    
    
    
}

class MBCustomMarker:MGLPointAnnotation{
    
    var reuseIdentifierId:String?
    var imageUrl:String?
    var cacheKey:String?
    var isLoadFromSignedUrl:Bool?
    var isSelected:Bool = false
    var willUseImage:Bool = false
    
    init(reuseIdentifier:String?,imageUrl:String?,cacheKey:String?,isLoadFromSignedUrl:Bool = false,willUseImage:Bool = false) {
        
        super.init()
        
        self.isLoadFromSignedUrl = isLoadFromSignedUrl
        self.reuseIdentifierId = reuseIdentifier
        self.imageUrl = imageUrl
        self.cacheKey = cacheKey
        self.willUseImage = willUseImage
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
}
