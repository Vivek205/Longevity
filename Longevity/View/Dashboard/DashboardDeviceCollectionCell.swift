//
//  DashboardDeviceCollectionCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 10/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class DashboardDeviceCollectionCell: UICollectionViewCell {
    
    lazy var deviceIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(named: "Icon-Apple-Health")
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    
    lazy var statusButton: UIButton = {
        let statusbutton = UIButton()
        statusbutton.setImage(UIImage(named: "icon: add"), for: .normal)
        statusbutton.translatesAutoresizingMaskIntoConstraints = false
        return statusbutton
    }()
    
    lazy var deviceStatus: UILabel = {
        let dStatus = UILabel()
        dStatus.text = ""
        dStatus.font = UIFont(name: "Montserrat-SemiBold", size: 10.0)
        dStatus.textColor = .themeColor
        dStatus.textAlignment = .center
        dStatus.translatesAutoresizingMaskIntoConstraints = false
        return dStatus
    }()
    
    lazy var deviceTitle: UILabel = {
        let title = UILabel()
        title.textAlignment = .center
        title.font = UIFont(name: "Montserrat-Medium", size: 20.0)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    lazy var deviceTitle2: UILabel = {
        let title = UILabel()
        title.textAlignment = .center
        title.font = UIFont(name: "Montserrat-Regular", size: 14.0)
        title.numberOfLines = 0
        title.lineBreakMode = .byWordWrapping
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    var borderColor: UIColor = .borderColor
    var isEmptyCell: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        self.addSubview(deviceIcon)
        self.addSubview(statusButton)
        self.addSubview(deviceStatus)
        self.addSubview(deviceTitle)
        self.addSubview(deviceTitle2)
        
        NSLayoutConstraint.activate([
            deviceIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
            deviceIcon.topAnchor.constraint(equalTo: topAnchor, constant: 10.0),
            deviceIcon.heightAnchor.constraint(equalToConstant: 38.0),
            deviceIcon.widthAnchor.constraint(equalToConstant: 38.0),
            
            statusButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
            statusButton.topAnchor.constraint(equalTo: topAnchor, constant: 10.0),
            statusButton.heightAnchor.constraint(equalToConstant: 38.0),
            statusButton.widthAnchor.constraint(equalToConstant: 38.0),
            
            deviceStatus.leadingAnchor.constraint(equalTo: statusButton.leadingAnchor),
            deviceStatus.trailingAnchor.constraint(equalTo: statusButton.trailingAnchor),
            deviceStatus.topAnchor.constraint(equalTo: statusButton.bottomAnchor),
            deviceStatus.heightAnchor.constraint(equalToConstant: 12.0),
            
            deviceTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
            deviceTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
            deviceTitle.centerYAnchor.constraint(equalTo: centerYAnchor),
            deviceTitle2.leadingAnchor.constraint(equalTo: deviceTitle.leadingAnchor),
            deviceTitle2.trailingAnchor.constraint(equalTo: deviceTitle.trailingAnchor),
            deviceTitle2.topAnchor.constraint(equalTo: deviceTitle.bottomAnchor, constant: 5.0),
            deviceTitle2.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.0)
        ])
        
        self.deviceTitle.text = "Healthkit"
        self.deviceTitle2.text = "Sync your health information"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.cornerRadius = 5.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.cornerRadius = 5.0
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.25
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
}
