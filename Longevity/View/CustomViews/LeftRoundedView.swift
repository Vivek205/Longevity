//
//  LeftRoundedView.swift
//  Longevity
//
//  Created by vivek on 28/09/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class LeftRoundedView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        styleView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        styleView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        styleView()
    }

    func styleView() {
        let height = self.frame.height
        roundCorners(corners: [.topLeft, .bottomLeft], radius: (height / 2))
    }

}
