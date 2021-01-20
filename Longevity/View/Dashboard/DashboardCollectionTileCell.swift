//
//  DashboardCollectionTileView.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 08/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class DashboardCollectionTileCell: CommonHexagonCell {
    
    var insightData: UserInsight! {
        didSet {
            self.tileTitle.text = insightData.name.hexagonTitle
            self.trendDirection.isHidden = false
            self.trendImage.isHidden = false
            
            if let details = insightData?.details {
                if let risklevel = details.riskLevel {
                    self.riskType.isHidden = false
                    self.riskType.text = risklevel.hexagontext
                    self.riskType.font = risklevel.textFont
                    self.riskType.textColor = .themeColor
                    self.guageView.image = risklevel.riskIcon
                } else {
                    self.riskType.text = RiskLevel.none.text
                    self.riskType.font = RiskLevel.none.textFont
                    self.riskType.textColor = UIColor(hexString: "#9B9B9B")
                    self.guageView.image =  RiskLevel.none.riskIcon
                }
                
                if let trending = details.trending {
                    self.trendDirection.text = trending.text
                    self.trendDirection.textColor = details.sentiment?.tintColor
                    self.trendImage.image = trending.trendIcon
                    self.trendImage.tintColor = details.sentiment?.tintColor
                    self.trendImage.isHidden = trending == .same
                } else {
                    self.trendImage.isHidden = true
                    self.trendDirection.isHidden = true
                }
            } else {
                self.riskType.text = RiskLevel.none.text
                self.riskType.font = RiskLevel.none.textFont
                self.riskType.textColor = UIColor(hexString: "#9B9B9B")
                self.guageView.image =  RiskLevel.none.riskIcon
                self.trendDirection.isHidden = true
                self.trendImage.isHidden = true
            }
        }
    }
    
    lazy var tileTitle: UILabel = {
        let title = UILabel()
        title.textAlignment = .center
        title.text = ""
        title.font = UIFont(name: AppFontName.medium, size: 14)
        title.textColor = .checkinCompleted
        title.numberOfLines = 0
        title.lineBreakMode = .byWordWrapping
        title.isUserInteractionEnabled = false
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    lazy var guageView: UIImageView = {
        let guage = UIImageView()
        guage.contentMode = .scaleAspectFit
        guage.isUserInteractionEnabled = false
        guage.translatesAutoresizingMaskIntoConstraints = false
        return guage
    }()
    
    lazy var riskType: UILabel = {
        let risk = UILabel()
        risk.textAlignment = .center
        risk.text = "Medium Risk"
        risk.font = UIFont(name: AppFontName.semibold, size: 18)
        risk.textColor = .themeColor
        risk.numberOfLines = 0
        risk.lineBreakMode = .byWordWrapping
        risk.isUserInteractionEnabled = false
        risk.translatesAutoresizingMaskIntoConstraints = false
        return risk
    }()

    lazy var trendDirection: UILabel = {
        let trend = UILabel()
        trend.textAlignment = .center
        trend.text = "TRENDING DOWN"
        trend.numberOfLines = 0
        trend.lineBreakMode = .byWordWrapping
        trend.isUserInteractionEnabled = false
        trend.font = UIFont(name: AppFontName.medium, size: 10)
        trend.translatesAutoresizingMaskIntoConstraints = false
        return trend
    }()
    
    lazy var trendImage: UIImageView = {
        let trendimage = UIImageView()
        trendimage.image = UIImage(named: "trending_up")
        trendimage.contentMode = .scaleAspectFit
        trendimage.isUserInteractionEnabled = false
        trendimage.translatesAutoresizingMaskIntoConstraints = false
        return trendimage
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.hexagonView.backgroundColor = .hexagonColor
    }
    
    func setupCell(index: Int) {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.tileTitle.textColor = .checkinCompleted
        self.hexagonView.backgroundColor = .hexagonColor
        self.hexagonView.borderColor = .borderColor
        self.hexagonView.isEmptyCell = false
        
        self.hexagonView.addSubview(tileTitle)
        self.hexagonView.addSubview(guageView)
        self.hexagonView.addSubview(riskType)
        self.hexagonView.addSubview(trendDirection)
        self.hexagonView.addSubview(trendImage)
        
        let isEvenCell = index % 2 == 0
        let vTop = isEvenCell ? 0.0 : self.bounds.height * 0.40
        
        NSLayoutConstraint.activate([
            hexagonView.topAnchor.constraint(equalTo: self.topAnchor, constant: vTop),
            tileTitle.leadingAnchor.constraint(equalTo: hexagonView.leadingAnchor, constant: 15.0),
            tileTitle.trailingAnchor.constraint(equalTo: hexagonView.trailingAnchor, constant: -15.0),
            tileTitle.topAnchor.constraint(equalTo: hexagonView.topAnchor, constant: 25.0),
            guageView.topAnchor.constraint(equalTo: tileTitle.bottomAnchor, constant: 6.0),
            guageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
            guageView.heightAnchor.constraint(equalTo: guageView.widthAnchor),
            guageView.leadingAnchor.constraint(equalTo: hexagonView.leadingAnchor, constant: 22.0),
            riskType.topAnchor.constraint(equalTo: guageView.topAnchor),
            riskType.leadingAnchor.constraint(equalTo: guageView.trailingAnchor),
            riskType.trailingAnchor.constraint(equalTo: hexagonView.trailingAnchor, constant: -20.0),
            riskType.bottomAnchor.constraint(equalTo: guageView.bottomAnchor),
            trendDirection.topAnchor.constraint(equalTo: riskType.bottomAnchor),
            trendDirection.leadingAnchor.constraint(equalTo: hexagonView.leadingAnchor, constant: 5.0),
            trendDirection.trailingAnchor.constraint(equalTo: hexagonView.trailingAnchor, constant: -5.0),
            trendImage.topAnchor.constraint(lessThanOrEqualTo: trendDirection.bottomAnchor, constant: 10.0),
            trendImage.heightAnchor.constraint(equalToConstant: 30.0),
            trendImage.widthAnchor.constraint(equalTo: trendImage.heightAnchor),
            trendImage.centerXAnchor.constraint(equalTo: hexagonView.centerXAnchor),
            trendImage.bottomAnchor.constraint(lessThanOrEqualTo: hexagonView.bottomAnchor, constant: -10.0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let path = self.hexagonView.shapePath {
            contentView.layer.masksToBounds = true
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 1.0)
            layer.shadowRadius = 2.0
            layer.shadowOpacity = 0.3
            layer.masksToBounds = false
        }
    }
    
    @objc func doOpenMyDataTab() {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        guard let tabBarController =  appdelegate.window?.rootViewController as? LNTabBarViewController else {
            return
        }
        tabBarController.selectedIndex = 1
        guard let viewController = tabBarController.viewControllers?[1] as? MyDataViewController else {
            return
        }
        viewController.expandItemfor(insightType: self.insightData.name)
    }
    
    override func doOpenInfo() {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        guard let tabBarController =  appdelegate.window?.rootViewController as? LNTabBarViewController else {
            return
        }
        tabBarController.selectedIndex = 1
        guard let viewController = tabBarController.viewControllers?[1] as? MyDataViewController else {
            return
        }
        viewController.expandItemfor(insightType: self.insightData.name)
    }
}
