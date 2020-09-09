//
//  CheckInGoalCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 08/09/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CheckInGoalCell: UICollectionViewCell {

    lazy var divider: UIView = {
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor(hexString: "#CECECE")
        return divider
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
        let goal = UILabel()
        goal.numberOfLines = 0
        goal.lineBreakMode = .byWordWrapping
        goal.translatesAutoresizingMaskIntoConstraints = false
        return goal
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(divider)
        self.addSubview(goalsView)
        goalsView.addSubview(rowIndex)
        self.addSubview(goalsLabel)
        
        NSLayoutConstraint.activate([
            divider.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1.0),
            divider.topAnchor.constraint(equalTo: self.topAnchor),
            goalsView.topAnchor.constraint(equalTo: self.topAnchor, constant: 14.0),
            goalsView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 14.0),
            goalsView.heightAnchor.constraint(equalToConstant: 24.0),
            goalsView.widthAnchor.constraint(equalTo: goalsView.heightAnchor),
            rowIndex.centerXAnchor.constraint(equalTo: goalsView.centerXAnchor),
            rowIndex.centerYAnchor.constraint(equalTo: goalsView.centerYAnchor),
            goalsLabel.topAnchor.constraint(equalTo: goalsView.topAnchor),
            goalsLabel.leadingAnchor.constraint(equalTo: goalsView.trailingAnchor, constant: 14.0),
            goalsLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -14.0),
            goalsLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -14.0)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(checkIngoal: Goal, goalIndex: Int) {
        let goalTitle = checkIngoal.text
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Regular", size: 17.0),.foregroundColor: UIColor.black]
        let attributedInfoText = NSMutableAttributedString(string: goalTitle, attributes: attributes)
        
        let goalDesc = "\n\(checkIngoal.goalDescription)"
        
        let descAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Regular", size: 14.0),.foregroundColor: UIColor(hexString: "#9B9B9B")]
        let attributedDescText = NSMutableAttributedString(string: goalDesc, attributes: descAttributes)
        
        attributedInfoText.append(attributedDescText)
        self.goalsLabel.attributedText = attributedInfoText
        self.rowIndex.text = "\(goalIndex)"
    }
}