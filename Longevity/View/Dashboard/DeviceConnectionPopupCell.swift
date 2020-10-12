//
//  DeviceConnectionPopupCell.swift
//  Longevity
//
//  Created by vivek on 07/09/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class DeviceConnectionPopupCell: UICollectionViewCell {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont(name: "Montserrat-SemiBold", size: 18)
        label.textColor = .sectionHeaderColor
        return label
    }()

    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont(name: "Montserrat-Regular", size: 16)
        label.textColor = .sectionHeaderColor
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(titleLabel)
        self.addSubview(infoLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor),

            infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            infoLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            infoLabel.widthAnchor.constraint(equalTo: widthAnchor)
        ])
    }

    func setText(title:String?, info:String?) {
        titleLabel.text = title
        infoLabel.text = info
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
