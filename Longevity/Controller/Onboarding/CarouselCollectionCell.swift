//
//  CarouselCollectionCell.swift
//  Longevity
//
//  Created by vivek on 01/09/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CarouselCollectionCell: UICollectionViewCell {

    var carouselDetails: OnboardingCarouselData? {
        didSet {
            backgroundImage.image = UIImage(named: carouselDetails?.bgImageName ?? "")
            carouselImage.image = UIImage(named: carouselDetails?.carouselImageName ?? "")
            titleLabel.text = carouselDetails?.titleText
            infoLabel.text = carouselDetails?.infoText
        }
    }

    lazy var backgroundImage:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var carouselImage:UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "adfld"
        label.numberOfLines = 0
        label.textColor = .sectionHeaderColor
        label.font = UIFont(name: "Montserrat-SemiBold", size: 32)
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        return label
    }()

    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "alfdjslfjasldfjl"
        label.numberOfLines = 0
        label.textColor = .sectionHeaderColor
        label.font = UIFont(name: "Montserrat-Regular", size: 20)
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .justified
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

//        self.addSubview(carouselImage)
              self.addSubview(backgroundImage)
              self.addSubview(carouselImage)
              self.addSubview(titleLabel)
              self.addSubview(infoLabel)

        let backgroundImageHeight:CGFloat = self.bounds.height * 0.87
        let titleLabelTopMargin:CGFloat = UIDevice.hasNotch ? 20.0 : 5.0
        let infoLabelTopMargin:CGFloat = UIDevice.hasNotch ? 20.0 : 5.0

        NSLayoutConstraint.activate([
            backgroundImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            backgroundImage.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundImage.heightAnchor.constraint(equalToConstant: backgroundImageHeight),

            carouselImage.leadingAnchor.constraint(equalTo: backgroundImage.leadingAnchor, constant: 74),
            carouselImage.trailingAnchor.constraint(equalTo: backgroundImage.trailingAnchor, constant: -74),
            carouselImage.topAnchor.constraint(equalTo: backgroundImage.topAnchor, constant: 63),
            carouselImage.heightAnchor.constraint(equalTo: carouselImage.widthAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: self.carouselImage.bottomAnchor,
                                            constant: CGFloat(titleLabelTopMargin)),

            infoLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            infoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: infoLabelTopMargin)
//            infoLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    
}
