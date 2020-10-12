//
//  UIColor+Extension.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 06/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hexString: String) {
        var cString:String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            self.init(ciColor: .gray)
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0))
    }
    
    @nonobjc class var themeColor: UIColor {
        return UIColor(hexString: "#5AA7A7")
    }
    
    @nonobjc class var unselectedColor: UIColor {
        return UIColor(hexString: "#8E8E93")
    }
    
    @nonobjc class var sectionHeaderColor: UIColor {
        return UIColor(hexString: "#4E4E4E")
    }
    
    @nonobjc class var hexagonColor: UIColor {
        return UIColor(hexString: "#FFFFFF")
    }
    
    @nonobjc class var borderColor: UIColor {
        return UIColor(hexString: "#C8C8CC")
    }
    
    @nonobjc class var checkinNotCompleted: UIColor {
        return UIColor(hexString: "#5AA7A7")
    }
    
    @nonobjc class var checkinCompleted: UIColor {
        return UIColor(hexString: "#4A4A4A")
    }
    
    @nonobjc class var statusColor: UIColor {
        return UIColor(hexString: "#9B9B9B")
    }
    
    @nonobjc class var progressColor: UIColor {
        return UIColor(hexString: "#5AA7A7")
    }
    
    @nonobjc class var progressTrackColor: UIColor {
        return UIColor(hexString: "#E5E5EA")
    }

    @nonobjc class var infoColor: UIColor {
        return UIColor(hexString: "#666666")
    }

    @nonobjc class var pageIndicatorTintColor: UIColor {
        return UIColor(hexString: "#D7D7D7")
    }

    @nonobjc class var appBackgroundColor: UIColor {
        return UIColor(hexString: "#F5F6FA")
    }

    @nonobjc class var textInput: UIColor {
        return UIColor(hexString: "#212121")
    }

    @nonobjc class var placeHolder: UIColor {
        return UIColor(hexString: "#C2C2C2")
    }
}
