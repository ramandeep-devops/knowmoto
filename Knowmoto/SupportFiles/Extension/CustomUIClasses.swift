//
//  CustomUIClasses.swift
//  Knowmoto
//
//  Created by Apple on 30/07/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation


//MARK:-TAB bar
class CustomTabBar : UITabBar {
    
    @IBInspectable var height: CGFloat = 0.0
    
    
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        if height > 0.0 {
            sizeThatFits.height += 10
        }
        return sizeThatFits
    }
    
    
}


class CustomScrollView:UIScrollView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isDragging {
            next?.touchesBegan(touches, with: event)
        } else {
            super.touchesBegan(touches, with: event)
        }
    }
    
}
