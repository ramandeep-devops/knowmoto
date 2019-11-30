//
//  ForgotPasswordVC.swift
//  FireFighter
//
//  Created by OSX on 01/06/18.
//  Copyright © 2018 OSX. All rights reserved.
//

import UIKit


enum PopupType:Int{
    
    case addBeacon = 8
}

protocol CustomPopUpVCDelegate {
    
}

extension CustomPopUpVCDelegate{
    
    func didPickDate(date:Date,selectedIndex:Int?){
    }
    
    func didAddCustomVital(vitalName:String,units:String?){
    }
}


class CustomPopUpVC: BaseVC {
    
    //Create folder
   
    @IBOutlet weak var containerView: UIView!
    private var customPopUpView:UIView?
  
    
    //MARK: --------- View controller lifecycle--------
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpInitialAnimation()
    }
    
    func setUpInitialAnimation(){
        
        setUpUI()
        
        
        self.view.backgroundColor = UIColor.clear
        containerView?.alpha = 0.0
        containerView.isHidden = false
        
        
        UIView.animateKeyframes(withDuration: 0.2, delay: 0.0, options: .calculationModeLinear, animations: {
            
            UIView.animate(withDuration: 0.1) {
                
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            }
            
            UIView.animate(withDuration: 0.1) {
                
                self.containerView?.clipsToBounds = true
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                self.containerView?.alpha = 1
            }
            
            
        }, completion: nil)
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch: UITouch? = touches.first
        if touch?.view == self.view {
//            closePopup()
        }
    }
    

    func setUpUI(){
        
//        switch popupType ?? .dateTimePicker{
//            
//        case .dateTimePicker:
//         
//        }
    }
    
    func closePopup(){
//        self.view.endEditing(true)
//
//        UIView.animate(withDuration: 0.2, animations: { [weak self] in
//            self?.customPopUpView?.alpha = 0.0
//            self?.view.backgroundColor = UIColor.clear
//
//        }) { (value) in
//            self.dismissVC(completion: nil)
//        }
    }
    
   
    
   
}
