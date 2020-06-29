//
//  CustomButtonOutlined.swift
//  Longevity
//
//  Created by vivek on 26/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CustomButtonOutlined: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        styleButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        styleButton()
    }

    func styleButton() {
        layer.borderColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
        layer.cornerRadius = CGFloat(10)
        layer.borderWidth = 2
        layer.masksToBounds = true
        self.setTitleColor(#colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1), for: .normal)
    }
}
