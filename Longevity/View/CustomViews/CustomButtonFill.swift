//
//  CustomButtonFill.swift
//  Longevity
//
//  Created by vivek on 16/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

func generateImage(fromColor color: UIColor) -> UIImage? {
    let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    
    context?.setFillColor(color.cgColor)
    context?.fill(rect)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image
}

class CustomButtonFill: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        styleButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        styleButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //Removing all existing layers
        if let layers = layer.sublayers {
            for layer in layers {
                if let name = layer.name, name.contains("shadowLayer") {
                    layer.removeFromSuperlayer()
                }
            }
        }
        
        let shadowLayer = CAShapeLayer()
        shadowLayer.name = "shadowLayer"
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 10).cgPath
        shadowLayer.fillColor = self.isEnabled ? UIColor.themeColor.cgColor : UIColor(hexString: "#D6D6D6").cgColor
        
        shadowLayer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        shadowLayer.shadowOpacity = 0.8
        shadowLayer.shadowRadius = 2
        
        layer.insertSublayer(shadowLayer, at: 0)
    }
    
    func styleButton() {
        setTitleColor(UIColor.white, for: .normal)
        titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 24.0)
    }
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        self.setBackgroundImage(generateImage(fromColor: color), for: state)
    }
}

