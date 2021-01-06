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

func generateBorderImage(fromColor color: UIColor) -> UIImage? {
    let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    
    context?.setFillColor(UIColor.white.cgColor)
    context?.setStrokeColor(color.cgColor)
    context?.setLineWidth(2.0)
    context?.fill(rect)
    context?.stroke(rect)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image
}

class CustomButtonFill: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        styleButton()
    }
    
    var cornerRadius: CGFloat = 0 {
            didSet {
                layer.cornerRadius = cornerRadius
                layer.masksToBounds = cornerRadius > 0
            }
        }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        styleButton()
    }
    
    lazy var shadowLayer: UIView = {
        let shadowLayer = UIView(frame: self.frame)
        shadowLayer.backgroundColor = UIColor.clear
        shadowLayer.layer.shadowColor = UIColor.darkGray.cgColor
        shadowLayer.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: self.cornerRadius).cgPath
        shadowLayer.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        shadowLayer.layer.shadowOpacity = 0.5
        shadowLayer.layer.shadowRadius = 1
        shadowLayer.layer.masksToBounds = true
        shadowLayer.clipsToBounds = false
        return shadowLayer
    }()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.shadowLayer.removeFromSuperview()
        self.superview?.addSubview(shadowLayer)
        self.superview?.bringSubviewToFront(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func styleButton() {
        self.setTitleColor(UIColor.white, for: .normal)
        self.setBackgroundColor(UIColor.themeColor, for: .normal)
        self.setBackgroundColor(UIColor(hexString: "#D6D6D6"), for: .disabled)
        self.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 24.0)
        self.cornerRadius = 10.0
    }
}

class CustomSecondaryButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        styleButton()
    }
    
    var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        styleButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func styleButton() {
        self.setTitleColor(UIColor.white, for: .normal)
        self.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 24.0)
        self.cornerRadius = 10.0
    }
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        self.setBackgroundImage(generateImage(fromColor: color), for: state)
    }
    
    func disableSecondaryButton() {
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor(hexString: "#D6D6D6").cgColor
        self.layer.cornerRadius = 10.0
        self.setTitleColor(UIColor(hexString: "#D6D6D6"), for: .normal)
        self.isEnabled = false
    }
    
    func enableButton() {
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.themeColor.cgColor
        self.layer.cornerRadius = 10.0
        self.setTitleColor(.themeColor, for: .normal)
        self.isEnabled = true
    }
}

