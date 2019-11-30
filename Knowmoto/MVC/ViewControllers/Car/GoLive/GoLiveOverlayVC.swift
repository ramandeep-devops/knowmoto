//
//  GoLiveOverlayVC.swift
//  Knowmoto
//
//  Created by Apple on 18/09/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class GoLiveOverlayVC: BaseGoLiveVC {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.view.backgroundColor = UIColor.clear
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        UIView.animate(withDuration: 0.3) {
            
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
 
        }
      
    }
    
    
    @IBAction override func didTapDismiss(_ sender: UIButton) {
        
        self.view.backgroundColor = UIColor.clear
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
