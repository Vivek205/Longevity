//
//  ContactSupportViewController.swift
//  Longevity
//
//  Created by vivek on 29/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class ContactSupportViewController: BasePopUpModalViewController {
    lazy var locationText:NSAttributedString = {
        let text = NSMutableAttributedString(string: "Moscow, Russia ,\n",
                                             attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)])
        text.append(NSAttributedString(string: "119019, Vozdvizhenka 7/6, \n"))
        text.append(NSAttributedString(string: "building 1"))
        return text
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = "Contact Details"
        self.infoLabel.isHidden = true
        self.actionButton.isHidden = true


        let locationCell = ContactsCell(iconName: "location-icon", contentText: locationText)
        locationCell.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(locationCell)

        let phoneCell = ContactsCell(iconName:"location-icon", contentText: NSAttributedString(string:"+919900880077"))
        phoneCell.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(phoneCell)

        let emailCell = ContactsCell(iconName:"location-icon", contentText: NSAttributedString(string:"support@rejuve.com"))
        emailCell.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(emailCell)

        let screenHeight = UIScreen.main.bounds.height
        //        let modalHeight = screenHeight - (UIDevice.hasNotch ? 100.0 : 60.0)

        NSLayoutConstraint.activate([
            //            containerView.heightAnchor.constraint(equalToConstant: modalHeight),
            locationCell.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            locationCell.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            locationCell.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 2),
            locationCell.heightAnchor.constraint(equalToConstant: 100),

            phoneCell.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            phoneCell.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            phoneCell.topAnchor.constraint(equalTo: locationCell.bottomAnchor, constant: 5),
            phoneCell.heightAnchor.constraint(equalToConstant: 30),

            emailCell.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            emailCell.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            emailCell.topAnchor.constraint(equalTo: phoneCell.bottomAnchor, constant: 5),
            emailCell.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

}


fileprivate class ContactsCell: UIView {
    lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var content:UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(iconName:String, contentText:NSAttributedString) {
        super.init(frame: CGRect.zero)

        self.addSubview(iconView)
        self.addSubview(content)

        iconView.image = UIImage(named: iconName)
        content.attributedText = contentText

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            iconView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 30),
            iconView.heightAnchor.constraint(equalToConstant: 30),

            content.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            content.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            content.topAnchor.constraint(equalTo: self.topAnchor),
            content.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }


}
