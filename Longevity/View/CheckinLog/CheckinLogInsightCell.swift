//
//  CheckinLogInsightCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 15/09/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CheckinLogInsightCell: UITableViewCell {
    
    var insight: Goal! {
        didSet {
            let insightTitle = insight.text
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-SemiBold", size: 18.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
            let attributedinsightTitle = NSMutableAttributedString(string: insightTitle, attributes: attributes)
            
            let insightDesc = "\n\n\(insight.goalDescription)"
            
            let descAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Regular", size: 14.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
            let attributedDescText = NSMutableAttributedString(string: insightDesc, attributes: descAttributes)
            
            attributedinsightTitle.append(attributedDescText)
            insightsLabel.attributedText = attributedinsightTitle
        }
    }
    
    lazy var insightsLabel: UILabel = {
        let insightsLabel = UILabel()
        insightsLabel.numberOfLines = 0
        insightsLabel.lineBreakMode = .byWordWrapping
        insightsLabel.translatesAutoresizingMaskIntoConstraints = false
        return insightsLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(insightsLabel)
        
        NSLayoutConstraint.activate([
            insightsLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14.0),
            insightsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14.0),
            insightsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14.0),
            insightsLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -14.0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
