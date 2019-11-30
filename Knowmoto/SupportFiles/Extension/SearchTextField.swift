//
//  SearchTextField.swift
//  Wave
//
//  Created by OSX on 30/07/18.
//  Copyright © 2018 CodeBrew labs. All rights reserved.
//

import Foundation


open class CustomSearchTextField: UITextField {
    
    typealias DidChangeInSearchField = (String)->()
    
    typealias DidBeginBeginEditing = ()->()
    
    private var timer:Timer?
    
    private var searchString:String?
    
    var didChangeSearchField:DidChangeInSearchField?
    var didBeginEditingSearchField:DidBeginBeginEditing?
    
    
    var activityIndicator:UIActivityIndicatorView?
    
    var isRTL:Bool = false
    
    open override var bounds: CGRect{
        didSet{
            
            activityIndicator?.frame.origin.x = self.bounds.width - 48
            self.layoutIfNeeded()
            self.layoutSubviews()
            
        }
    }
    

    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        addActivityIndicator()
        self.delegate = self
        self.textAlignment = isRTL ? .right : .left
    }
    
    
    func addActivityIndicator(){
        
        let frame = isRTL ? CGRect(x: 0, y: 0, width: 48, height: self.bounds.height) : CGRect(x: self.bounds.width - 48, y: 0, width: 48, height: self.bounds.height)
        activityIndicator = UIActivityIndicatorView(frame: frame)
        activityIndicator?.color = UIColor.white
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.stopAnimating()
        self.addSubview(activityIndicator!)
    }
}

extension CustomSearchTextField :UITextFieldDelegate{
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.endEditing(true)
        return true
        
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        timer?.invalidate()
        if string == "" {
            
        }
        
        let userEnteredString = /self.text
        let newString = (userEnteredString as NSString).replacingCharacters(in: range, with: string) as NSString
        searchString = newString as String
        
        
        
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.myPerformeCode), userInfo: nil, repeats: false)
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if let block = self.didBeginEditingSearchField{
            block()
        }
        
    }
    
    
    @objc func myPerformeCode(){
        
        if let block = self.didChangeSearchField{
            activityIndicator?.startAnimating()
            
            if /self.text?.isBlank{
             activityIndicator?.stopAnimating()
            }
            block(/self.text)
        }
    }
}

