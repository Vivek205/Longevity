//
//  CheckInInsightCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 08/09/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CheckInInsightCell: UICollectionViewCell {

    var inSight: Goal! {
        didSet {
            let insightTitle = inSight?.text ?? ""
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-SemiBold", size: 18.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
            let attributedinsightTitle = NSMutableAttributedString(string: insightTitle, attributes: attributes)
            
            if inSight.goalDescription.isEmpty ?? false {
                let insightDesc = "\n\n\(inSight?.goalDescription ?? "")"
                
                let descAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Regular", size: 14.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
                let attributedDescText = NSMutableAttributedString(string: insightDesc, attributes: descAttributes)
                
                attributedinsightTitle.append(attributedDescText)
            }
            
            insightsLabel.attributedText = attributedinsightTitle
        }
    }
    
    lazy var insightsLabel: UILabel = {
        let insight = UILabel()
        insight.numberOfLines = 0
        insight.lineBreakMode = .byWordWrapping
        insight.translatesAutoresizingMaskIntoConstraints = false
        return insight
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(insightsLabel)
        
        NSLayoutConstraint.activate([
            insightsLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10.0),
            insightsLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            insightsLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            insightsLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -10.0)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
