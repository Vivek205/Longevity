//
//  RKCFormSectionView.swift
//  Longevity
//
//  Created by vivek on 11/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class RKCFormSectionItemView: UICollectionViewCell {

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

    func createLayout(heading:String, iconName: String?) {
        let defaultIconName:String = "icon : GI"
        let iconNameFromModule = SurveyTaskUtility.iconNameForModuleName[heading] ?? defaultIconName
//
        self.addSubview(iconImage)
        iconImage.image = UIImage(named: iconNameFromModule!)
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

    }
}
