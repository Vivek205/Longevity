//
//  DashboardTaskCompletedCell.swift
//  Longevity
//
//  Created by vivek on 29/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class DashboardTaskCompletedCell: UITableViewCell {
    lazy var iconView:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "icon: tasks-completed")
        return imageView
    }()

    lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.checkinCompleted
        label.font = UIFont(name: "Montserrat-Light", size: 16)
        label.text = "All completed"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    lazy var info:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Montserrat-Light", size: 14)
        label.text = "Check back for later for new tasks"
        label.textColor = UIColor.infoColor
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.addSubview(iconView)
        self.addSubview(titleLabel)
        self.addSubview(info)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            iconView.heightAnchor.constraint(equalToConstant:  CGFloat(50)),
            iconView.widthAnchor.constraint(equalToConstant:  CGFloat(50)),

            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: CGFloat(5)),
            titleLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40),

            info.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            info.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: CGFloat(5)),
            info.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
