//
//  KnowmotoTextField.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/8/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation
//MARK:-Knowmoto uitextfield
class KnowMotoTextField:UITextField,UITextFieldDelegate{
    
    @IBInspectable open var copyText:Bool = false
    @IBInspectable open var cutText:Bool = false
    @IBInspectable open var selectText:Bool = false
    @IBInspectable open var pasteText:Bool = false
    
    @IBInspectable open var borderWidth:CGFloat = 0.2{
        didSet{
            setBorderStyle()
        }
    }
    @IBInspectable open var borderColor:UIColor = UIColor.BorderColor ?? UIColor.white{
        didSet{
            setBorderStyle()
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        if action == #selector(UIResponderStandardEditActions.paste(_:)) && !pasteText{
            
            return false
            
        }else if action ==  #selector(UIResponderStandardEditActions.copy(_:)) && !copyText{
            
            return false
            
        }else if action ==  #selector(UIResponderStandardEditActions.cut(_:)) && !cutText{
            
            return false
            
        }else if (action ==  #selector(UIResponderStandardEditActions.select(_:)) || action == #selector(UIResponderStandardEditActions.selectAll(_:))) && !selectText{
            
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setTextFieldProperties()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
        self.setTextFieldProperties()
    }
    
    override func awakeFromNib() {
        
        self.delegate = self
    }
    
    private func setTextFieldProperties(){
        
        self.sizeToFit()
        self.placeHolderColor = UIColor.white.withAlphaComponent(0.5)
        setLeftPadding()
        setFontStyle()
        setBorderStyle()
    }
    
    open func setLeftPadding(){
        
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: self.frame.height))
        self.leftViewMode = .always
    }
    
    open func setRightPadding(padding:CGFloat = 56.0){
        
        self.rightView = UIView(frame: CGRect(x: self.bounds.width - padding, y: 0, width: padding, height: self.frame.height))
        self.rightViewMode = .always
    }
    
    private func setFontStyle(){
        
        //border style
        self.tintColor = UIColor.white //cursor color
        self.font = ENUM_APP_FONT.bold.size(14.0)
    }
    
    private func setBorderStyle(){
        
        //border style
        self.borderStyle = .none
        self.layer.borderWidth = borderWidth
        self.layer.masksToBounds = true
        self.layer.borderColor = borderColor.cgColor
        
        //corner radius
        self.layer.cornerRadius = 4.0
    }
    
    
}


