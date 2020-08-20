//
//  ProfileSettingsCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 20/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class ProfileSettingsCell: UITableViewCell {
    
    
    
    lazy var settingBGView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.translatesAutoresizingMaskIntoConstraints = false
        return bgView
    }()
    
    lazy var settingName: UILabel = {
        let settingname = UILabel()
        settingname.font = UIFont(name: "Montserrat-Medium", size: 18.0)
        settingname.translatesAutoresizingMaskIntoConstraints = false
        return settingname
    }()
    
    lazy var settingsActionImage: UIImageView = {
        let actionImage = UIImageView()
        actionImage.contentMode = .scaleAspectFit
        actionImage.translatesAutoresizingMaskIntoConstraints = false
        return actionImage
    }()
    
    lazy var settingsSwitch: UISwitch = {
        let settingsswitch = UISwitch()
        settingsswitch.tintColor = .themeColor
        settingsswitch.translatesAutoresizingMaskIntoConstraints = false
        return settingsswitch
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        
        self.addSubview(settingBGView)
        settingBGView.addSubview(settingName)
        settingBGView.addSubview(settingsActionImage)
        settingBGView.addSubview(settingsSwitch)
        
        NSLayoutConstraint.activate([
            settingBGView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
            settingBGView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
            settingBGView.topAnchor.constraint(equalTo: topAnchor),
            settingBGView.bottomAnchor.constraint(equalTo: bottomAnchor),
            settingName.centerYAnchor.constraint(equalTo: settingBGView.centerYAnchor),
            settingName.leadingAnchor.constraint(equalTo: settingBGView.leadingAnchor, constant: 10.0),
            settingsActionImage.trailingAnchor.constraint(equalTo: settingBGView.trailingAnchor, constant: -10.0),
            settingsActionImage.widthAnchor.constraint(equalToConstant: 30.0),
            settingsActionImage.heightAnchor.constraint(equalTo: settingsActionImage.widthAnchor),
            settingsActionImage.centerYAnchor.constraint(equalTo: settingBGView.centerYAnchor),
            settingsActionImage.leadingAnchor.constraint(greaterThanOrEqualTo: settingName.trailingAnchor, constant: 10.0),
            settingsSwitch.trailingAnchor.constraint(equalTo: settingBGView.trailingAnchor, constant: -10.0),
            settingsSwitch.centerYAnchor.constraint(equalTo: settingBGView.centerYAnchor),
            settingsSwitch.leadingAnchor.constraint(greaterThanOrEqualTo: settingName.trailingAnchor, constant: 10.0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}
