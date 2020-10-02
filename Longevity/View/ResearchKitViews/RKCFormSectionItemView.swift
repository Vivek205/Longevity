//
//  RKCFormSectionView.swift
//  Longevity
//
//  Created by vivek on 11/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class RKCFormSectionItemView: UICollectionViewCell {

    lazy var verticalLine: UIView = {
        let verticalLine = UIView()
        verticalLine.backgroundColor = UIColor(hexString: "#D6D6D6")
        verticalLine.translatesAutoresizingMaskIntoConstraints = false
        return verticalLine
    }()
    
    lazy var iconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy var headingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createLayout(heading:String, iconName: String?, cellPosition: CellPosition) {
        let iconNameFromModule = SurveyTaskUtility.shared.getIconName(for: heading)
        self.addSubview(iconImage)
        
        iconImage.image = UIImage(named: iconNameFromModule)
        
        NSLayoutConstraint.activate([
            iconImage.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            iconImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            iconImage.widthAnchor.constraint(equalToConstant: 48.0),
            iconImage.heightAnchor.constraint(equalToConstant: 48.0)
        ])

        self.addSubview(headingLabel)
        headingLabel.text = heading
        NSLayoutConstraint.activate([
            headingLabel.leadingAnchor.constraint(equalTo: iconImage.trailingAnchor, constant: 12),
            headingLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            headingLabel.topAnchor.constraint(equalTo: self.topAnchor),
            headingLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        if cellPosition != .none {
            self.addSubview(verticalLine)
            self.sendSubviewToBack(verticalLine)
            NSLayoutConstraint.activate([
            verticalLine.widthAnchor.constraint(equalToConstant: 1.5),
            verticalLine.centerXAnchor.constraint(equalTo: iconImage.centerXAnchor)])
            if cellPosition == .topmost {
                NSLayoutConstraint.activate([
                    verticalLine.topAnchor.constraint(equalTo: iconImage.centerYAnchor),
                    verticalLine.bottomAnchor.constraint(equalTo: self.bottomAnchor)
                ])
            } else if cellPosition == .center {
                NSLayoutConstraint.activate([
                    verticalLine.topAnchor.constraint(equalTo: self.topAnchor),
                    verticalLine.bottomAnchor.constraint(equalTo: self.bottomAnchor)
                ])
            } else if cellPosition == .bottom {
                NSLayoutConstraint.activate([
                    verticalLine.topAnchor.constraint(equalTo: self.topAnchor),
                    verticalLine.bottomAnchor.constraint(equalTo: iconImage.centerYAnchor)
                ])
            }
        }
    }
}
