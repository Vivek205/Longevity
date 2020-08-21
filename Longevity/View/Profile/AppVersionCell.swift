//
//  AppVersionCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 20/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class AppVersionCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        
        let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? ""
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] ?? ""
        
        let appNameLabel = UILabel()
        appNameLabel.text = "Rejuve \(shortVersion) (\(buildNumber))\n© 2020"
        appNameLabel.numberOfLines = 2
        appNameLabel.font = UIFont(name: "Montserrat-Light", size: 18.0)
        appNameLabel.textColor = UIColor(hexString: "#4E4E4E")
        appNameLabel.textAlignment = .center
        appNameLabel.lineBreakMode = .byWordWrapping
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(appNameLabel)
        
        NSLayoutConstraint.activate([
            appNameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 100.0),
            appNameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -100.0),
            appNameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
