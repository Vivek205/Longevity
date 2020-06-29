//
//  CustomButtonFill.swift
//  Longevity
//
//  Created by vivek on 16/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

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
        layer.backgroundColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
        setTitleColor(UIColor.white, for: .normal)
        titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 24)
    }

}
