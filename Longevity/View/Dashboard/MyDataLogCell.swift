//
//  MyDataLogCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 28/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class MyDataLogCell: UICollectionViewCell {
    
    var logData: UserInsight! {
        didSet {
            self.cellTitle.text = logData?.text
//            var durationtext = "\(logData?.details?.history?.count ?? 0) Days"
            var durationtext: String?
            if logData.name == .coughlogs {
                durationtext = "\(logData?.details?.history?.count ?? 0) entries"
            }
            self.logDuration.text = durationtext
        }
    }
    
    lazy var cellTitle: UILabel = {
        let title = UILabel()
        title.textAlignment = .left
        title.font = UIFont(name: "Montserrat-SemiBold", size: 18)
        title.textColor = UIColor(hexString: "#4E4E4E")
        title.numberOfLines = 2
        title.lineBreakMode = .byWordWrapping
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    lazy var logDuration: UILabel = {
        let risk = UILabel()
        risk.textAlignment = .center
        risk.font = UIFont(name: "Montserrat-SemiBold", size: 18)
        risk.textColor = .themeColor
        risk.numberOfLines = 2
        risk.lineBreakMode = .byWordWrapping
        risk.translatesAutoresizingMaskIntoConstraints = false
        return risk
    }()
    
    lazy var navigateActionImage: UIImageView = {
        let actionImage = UIImageView()
        actionImage.image = UIImage(named: "icon: arrow")
        actionImage.contentMode = .scaleAspectFit
        actionImage.isUserInteractionEnabled = false
        actionImage.translatesAutoresizingMaskIntoConstraints = false
        return actionImage
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        self.addSubview(cellTitle)
        self.addSubview(logDuration)
        self.addSubview(navigateActionImage)
        
        NSLayoutConstraint.activate([
            cellTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.5),
            cellTitle.centerYAnchor.constraint(equalTo: centerYAnchor),
            navigateActionImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.5),
            navigateActionImage.widthAnchor.constraint(equalToConstant: 25.0),
            navigateActionImage.heightAnchor.constraint(equalTo: navigateActionImage.widthAnchor),
            navigateActionImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            logDuration.widthAnchor.constraint(equalToConstant: 100.0),
            logDuration.leadingAnchor.constraint(greaterThanOrEqualTo: cellTitle.trailingAnchor, constant: 10.0),
            logDuration.centerYAnchor.constraint(equalTo: centerYAnchor),
            logDuration.trailingAnchor.constraint(equalTo: navigateActionImage.leadingAnchor, constant: 10.0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.cornerRadius = 5.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.borderColor.cgColor
        contentView.layer.masksToBounds = true
    }
}

