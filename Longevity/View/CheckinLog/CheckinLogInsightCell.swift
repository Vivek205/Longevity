//
//  CheckinLogInsightCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 15/09/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CheckinLogInsightCell: CheckInLogBaseCell {
    
    var insight: Goal! {
        didSet {
            let insightTitle = insight.text
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.semibold, size: 18.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
            let attributedinsightTitle = NSMutableAttributedString(string: insightTitle, attributes: attributes)
            
            let insightDesc = "\n\n\(insight.goalDescription)"
            
            let descAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.regular, size: 14.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
            let attributedDescText = NSMutableAttributedString(string: insightDesc, attributes: descAttributes)
            
            attributedinsightTitle.append(attributedDescText)
            insightsLabel.attributedText = attributedinsightTitle
            
            if let citation = insight.citation, !citation.isEmpty {
                let linkAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.regular,
                                                                                   size: 14.0),
                                                                     .foregroundColor: UIColor(red: 0.05,
                                                                                               green: 0.4, blue: 0.65, alpha: 1.0),
                                                                     .underlineStyle: NSUnderlineStyle.single]
                let attributedCitationText = NSMutableAttributedString(string: citation,
                                                                       attributes: linkAttributes)
                self.citationLabel.attributedText = attributedCitationText
            }
        }
    }
    
    lazy var insightsLabel: UILabel = {
        let insightsLabel = UILabel()
        insightsLabel.numberOfLines = 0
        insightsLabel.lineBreakMode = .byWordWrapping
        insightsLabel.translatesAutoresizingMaskIntoConstraints = false
        return insightsLabel
    }()
    
    lazy var citationLabel: UILabel = {
        let citation = UILabel()
        citation.numberOfLines = 0
        citation.lineBreakMode = .byWordWrapping
        citation.translatesAutoresizingMaskIntoConstraints = false
        return citation
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(insightsLabel)
        self.contentView.addSubview(citationLabel)
        
        NSLayoutConstraint.activate([
            insightsLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14.0),
            insightsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14.0),
            insightsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14.0),
            citationLabel.topAnchor.constraint(equalTo: insightsLabel.bottomAnchor, constant: 10.0),
            citationLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            citationLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            citationLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -14.0)
        ])
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doOpenCitation))
        gestureRecognizer.numberOfTapsRequired = 1
        
        self.citationLabel.addGestureRecognizer(gestureRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func doOpenCitation() {
        if let citation = self.insight.citation,
           let url = URL(string: citation) {
            UIApplication.shared.open(url)
        }
    }
}
