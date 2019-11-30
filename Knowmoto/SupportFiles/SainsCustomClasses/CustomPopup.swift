//
//  CustomPopup.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/17/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation

protocol CustomPopUpDelegate:class {
    
    func didDone(_ data:Any)
    func didCancel()
    
}

class CustomPopUp:UIView{
    
    var isKeyboardOpen:Bool = false
    
    lazy var blurEffectView:UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
        return blurView
    }()
    
    
    lazy var statusBarView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
    var popUpView:UIView!
    
    static var delegate:CustomPopUpDelegate?
    
    var popupData:Any?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        keyboardHandling()
    }
    
    
    func initialSetup(){
        
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        
        self.addSubview(popUpView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func addBackgroundView(){
        
        UIApplication.shared.keyWindow?.isUserInteractionEnabled = true
        
        blurEffectView.isUserInteractionEnabled = true
        blurEffectView.alpha = 0.9
        blurEffectView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        blurEffectView.frame = UIApplication.shared.keyWindow?.frame ?? CGRect.zero
        UIApplication.shared.keyWindow!.addSubview(blurEffectView)
        
        
        blurEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backroundTouchAction)))
    }
    
    
    //MARK:- Keyboard handling
    func keyboardHandling(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        
        isKeyboardOpen = true
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            
            
            print("notification: Keyboard will show")
            let padding:CGFloat = 16
            self.frame.origin.y -= (self.frame.origin.y + self.bounds.height) - (keyboardSize.origin.y - padding)
            
        }
        
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        
        isKeyboardOpen = false
        
        if self.frame.origin.y != 0 {
            self.center = self.window?.center ?? CGPoint.zero
        }
        
    }
    
    
    //MARK:- Present dismiss functions
    func openPopUp(animation:Bool = true){
        
        
        addBackgroundView()
        
        self.blurEffectView.alpha = 0
        self.alpha = 0
        self.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        
        
        guard let window = UIApplication.shared.keyWindow else {return}
        
        self.center = window.center
        
        
        window.addSubview(self)
        
        UIView.animate(withDuration: animation ? 0.4 : 0.0) { [weak self] in
            
            self?.blurEffectView.alpha = 0.9
            self?.alpha = 1
            self?.transform = CGAffineTransform.identity
        }
        
    }
    
    @objc func backroundTouchAction(){
        if isKeyboardOpen{
            self.endEditing(true)
        }else{
            dismissPopUp()
        }
    }
    
    @objc func dismissPopUp(animation:Bool = true){
    
        UIView.animate(withDuration:animation ? 0.4 : 0.0, animations: { [weak self] in
            
            self?.blurEffectView.alpha = 0
            self?.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
            self?.alpha = 0
            
        }) { (_) in
            
            for view in UIApplication.shared.keyWindow?.subviews ?? []{
                if view is UIVisualEffectView || view is CustomPopUp{
                    view.removeFromSuperview()
                }
            }
  
        }
        
    }
    
    
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        
        self.dismissPopUp()
        
    }
}
