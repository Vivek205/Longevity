//
//  OfflineNotificationView.swift
//  Longevity
//
//  Created by vivek on 23/10/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class OfflineNotificationView: UIView {
    lazy var backdrop: UIView = {
        let backdrop = UIView()
        backdrop.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return backdrop
    }()

    lazy var card: UIView = {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 10
        return card
    }()

    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(text: "You are offline…", font: UIFont(name: AppFontName.medium, size: 24), textColor: .black, textAlignment: .center, numberOfLines: 1)
        return titleLabel
    }()

    lazy var offlineImg: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "icon: offline")
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()

    lazy var descriptionLabel: UILabel = {
        let label = UILabel(text: "Please check your internet or mobile connection and try again.", font: UIFont(name: AppFontName.regular, size: 16), textColor: .sectionHeaderColor, textAlignment: .center, numberOfLines: 2)
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    lazy var ctaButton: CustomButtonFill = {
        let button = CustomButtonFill(title: "Try Again")
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder:coder)
        self.setupView()
    }

    func setupView() {
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        self.addSubview(backdrop)
        backdrop.anchor(.width(screenWidth), .height(screenHeight))
        backdrop.centerXTo(self.centerXAnchor)
        backdrop.centerYTo(self.centerYAnchor)
//        backdrop.fillSuperview()

        backdrop.addSubview(card)


        card.anchor(.width(screenWidth-30), .height(301))
        card.centerXTo(self.centerXAnchor)
        card.centerYTo(backdrop.centerYAnchor)

        card.addSubview(titleLabel)
        card.addSubview(offlineImg)
        card.addSubview(descriptionLabel)
        card.addSubview(ctaButton)
        titleLabel.anchor(top: card.topAnchor, leading: card.leadingAnchor, bottom: nil, trailing: card.trailingAnchor, padding: .init(top: 18, left: 59, bottom: 0, right: 59))
        offlineImg.anchor(top: titleLabel.bottomAnchor, leading: card.leadingAnchor, bottom: nil, trailing:  card.trailingAnchor, padding: .init(top: 12, left: 12.5, bottom: 0, right: 12.5), size: .init(width: 96, height: 96))
        descriptionLabel.anchor(top: offlineImg.bottomAnchor, leading: card.leadingAnchor, bottom: nil, trailing: card.trailingAnchor, padding: .init(top: 12, left: 18, bottom: 24, right: 17))
//        size: .init(width: , height: 0)
        descriptionLabel.anchor(.width(card.frame.size.width - 35))
        ctaButton.anchor(top: nil, leading: card.leadingAnchor, bottom: card.bottomAnchor, trailing: card.trailingAnchor, padding: .init(top: 0, left: 59, bottom: 24, right: 59), size: .init(width: 0, height: 48))

    }

    deinit {
        print("offline notificitation deinti")
    }
}
