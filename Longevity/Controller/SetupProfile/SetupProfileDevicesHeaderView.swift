//
//  SetupProfileDevicesHeaderView.swift
//  COVID Signals
//
//  Created by vivek on 09/12/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class SetupProfileDevicesHeaderView: UICollectionViewCell {
    lazy var image: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "setupProfileDevices")
        return image
    }()

    lazy var headerLabel: UILabel = {
        let label = UILabel(text: "Health Devices", font: UIFont(name: AppFontName.semibold, size: 24), textColor: .sectionHeaderColor, textAlignment: .center, numberOfLines: 1)
        return label
    }()

    lazy var infoLabel: UILabel = {
        let label = UILabel(text: "Are you using Fitbit or other health tracking devices? Connect them to improve your results.", font: UIFont(name: AppFontName.regular, size: 20), textColor: .sectionHeaderColor, textAlignment: .left, numberOfLines: 0)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(image)
        self.addSubview(headerLabel)
        self.addSubview(infoLabel)

        image.centerXTo(centerXAnchor)
        image.anchor(.top(topAnchor),.width(244), .height(224))
        headerLabel.anchor(top: image.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 24, left: 15, bottom: 0, right: 15))
        infoLabel.anchor(top: headerLabel.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 12, left: 15, bottom: 10, right: 15))
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

}
