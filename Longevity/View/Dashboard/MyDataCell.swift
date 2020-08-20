//
//  MyDataCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 12/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class MyDataCell: UICollectionViewCell {
    
    var insightData: UserInsight! {
        didSet {
            if let details = insightData?.details {
                self.tileTitle.text = insightData?.text
                self.riskType.text = details.riskLevel?.text
                self.guageView.image = details.riskLevel?.riskIcon
                self.trendDirection.text = details.trend?.text
                self.trendDirection.textColor = details.sentiment?.tintColor
                self.trendImage.image = details.trend?.trendIcon
                self.trendImage.isHidden = details.trend == .same
            }
        }
    }
    
    lazy var expandCollapseImage: UIImageView = {
        let expandCollapse = UIImageView()
        expandCollapse.image = UIImage(named: "rightArrow")
        expandCollapse.contentMode = .scaleAspectFit
        expandCollapse.translatesAutoresizingMaskIntoConstraints = false
        return expandCollapse
    }()
    
    lazy var tileTitle: UILabel = {
        let title = UILabel()
        title.textAlignment = .left
        title.font = UIFont(name: "Montserrat-SemiBold", size: 18)
        title.textColor = UIColor(hexString: "#4E4E4E")
        title.numberOfLines = 2
        title.lineBreakMode = .byWordWrapping
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    lazy var guageView: UIImageView = {
        let guage = UIImageView()
        guage.contentMode = .scaleAspectFit
        guage.translatesAutoresizingMaskIntoConstraints = false
        return guage
    }()
    
    lazy var riskType: UILabel = {
        let risk = UILabel()
        risk.textAlignment = .center
        risk.text = "Medium Risk"
        risk.font = UIFont(name: "Montserrat-SemiBold", size: 18)
        risk.textColor = .themeColor
        risk.numberOfLines = 2
        risk.lineBreakMode = .byWordWrapping
        risk.translatesAutoresizingMaskIntoConstraints = false
        return risk
    }()
    
    lazy var trendImage: UIImageView = {
        let trendimage = UIImageView()
        trendimage.image = UIImage(named: "trending_up")
        trendimage.tintColor = .red
        trendimage.contentMode = .scaleAspectFit
        trendimage.translatesAutoresizingMaskIntoConstraints = false
        return trendimage
    }()
    
    lazy var trendDirection: UILabel = {
        let trend = UILabel()
        trend.textAlignment = .center
        trend.text = "TRENDING DOWN"
        trend.numberOfLines = 0
        trend.lineBreakMode = .byWordWrapping
        trend.font = UIFont(name: "Montserrat-Medium", size: 10)
        trend.translatesAutoresizingMaskIntoConstraints = false
        return trend
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        self.addSubview(expandCollapseImage)
        self.addSubview(tileTitle)
        self.addSubview(guageView)
        self.addSubview(riskType)
        self.addSubview(trendImage)
        self.addSubview(trendDirection)
        
        NSLayoutConstraint.activate([
            self.expandCollapseImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
            self.expandCollapseImage.topAnchor.constraint(equalTo: topAnchor, constant: 10.0),
            self.expandCollapseImage.widthAnchor.constraint(equalToConstant: 24.0),
            self.expandCollapseImage.heightAnchor.constraint(equalTo: self.expandCollapseImage.widthAnchor),
            self.tileTitle.leadingAnchor.constraint(equalTo: self.expandCollapseImage.trailingAnchor, constant: 10.0),
            self.tileTitle.topAnchor.constraint(equalTo: self.expandCollapseImage.topAnchor),
            self.tileTitle.widthAnchor.constraint(lessThanOrEqualToConstant: 110.0),
            self.tileTitle.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10.0),
            self.guageView.leadingAnchor.constraint(greaterThanOrEqualTo: self.tileTitle.trailingAnchor, constant: 10.0),
            self.guageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.guageView.widthAnchor.constraint(equalToConstant: 50.0),
            self.guageView.heightAnchor.constraint(equalTo: self.guageView.widthAnchor),
            self.riskType.leadingAnchor.constraint(equalTo: self.guageView.trailingAnchor),
            self.riskType.topAnchor.constraint(equalTo: self.topAnchor, constant: 10.0),
            self.riskType.bottomAnchor.constraint( equalTo: self.bottomAnchor, constant: -10.0),
            self.trendImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 10.0),
            self.trendImage.heightAnchor.constraint(equalToConstant: 30.0),
            self.trendImage.widthAnchor.constraint(equalTo: self.trendImage.heightAnchor),
            self.trendDirection.topAnchor.constraint(equalTo: self.trendImage.bottomAnchor),
            self.trendDirection.leadingAnchor.constraint(equalTo: self.riskType.trailingAnchor, constant: 10.0),
            self.trendDirection.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10.0),
            self.trendDirection.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10.0),
            self.trendImage.centerXAnchor.constraint(equalTo: self.trendDirection.centerXAnchor)
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
