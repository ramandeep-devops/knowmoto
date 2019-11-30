//
//  KnowmotoUIButton.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/8/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation
//MARK:-KNOW moto button
class KnomotButton:UIButton{
    
//    override var isHighlighted: Bool{
//        didSet{
//            
//            self.backgroundColor = isHighlighted ? self.backgroundColor?.withAlphaComponent(0.3) : UIColor.clear
//            
//        }
//    }
    
    @IBInspectable var enableButton:Bool = true{
        
        didSet{
            enableButton ? setButtonEnabled() : setButtonDisabled()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setTextFieldProperties()
    }
    
    func setTextFieldProperties(){
        
//        setb
        setTextFieldFontStyle()
        setBorderStyle()
    }
    
    private func setTextFieldFontStyle(){
        
        //corner radius
        self.titleLabel?.font = ENUM_APP_FONT.bold.size(14.0)
//        self.backgroundColor = UIColor.BlueColor
    }
    
    private func setBorderStyle(){
        
        //corner radius
        self.layer.cornerRadius = 6.0
    }
    
    
    func setButtonDisabled(){
        
        self.alpha = 0.4
        self.isUserInteractionEnabled = false
    }
    
    func setButtonEnabled(){
        
        self.alpha = 1.0
        self.isUserInteractionEnabled = true
    }
}


extension UIButton {
    // https://stackoverflow.com/questions/14523348/how-to-change-the-background-color-of-a-uibutton-while-its-highlighted
    private func image(withColor color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        

        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        self.setBackgroundImage(image(withColor: color), for: state)
    }
}
