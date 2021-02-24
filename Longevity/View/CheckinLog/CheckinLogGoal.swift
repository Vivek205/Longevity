//
//  CheckinLogGoal.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 15/09/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CheckinLogGoal: CheckInLogBaseCell {
    
    var citationURL: String = ""
    
    lazy var containerView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        return container
    }()
    
    lazy var goalsView: UIView = {
        let goalsView = UIView()
        goalsView.backgroundColor = .themeColor
        goalsView.translatesAutoresizingMaskIntoConstraints = false
        goalsView.layer.cornerRadius = 12.0
        goalsView.layer.masksToBounds = true
        return goalsView
    }()
    
    lazy var rowIndex: UILabel = {
        let rowIndex = UILabel()
        rowIndex.font = UIFont(name: "Montserrat-SemiBold", size: 14.0)
        rowIndex.textColor = .white
        
        rowIndex.textAlignment = .center
        rowIndex.translatesAutoresizingMaskIntoConstraints = false
        return rowIndex
    }()
        
    lazy var goalsLabel: UILabel = {
        let goalsLabel = UILabel()
        goalsLabel.numberOfLines = 0
        goalsLabel.lineBreakMode = .byWordWrapping
        goalsLabel.translatesAutoresizingMaskIntoConstraints = false
        return goalsLabel
    }()
    
    lazy var citationLabel: UILabel = {
        let citation = UILabel()
        citation.numberOfLines = 0
        citation.lineBreakMode = .byWordWrapping
        citation.isUserInteractionEnabled = true
        citation.translatesAutoresizingMaskIntoConstraints = false
        return citation
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(containerView)
        containerView.addSubview(goalsView)
        goalsView.addSubview(rowIndex)
        containerView.addSubview(goalsLabel)
        containerView.addSubview(citationLabel)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15.0),
            containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15.0),
            containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5.0),
            containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5.0),
            goalsView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14.0),
            goalsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14.0),
            goalsView.heightAnchor.constraint(equalToConstant: 24.0),
            goalsView.widthAnchor.constraint(equalTo: goalsView.heightAnchor),
            rowIndex.centerXAnchor.constraint(equalTo: goalsView.centerXAnchor),
            rowIndex.centerYAnchor.constraint(equalTo: goalsView.centerYAnchor),
            goalsLabel.topAnchor.constraint(equalTo: goalsView.topAnchor),
            goalsLabel.leadingAnchor.constraint(equalTo: goalsView.trailingAnchor, constant: 14.0),
            goalsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14.0),
            citationLabel.topAnchor.constraint(equalTo: goalsLabel.bottomAnchor, constant: 10.0),
            citationLabel.leadingAnchor.constraint(equalTo: goalsLabel.leadingAnchor),
            citationLabel.trailingAnchor.constraint(equalTo: goalsLabel.trailingAnchor),
            citationLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -14.0)
        ])
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doOpenCitation))
        gestureRecognizer.numberOfTapsRequired = 1
        
        self.citationLabel.addGestureRecognizer(gestureRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.layer.cornerRadius = 5.0
        containerView.layer.masksToBounds = true
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        containerView.layer.cornerRadius = 5.0
        containerView.layer.shadowRadius = 3.0
        containerView.layer.shadowOpacity = 0.25
        containerView.layer.masksToBounds = false
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds,
                                                      cornerRadius: containerView.layer.cornerRadius).cgPath
    }
    
    func setup(goal: Goal, index: Int) {
        let goalTitle = goal.text
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.regular, size: 17.0),.foregroundColor: UIColor.black]
        let attributedInfoText = NSMutableAttributedString(string: goalTitle, attributes: attributes)
        
        if !goal.goalDescription.isEmpty {
            let goalDesc = "\n\(goal.goalDescription)"
            
            let descAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.regular, size: 14.0),.foregroundColor: UIColor(hexString: "#9B9B9B")]
            let attributedDescText = NSMutableAttributedString(string: goalDesc, attributes: descAttributes)
            
            attributedInfoText.append(attributedDescText)
        }
        
        goalsLabel.attributedText = attributedInfoText
        rowIndex.text = "\(index + 1)"
        
        if let citation = goal.citation, !citation.isEmpty {
            self.citationURL = citation
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
    
    @objc func doOpenCitation() {
         if let url = URL(string: citationURL) {
            UIApplication.shared.open(url)
         }
    }
}

