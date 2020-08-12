//
//  RKCFormSectionView.swift
//  Longevity
//
//  Created by vivek on 11/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class RKCFormSectionItemView: UICollectionViewCell {

    lazy var circleImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = imageView.frame.width / 2
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

    func createLayout(heading:String) {
        self.addSubview(circleImage)
        circleImage.image = UIImage(named: "icon: checkbox-selected")
        NSLayoutConstraint.activate([
            circleImage.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            circleImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            circleImage.widthAnchor.constraint(equalToConstant: 48.0),
            circleImage.heightAnchor.constraint(equalToConstant: 48.0)
        ])

        self.addSubview(headingLabel)
        headingLabel.text = heading
        NSLayoutConstraint.activate([
            headingLabel.leadingAnchor.constraint(equalTo: circleImage.trailingAnchor, constant: 20),
            headingLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            headingLabel.topAnchor.constraint(equalTo: self.topAnchor),
            headingLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

    }
}
