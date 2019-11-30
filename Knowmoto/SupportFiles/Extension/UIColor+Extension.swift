//
//  UIColor+Extension.swift
//  Knowmoto
//
//  Created by Apple on 27/07/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation
import UIKit

@available(iOS 11.0, *)
extension UIColor{
    
    static let backGroundHeaderColor:UIColor? = UIColor.init(named: "BackGroundHeaderColor")
    
    static let BackgroundRustColor:UIColor? =  UIColor.init(named: "BackroundRustColor")
    
    static let BackgroundLightRustColor:UIColor? =  UIColor.init(named: "BackgroundLightRustColor")
    
    static let BackgroundLightSkyBlueColor:UIColor? =  UIColor.init(named: "BackgroundLightSkyBlueColor")
    
    static let BlueColor:UIColor? =  UIColor.init(named: "BlueColor")
    
    static let HighlightSkyBlueColor:UIColor? =  UIColor.init(named: "HighlightSkyBlueColor")
    
    static let RedColor:UIColor? =  UIColor.init(named: "RedColor")
    
    static let SubtitleLightGrayColor:UIColor? =  UIColor.init(named: "SubtitleLightGrayColor")
    
    static let BorderColor:UIColor? =  UIColor.init(named: "BorderColor")
    
    static let BackgroundLightSky2BlueColor:UIColor? =  UIColor.init(named: "BackgroundLightSky2BlueColor")
    
     static let BlueColorDisabled:UIColor? =  UIColor.init(named: "BlueColorDisabled")
 
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
