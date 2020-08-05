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

    func styleButton() {
        layer.cornerRadius = CGFloat(10)
        layer.masksToBounds = true
        //        layer.backgroundColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
        setBackgroundColor( #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1), for: .normal)
        setBackgroundColor( UIColor.gray, for: .disabled)
        setTitleColor(UIColor.white, for: .normal)
        titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 24)
    }
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
//        func image(withColor color: UIColor) -> UIImage? {
//            let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
//            UIGraphicsBeginImageContext(rect.size)
//            let context = UIGraphicsGetCurrentContext()
//
//            context?.setFillColor(color.cgColor)
//            context?.fill(rect)
//
//            let image = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//
//            return image
//        }
        self.setBackgroundImage(generateImage(fromColor: color), for: state)
    }
}

