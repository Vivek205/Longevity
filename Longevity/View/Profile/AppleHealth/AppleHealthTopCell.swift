//
//  AppleHealthTopCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 27/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class AppleHealthTopCell: UITableViewCell {
    
    lazy var healthKitImage: UIImageView = {
        let healthkitImage = UIImageView()
        healthkitImage.image = UIImage(named: "healthkitIcon")
        healthkitImage.contentMode = .scaleAspectFit
        healthkitImage.translatesAutoresizingMaskIntoConstraints = false
        return healthkitImage
    }()
    
    lazy var appLogoImage: UIImageView = {
        let logoImage = UIImageView()
        logoImage.image = UIImage(named: "rejuveIcon")
        logoImage.contentMode = .scaleAspectFit
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        return logoImage
    }()
    
    lazy var connectionStateIcon: UIImageView = {
        let stateIcon = UIImageView()
        stateIcon.image = UIImage(named: "icon sync")?.withRenderingMode(.alwaysTemplate)
        stateIcon.contentMode = .scaleAspectFit
        stateIcon.translatesAutoresizingMaskIntoConstraints = false
        return stateIcon
    }()
    
    lazy var healthkitName: UILabel = {
        let healthkitname = UILabel()
        healthkitname.text = "Apple Health"
        healthkitname.font = UIFont(name: "Montserrat-Medium", size: 14.0)
        healthkitname.textColor = UIColor(hexString: "#4E4E4E")
        healthkitname.textAlignment = .center
        return healthkitname
    }()
    
    lazy var appName: UILabel = {
        let appname = UILabel()
        appname.text = "Rejuve"
        appname.font = UIFont(name: "Montserrat-Medium", size: 14.0)
        appname.textColor = UIColor(hexString: "#4E4E4E")
        appname.textAlignment = .center
        return appname
    }()
    
    lazy var healthKitImageView: UIStackView = {
        let healthkitView = UIStackView(arrangedSubviews: [healthKitImage, healthkitName])
        healthkitView.axis = .vertical
        healthkitView.distribution = .fillProportionally
        healthkitView.alignment = .center
        healthkitView.translatesAutoresizingMaskIntoConstraints = false
        return healthkitView
    }()
    
    lazy var rejuveImageView: UIStackView = {
        let rejuveView = UIStackView(arrangedSubviews: [appLogoImage, appName])
        rejuveView.axis = .vertical
        rejuveView.distribution = .fillProportionally
        rejuveView.alignment = .center
        rejuveView.translatesAutoresizingMaskIntoConstraints = false
        return rejuveView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let horizontalStack = UIStackView(arrangedSubviews: [healthKitImageView, connectionStateIcon, rejuveImageView])
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.axis = .horizontal
        horizontalStack.distribution = .fillEqually
        horizontalStack.alignment = .center
        horizontalStack.spacing = 10.0
        
        self.addSubview(horizontalStack)
        
        NSLayoutConstraint.activate([
            healthKitImage.heightAnchor.constraint(equalToConstant: 80.0),
            healthKitImage.widthAnchor.constraint(equalTo: healthKitImage.heightAnchor),
            horizontalStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.0),
            horizontalStack.topAnchor.constraint(equalTo: topAnchor, constant: 10.0),
            horizontalStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0),
            horizontalStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.0),
        ])
        
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(deviceImage: UIImage?, deviceName: String, isConnected: Bool) {
        self.healthKitImage.image = deviceImage
        self.healthkitName.text = deviceName
        if isConnected == true {
            self.connectionStateIcon.tintColor = .themeColor
        } else {
            self.connectionStateIcon.tintColor = .lightGray
        }
    }
}
