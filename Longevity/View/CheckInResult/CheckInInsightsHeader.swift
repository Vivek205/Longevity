//
//  CheckInInsightsHeader.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 08/09/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CheckInInsightsHeader: UICollectionReusableView {
    
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.text = "Insights"
        title.font = UIFont(name: "Montserrat-SemiBold", size: 24.0)
        title.textColor = UIColor(hexString: "#4E4E4E")
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(titleLabel)
        
//        let attributes: [NSAttributedString.Key: Any] = [.font: ,.foregroundColor: UIColor(hexString: "#4E4E4E")]
//        let attributedInfoText = NSMutableAttributedString(string: "Insights", attributes: attributes)
//
//        let insightDesc = "\nAccording to our analysis you should:"
//
//        let descAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Regular", size: 18.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
//        let attributedDescText = NSMutableAttributedString(string: insightDesc, attributes: descAttributes)
//
//        attributedInfoText.append(attributedDescText)
//
//        titleLabel.attributedText = attributedInfoText
        self.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10.0),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10.0),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: -10.0),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10.0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
