//
//  CheckInLogNoDataView.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 25/09/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

class CheckInLogNoDataView: UIView {
    
    lazy var iconView:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "img :  thumbs up")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.checkinCompleted
        label.font = UIFont(name: "Montserrat-Light", size: 16)
        label.text = "No Check-ins recorded"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    lazy var info:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Montserrat-Light", size: 14)
        label.text = "Start your first one today"
        label.textColor = UIColor.infoColor
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var checkinButton: UIButton = {
        let checkinButton = UIButton()
        checkinButton.setTitle("Check-in", for: .normal)
        checkinButton.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 24.0)
        checkinButton.setTitleColor(.themeColor, for: .normal)
        checkinButton.backgroundColor = .clear
        checkinButton.translatesAutoresizingMaskIntoConstraints = false
        return checkinButton
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = .clear
        self.addSubview(iconView)
        self.addSubview(titleLabel)
        self.addSubview(info)
        self.addSubview(checkinButton)

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20.0),
            iconView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            iconView.heightAnchor.constraint(equalToConstant:  CGFloat(50)),
            iconView.widthAnchor.constraint(equalToConstant:  CGFloat(50)),

            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: CGFloat(5)),
            titleLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40),

            info.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            info.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: CGFloat(5)),
            info.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40),
            
            checkinButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 75.0),
            checkinButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -75.0),
            checkinButton.topAnchor.constraint(equalTo: self.info.bottomAnchor, constant: 20.0),
            checkinButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10.0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        checkinButton.layer.cornerRadius = 10.0
        checkinButton.layer.borderWidth = 2.0
        checkinButton.layer.borderColor = UIColor.themeColor.cgColor
    }
}
