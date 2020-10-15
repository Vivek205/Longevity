//
//  UITextField+Extension.swift
//  Longevity
//
//  Created by vivek on 14/10/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

extension UITextField {
    convenience public init(placeholder: String, keyboardType: UIKeyboardType ) {
        self.init()
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        backgroundColor = .white
        layer.borderColor = UIColor.borderColor.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 4

        let paddingView = UIView(frame: .init(x: 0, y: 0, width: 15, height: frame.height))
        leftView = paddingView
        leftViewMode = .always
    }
}
