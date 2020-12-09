//
//  CheckInNextGoals.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 08/09/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CheckInNextGoals: UICollectionReusableView {
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.font = UIFont(name: AppFontName.medium, size: 14.0)
        title.text = "YOUR NEXT GOALS"
        title.textColor = UIColor(hexString: "#4E4E4E")
        title.numberOfLines = 0
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

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

