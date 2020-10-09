//
//  AppleHealthStatusCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 27/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class AppleHealthStatusCell: UITableViewCell {
    
    
    
    lazy var howitWorksLabel: UILabel = {
        let howitworks = UILabel()
        howitworks.numberOfLines = 0
        howitworks.textAlignment = .center
        howitworks.lineBreakMode = .byWordWrapping
        howitworks.translatesAutoresizingMaskIntoConstraints = false
        return howitworks
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        
//        let horizontaStack = UIStackView(arrangedSubviews: [statusImage, deviceStatus])
//        horizontaStack.alignment = .fill
//        horizontaStack.axis = .horizontal
//        horizontaStack.distribution = .fillProportionally
//        horizontaStack.spacing = 10.0
//        horizontaStack.translatesAutoresizingMaskIntoConstraints = false
        
//        self.addSubview(statusImage)
//        self.addSubview(deviceStatus)
        self.addSubview(howitWorksLabel)
        
        NSLayoutConstraint.activate([
//            deviceStatus.topAnchor.constraint(equalTo: topAnchor, constant: 15.0),
//            deviceStatus.centerXAnchor.constraint(equalTo: centerXAnchor),
//            statusImage.widthAnchor.constraint(equalToConstant: 30.0),
//            statusImage.heightAnchor.constraint(equalTo: statusImage.widthAnchor),
//            statusImage.centerYAnchor.constraint(equalTo: deviceStatus.centerYAnchor),
//            statusImage.trailingAnchor.constraint(equalTo: deviceStatus.leadingAnchor, constant: 10.0),
            howitWorksLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15.0),
            howitWorksLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15.0),
            howitWorksLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15.0),
            howitWorksLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15.0)
        ])
        
        let howitworksLabel = "Note: Go to Apple Health to change settings."
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Italic", size: 14.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
        let attributedInfoText = NSMutableAttributedString(string: howitworksLabel, attributes: attributes)
        
        let howitworksDescription = "\n\niOS Settings > Health > Data Access & Devices > Rejuve"
        let attributes2: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Medium", size: 14.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
        let attributedDescription = NSMutableAttributedString(string: howitworksDescription, attributes: attributes2)
        
        attributedInfoText.append(attributedDescription)
        
        self.howitWorksLabel.attributedText = attributedInfoText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
