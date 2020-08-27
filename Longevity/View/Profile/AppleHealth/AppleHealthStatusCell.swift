//
//  AppleHealthStatusCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 27/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class AppleHealthStatusCell: UITableViewCell {
    
    lazy var statusImage: UIImageView = {
        let statusimage = UIImageView()
        statusimage.image = UIImage(named: "icon: check mark")
        statusimage.contentMode = .scaleAspectFit
        statusimage.translatesAutoresizingMaskIntoConstraints = false
        return statusimage
    }()
    
    lazy var deviceStatus: UILabel = {
        let status = UILabel()
        status.text = "Connected"
        status.font = UIFont(name: "Montserrat-Medium", size: 24.0)
        status.textColor = UIColor(hexString: "#5AA7A7")
        status.textAlignment = .center
        status.translatesAutoresizingMaskIntoConstraints = false
        return status
    }()
    
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
        
        let horizontaStack = UIStackView(arrangedSubviews: [statusImage, deviceStatus])
        horizontaStack.alignment = .fill
        horizontaStack.axis = .horizontal
        horizontaStack.distribution = .fillProportionally
        horizontaStack.spacing = 10.0
        horizontaStack.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(horizontaStack)
        self.addSubview(howitWorksLabel)
        
        NSLayoutConstraint.activate([
            horizontaStack.topAnchor.constraint(equalTo: topAnchor, constant: 15.0),
            horizontaStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            howitWorksLabel.topAnchor.constraint(equalTo: horizontaStack.bottomAnchor, constant: 15.0),
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
