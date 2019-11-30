//
//  UtilityFunctions.swift
//  Grintafy
//
//  Created by Sierra 4 on 16/08/17.
//  Copyright © 2017 com.example. All rights reserved.
//

import UIKit
import Foundation


class UtilityFunctions {
    
    class func appendOptionalStrings(withArray array : [String?]) -> String {
        return array.flatMap{$0}.joined(separator: " ")
    }
  
    //MARK: - Different Alerts
    class func show(alert title:String , message:String ,buttonText: String , buttonOk: @escaping () -> ()  ){
        
        let alertController = UIAlertController(title: title, message: message , preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel".localized , style: UIAlertAction.Style.default, handler: nil))
        
        alertController.addAction(UIAlertAction(title: buttonText , style: UIAlertAction.Style.default, handler: {  (action) in
            buttonOk()
        }))
        
        UIApplication.getTopViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    class func showWithCancelAction(alert title:String , message:String ,buttonText: String , buttonOk: @escaping (Bool) -> ()  ){
        
        let alertController = UIAlertController(title: title, message: message , preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel".localized , style: UIAlertAction.Style.default, handler: {  (action) in
            buttonOk(false)
        }))
        
        alertController.addAction(UIAlertAction(title: buttonText , style: UIAlertAction.Style.default, handler: {  (action) in
            buttonOk(true)
        }))
        
        UIApplication.getTopViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    
    class func showWithOk(alert title:String , message:String, buttonTitle : String , buttonOk: @escaping () -> ()){
        
        let alertController = UIAlertController(title: title, message: message , preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: buttonTitle , style: UIAlertAction.Style.default, handler: {  (action) in
            buttonOk()
        }))
        
        UIApplication.getTopViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    
    class func showActionSheetWithStringButtons(cancelButtonTextColor:UIColor? = nil,backgroundColor:UIColor? = nil, title  : String? = nil ,   buttons : [String] , success : @escaping (String) -> ()) {
        
        let controller = UIAlertController(title: title, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        controller.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.BackgroundLightRustColor!
        
        controller.view.tintColor = backgroundColor ?? UIColor.blue
        
        for button in buttons{
            
            let action = UIAlertAction(title: button.localized , style:button == "Delete" ? .destructive : .default, handler: { (action) -> Void in
                success(button)
            })
            controller.addAction(action)
        }
        let cancelButtonViewController = CancelButtonVC()

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancel.setValue(cancelButtonTextColor ?? UIColor.BlueColor!, forKey: "_titleTextColor")

        controller.addAction(cancel)
        UIApplication.getTopViewController()?.present(controller, animated: true) { () -> Void in
            
        }
    }
    
    class func showWithCancelTileAndAction(alert title:String , message:String ,buttonText: String , cancelText : String? , buttonOk: @escaping (Bool) -> ()  ){
        
        let alertController = UIAlertController(title: title, message: message , preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: cancelText ?? "Cancel".localized , style: UIAlertAction.Style.default, handler: {  (action) in
            buttonOk(false)
        }))
        
        alertController.addAction(UIAlertAction(title: buttonText , style: UIAlertAction.Style.default, handler: {  (action) in
            buttonOk(true)
        }))
        
       UIApplication.getTopViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    
   
    
    //MARK: - convert arabic number to English
    class func toEnglishNumber(number: String) -> String {
        
        var result:NSNumber = 0
        
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "EN")
        
        if let finalText = numberFormatter.number(from: number) {
            
            //            debugPrint("Intial text is: ", number)
            //            debugPrint("Final text is: ", finalText)
            result =  finalText
        }
        return result.stringValue
    }
    
    
  
    
    
    //MARK: - Get Attributed String
    class func GetAttributedString(arrStrings : [String],arrColor : [UIColor], arrFont: [String] , arrSize: [CGFloat], arrNextLineCheck: [Bool],lineSpacing: CGFloat = 8.0) -> NSMutableAttributedString {
        
        var attriString : NSMutableAttributedString?
        let combination = NSMutableAttributedString()
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineSpacing = lineSpacing // Whatever line spacing you want in points
        
        for index in 0..<arrStrings.count {
      
            
            let yourAttributes = [NSAttributedString.Key.foregroundColor: arrColor[index], NSAttributedString.Key.font:UIFont.init(name: arrFont[index], size: arrSize[index])]
            
            if arrNextLineCheck[index] == true {
                
                attriString = NSMutableAttributedString(string:"\n\(arrStrings[index])" , attributes: yourAttributes as [NSAttributedString.Key : Any] )
    
                
            }else{
        
                // *** Apply attribute to string ***
                
                attriString = NSMutableAttributedString(string:" \(arrStrings[index])"  , attributes: yourAttributes as [NSAttributedString.Key : Any])
         
            }
            
            attriString?.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, /attriString?.length))
            
            combination.append(attriString!)
        }
        
        return combination
    }
    
    
    //MARK: - Conversion of UIView to its Image // i.e screenshot
    class func imageWithView(view: UIView) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    
    
    //MARK: - convert array Model To json object
    class func convertArrayIntoJson(array: [Any]?) -> String? {
        
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: array ?? [], options: JSONSerialization.WritingOptions.prettyPrinted)
            
            var string = String(data: jsonData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) ?? ""
            string = string.replacingOccurrences(of: "\n", with: "") as String
            string = string.replacingOccurrences(of: "\\\"", with: "\"") as String
            string = string.replacingOccurrences(of: "\\", with: "") as String // removes \
            // string = string.replacingOccurrences(of: " ", with: "") as String
//            string = string.replacingOccurrences(of: "/", with: "") as String
            
            return string as String
        }
            
        catch let error as NSError {
            
            debugPrint(error.description)
            return ""
        }
    }
    
}



