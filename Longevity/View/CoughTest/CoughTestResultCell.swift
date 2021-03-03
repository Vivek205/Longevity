//
//  CoughTestResultCell.swift
//  COVID Signals
//
//  Created by Jagan Kumar Mudila on 03/03/2021.
//  Copyright © 2021 vivek. All rights reserved.
//

import UIKit

class CoughTestResultCell: UICollectionViewCell {
    
    var coughResultDescription: CoughResultDescription! {
        didSet {
            let textheader = "According to our cough classifier:"
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.medium, size: 14.0),
                                                             .foregroundColor: UIColor(hexString: "#4E4E4E")]
            let attributedCoughResult = NSMutableAttributedString(string: textheader, attributes: attributes)
            
            let insightTitle = "\n\n\(coughResultDescription?.shortDescription ?? "")"
            
            let attributes2: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.semibold, size: 24.0),
                                                              .foregroundColor: UIColor(hexString: "#4E4E4E")]
            attributedCoughResult.append(NSMutableAttributedString(string: insightTitle, attributes: attributes2))
            
            let insightText = "\n\n\(coughResultDescription?.longDescription ?? "")"
            
            let attributes3: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.italic, size: 18.0),
                                                              .foregroundColor: UIColor(hexString: "#4E4E4E")]
            attributedCoughResult.append(NSMutableAttributedString(string: insightText, attributes: attributes3))
            
            coughResultLabel.attributedText = attributedCoughResult
        }
    }
    
    lazy var coughResultLabel: UILabel = {
        let insightsLabel = UILabel()
        insightsLabel.numberOfLines = 0
        insightsLabel.lineBreakMode = .byWordWrapping
        insightsLabel.translatesAutoresizingMaskIntoConstraints = false
        return insightsLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(coughResultLabel)
        
        NSLayoutConstraint.activate([
            coughResultLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14.0),
            coughResultLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14.0),
            coughResultLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14.0),
            coughResultLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14.0),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
