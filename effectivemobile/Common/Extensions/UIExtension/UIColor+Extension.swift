//
//  UIColor+Extension.swift
//  effectivemobile
//
//  Created by ellkaden on 23.09.2025.
//

import UIKit

extension UIColor {
    
    static let background = UIColor(red: 4/255, green: 4/255, blue: 4/255, alpha: 1.0)
    static let fiftyPercentWhite = UIColor(hex: "F4F4F4", alpha: 0.5)
    static let backgroundGray = UIColor(hex: "#272729")
    static let yellowButton = UIColor(hex: "#FED702") //#272729


    
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            self.init(red: 0, green: 0, blue: 0, alpha: alpha)
            return
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

