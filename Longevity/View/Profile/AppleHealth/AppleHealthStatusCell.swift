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

        self.addSubview(howitWorksLabel)
        
        NSLayoutConstraint.activate([
            howitWorksLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15.0),
            howitWorksLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15.0),
            howitWorksLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15.0),
            howitWorksLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0)
        ])
        
        let howitworksLabel = "To change settings, go to Apple Health."
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Italic", size: 14.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
        let attributedInfoText = NSMutableAttributedString(string: howitworksLabel, attributes: attributes)
        
        let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String
        
        let howitworksDescription = "\n\niOS Settings > Health > Data \nAccess & Devices > \(appName ?? "")"
        let attributes2: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.medium, size: 14.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
        let attributedDescription = NSMutableAttributedString(string: howitworksDescription, attributes: attributes2)
        
        attributedInfoText.append(attributedDescription)
        
        self.howitWorksLabel.attributedText = attributedInfoText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
