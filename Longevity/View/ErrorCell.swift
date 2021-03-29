//
//  ErrorCell.swift
//  COVID Signals
//
//  Created by Jagan Kumar Mudila on 29/03/2021.
//  Copyright © 2021 vivek. All rights reserved.
//

import UIKit

class ErrorCell: UICollectionViewCell {
    
    lazy var errorMessageLabel: UILabel = {
        let insightsLabel = UILabel()
        insightsLabel.numberOfLines = 0
        insightsLabel.lineBreakMode = .byWordWrapping
        insightsLabel.translatesAutoresizingMaskIntoConstraints = false
        return insightsLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(errorMessageLabel)
        
        NSLayoutConstraint.activate([
            errorMessageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14.0),
            errorMessageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14.0),
            errorMessageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14.0),
            errorMessageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14.0),
        ])
        
        let textheader = "Error occurred while fetching the data. Please try again later."
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.medium, size: 14.0)!,
                                                         .foregroundColor: UIColor(hexString: "#4E4E4E")]
        let attributedCoughResult = NSMutableAttributedString(string: textheader, attributes: attributes)
        errorMessageLabel.attributedText = attributedCoughResult
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

