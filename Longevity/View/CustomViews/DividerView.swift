//
//  DividerView.swift
//  Longevity
//
//  Created by vivek on 15/10/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class DividerView: UIView {

    convenience init(text: String) {
        self.init()
        label.text = text
    }

    lazy var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = .borderColor
        return line
    }()

    lazy var labelView: UIView = {
        let view = UIView()
        view.backgroundColor = .appBackgroundColor

        return view
    }()

    lazy var label: UILabel = {
        let label = UILabel(text: "Ok", font: UIFont(name: AppFontName.regular, size: 14), textColor: .textInput, textAlignment: .center, numberOfLines: 1)

        return label
    }()

    override func layoutSubviews() {
        addSubview(lineView)
        addSubview(labelView)
        labelView.addSubview(label)

        lineView.anchor(.leading(leadingAnchor, constant: 0), .trailing(trailingAnchor, constant: 0), .height(1))
        lineView.centerYTo(centerYAnchor)

        labelView.centerInSuperview(size: .init(width: 30, height: 30))
        label.fillSuperview()
    }
}
