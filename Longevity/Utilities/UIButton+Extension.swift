//
//  UIButton+Extension.swift
//  Longevity
//
//  Created by vivek on 14/10/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

extension UIButton {
    convenience init(title: String, target: Any? = nil, action:Selector? = nil) {
        self.init()
        setTitle(title, for: .normal)
        if let target = target, let action = action {
            addTarget(target, action: action, for: .touchUpInside)
        }
    }
}

