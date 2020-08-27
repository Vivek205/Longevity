//
//  HowItWorksCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 27/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class HowItWorksCell: UITableViewCell {
    
    lazy var howitWorksLabel: UILabel = {
        let howitworks = UILabel()
        howitworks.numberOfLines = 0
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
            howitWorksLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15.0)
        ])
        
        let howitworksLabel = "How it works"
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-SemiBold", size: 18.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
        let attributedInfoText = NSMutableAttributedString(string: howitworksLabel, attributes: attributes)
        
        let howitworksDescription = "\n\nUse Apple Health to import data from other apps into Rejuve and vice versa. This will help improve AI accuracy for your health analysis and insights.\n\n"
        let attributes2: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Regular", size: 16.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
        let attributedDescription = NSMutableAttributedString(string: howitworksDescription, attributes: attributes2)
        
        let valuesImported = "Which values are imported"
        let attributes3: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-SemiBold", size: 18.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
        let attributedvaluesImported = NSMutableAttributedString(string: valuesImported, attributes: attributes3)
        
        let importedDescription = "\n\nGender, Body Weight, Height, Activity, etc etc, etc, etc ,etc\n\n"
        let attributes4: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Regular", size: 16.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
        let attributedImportedDescription = NSMutableAttributedString(string: importedDescription, attributes: attributes4)
        
        let visitLearnMore = "Visit Rejuve.com to learn more"
        let attributes5: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Medium", size: 18.0),.foregroundColor: UIColor.themeColor]
        let attributedvisitLearnMore = NSMutableAttributedString(string: visitLearnMore, attributes: attributes5)
        
        attributedInfoText.append(attributedDescription)
        attributedInfoText.append(attributedvaluesImported)
        attributedInfoText.append(attributedImportedDescription)
        attributedInfoText.append(attributedvisitLearnMore)
        
        self.howitWorksLabel.attributedText = attributedInfoText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
