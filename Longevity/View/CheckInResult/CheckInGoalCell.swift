//
//  CheckInGoalCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 08/09/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CheckInGoalCell: UICollectionViewCell {
    
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
        let goal = UILabel()
        goal.numberOfLines = 0
        goal.lineBreakMode = .byWordWrapping
        goal.translatesAutoresizingMaskIntoConstraints = false
        return goal
    }()
    
    lazy var citationLabel: UILabel = {
        let citation = UILabel()
        citation.numberOfLines = 0
        citation.isUserInteractionEnabled = true
        citation.lineBreakMode = .byWordWrapping
        citation.translatesAutoresizingMaskIntoConstraints = false
        return citation
    }()
    
    var citationURL: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(goalsView)
        goalsView.addSubview(rowIndex)
        self.addSubview(goalsLabel)
        self.contentView.addSubview(citationLabel)
        
        NSLayoutConstraint.activate([
            goalsView.topAnchor.constraint(equalTo: self.topAnchor, constant: 14.0),
            goalsView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 14.0),
            goalsView.heightAnchor.constraint(equalToConstant: 24.0),
            goalsView.widthAnchor.constraint(equalTo: goalsView.heightAnchor),
            rowIndex.centerXAnchor.constraint(equalTo: goalsView.centerXAnchor),
            rowIndex.centerYAnchor.constraint(equalTo: goalsView.centerYAnchor),
            goalsLabel.topAnchor.constraint(equalTo: goalsView.topAnchor),
            goalsLabel.leadingAnchor.constraint(equalTo: goalsView.trailingAnchor, constant: 14.0),
            goalsLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -14.0),
            citationLabel.topAnchor.constraint(equalTo: goalsLabel.bottomAnchor, constant: 10.0),
            citationLabel.leadingAnchor.constraint(equalTo: goalsLabel.leadingAnchor),
            citationLabel.leadingAnchor.constraint(equalTo: goalsLabel.leadingAnchor),
            citationLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -14.0)
        ])
        
        self.backgroundColor = .white
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doOpenCitation))
        gestureRecognizer.numberOfTapsRequired = 1
        
        self.citationLabel.addGestureRecognizer(gestureRecognizer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(checkIngoal: Goal, goalIndex: Int) {
        let goalTitle = checkIngoal.text
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.regular, size: 17.0),
                                                         .foregroundColor: UIColor.black]
        let attributedInfoText = NSMutableAttributedString(string: goalTitle, attributes: attributes)
        
        let goalDesc = "\n\(checkIngoal.goalDescription)"
        
        let descAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.regular, size: 14.0),
                                                             .foregroundColor: UIColor(hexString: "#9B9B9B")]
        let attributedDescText = NSMutableAttributedString(string: goalDesc, attributes: descAttributes)
        
        attributedInfoText.append(attributedDescText)
        
        self.goalsLabel.attributedText = attributedInfoText
        self.rowIndex.text = "\(goalIndex)"
        
        if let citation = checkIngoal.citation, !citation.isEmpty {
            let linkAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.regular,
                                                                               size: 14.0),
                                                                 .foregroundColor: UIColor(red: 0.05,
                                                                                           green: 0.4, blue: 0.65, alpha: 1.0),
                                                                 .underlineStyle: NSUnderlineStyle.single]
            let attributedCitationText = NSMutableAttributedString(string: self.citationURL,
                                                                   attributes: linkAttributes)
            self.citationLabel.attributedText = attributedCitationText
        }
    }
    
    @objc func doOpenCitation() {
         if let url = URL(string: citationURL) {
            UIApplication.shared.open(url)
         }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.cornerRadius = 5.0
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.cornerRadius = 5.0
        layer.shadowRadius = 1.0
        layer.shadowOpacity = 0.25
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
}
