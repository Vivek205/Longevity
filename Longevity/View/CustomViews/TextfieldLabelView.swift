//
//  TextfieldLabelView.swift
//  Longevity
//
//  Created by vivek on 19/10/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class TextfieldLabelView: UIView {
    var label: UILabel?
    var bgGradientColors: [UIColor]?

    convenience init(label:UILabel, bgGradientColors: [UIColor]) {
        self.init()
        self.bgGradientColors = bgGradientColors
        self.label = label
        self.addSubview(label)
        label.fillSuperview()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let label = self.label {
            self.addSubview(label)
            label.fillSuperview()
        }
        if let bgGradientColors = bgGradientColors {
            self.addColors(colors: bgGradientColors)
        }
    }
}

extension TextfieldLabelView {
    func attach(to textfield: UITextField) {
        self.layoutSubviews()
        self.centerYTo(textfield.topAnchor)
        self.anchor(.leading(textfield.leadingAnchor, constant: 20))
        if let width = label?.frame.size.width {
            self.anchor(.width(width))
        }
    }
}
