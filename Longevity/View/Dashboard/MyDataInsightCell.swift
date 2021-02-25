//
//  MyDataCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 12/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class MyDataInsightCell: UICollectionViewCell {
    
    var insightData: UserInsight! {
        didSet {
            self.trendDirection.isHidden = false
            self.trendImage.isHidden = false
            self.tileTitle.text = insightData?.name
            
            if let details = insightData?.details {
                if let risklevel = details.riskLevel {
                    self.riskType.isHidden = false
                    self.riskType.text = risklevel.text
                    self.riskType.font = risklevel.textFont
                    self.riskType.textColor = .themeColor
                    self.guageView.image = risklevel.riskIcon
                    self.nodataLabel.isHidden = true
                } else {
                    self.riskType.isHidden = true
                    self.guageView.image =  RiskLevel.none.riskIcon
                    self.nodataLabel.isHidden = false
                }
                
                if let trending = details.trending, trending != .same {
                    self.trendDirection.text = trending.text
                    self.trendImage.image = trending.trendIcon
                    self.trendDirection.textColor = details.sentiment?.tintColor
                    self.trendImage.tintColor = details.sentiment?.tintColor
                    self.trendDirection.isHidden = false
                    self.trendImage.isHidden = false
                } else {
                    self.trendImage.isHidden = true
                    self.trendDirection.isHidden = true
                }
            } else {
                self.riskType.isHidden = true
                self.guageView.image =  RiskLevel.none.riskIcon
                self.trendDirection.isHidden = true
                self.trendImage.isHidden = true
                self.nodataLabel.isHidden = false
            }
            
            self.detailsView.isHidden = !(insightData?.isExpanded ?? false)
            self.detailsView.insightData = insightData
            
            if insightData?.isExpanded ?? false {
                expandCollapseImage.image = UIImage(named: "rightArrow")?.rotate(radians: .pi / 2)
            } else {
                expandCollapseImage.image = UIImage(named: "rightArrow")
            }
        }
    }
    
    lazy var nodataLabel: UILabel = {
        let nodatalabel = UILabel()
        nodatalabel.font = UIFont(name: "Montserrat-Regular", size: 12.0)
        nodatalabel.text = "More data needed"
        nodatalabel.textColor = UIColor(hexString: "#9B9B9B")
        nodatalabel.textAlignment = .right
        nodatalabel.translatesAutoresizingMaskIntoConstraints = false
        return nodatalabel
    }()
    
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
        risk.textColor = UIColor(hexString: "#9B9B9B")
        risk.numberOfLines = 2
        risk.lineBreakMode = .byWordWrapping
        risk.translatesAutoresizingMaskIntoConstraints = false
        return risk
    }()
    
    lazy var trendImage: UIImageView = {
        let trendimage = UIImageView()
        trendimage.image = UIImage(named: "trending_up")
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
    
    lazy var detailsView: MyDataInsightDetailView = {
        let detailsview = MyDataInsightDetailView()
        detailsview.translatesAutoresizingMaskIntoConstraints = false
        return detailsview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        self.addSubview(expandCollapseImage)
        self.addSubview(tileTitle)
        self.addSubview(guageView)
        self.addSubview(riskType)
        self.addSubview(nodataLabel)
        self.addSubview(trendImage)
        self.addSubview(trendDirection)
        self.addSubview(detailsView)
        
        NSLayoutConstraint.activate([
            self.expandCollapseImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
            self.expandCollapseImage.topAnchor.constraint(equalTo: topAnchor, constant: 15.0),
            self.expandCollapseImage.widthAnchor.constraint(equalToConstant: 20.0),
            self.expandCollapseImage.heightAnchor.constraint(equalTo: self.expandCollapseImage.widthAnchor),
            
            self.tileTitle.leadingAnchor.constraint(equalTo: self.expandCollapseImage.trailingAnchor, constant: 10.0),
            self.tileTitle.topAnchor.constraint(equalTo: self.expandCollapseImage.topAnchor),
            self.tileTitle.widthAnchor.constraint(equalToConstant: 110.0),
            
            self.guageView.leadingAnchor.constraint(equalTo: self.tileTitle.trailingAnchor, constant: 10.0),
            self.guageView.topAnchor.constraint(equalTo: self.tileTitle.topAnchor),
            self.guageView.widthAnchor.constraint(equalToConstant: 48.0),
            self.guageView.heightAnchor.constraint(equalTo: self.guageView.widthAnchor),
            
            self.riskType.leadingAnchor.constraint(equalTo: self.guageView.trailingAnchor),
            self.riskType.topAnchor.constraint(equalTo: self.tileTitle.topAnchor),
            self.riskType.widthAnchor.constraint(equalToConstant: 80.0),
            
            self.trendImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 8.0),
            self.trendImage.heightAnchor.constraint(equalToConstant: 30.0),
            self.trendImage.widthAnchor.constraint(equalTo: self.trendImage.heightAnchor),
            self.trendImage.centerXAnchor.constraint(equalTo: self.trendDirection.centerXAnchor),
            self.trendDirection.topAnchor.constraint(equalTo: self.trendImage.bottomAnchor),
            self.trendDirection.leadingAnchor.constraint(greaterThanOrEqualTo: self.riskType.trailingAnchor,
                                                         constant: 10.0),
            self.trendDirection.widthAnchor.constraint(equalToConstant: 60.0),
            self.trendDirection.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10.0),
            
            self.detailsView.topAnchor.constraint(equalTo: self.topAnchor, constant: 80.0),
            self.detailsView.leadingAnchor.constraint(equalTo: self.tileTitle.leadingAnchor),
            self.detailsView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10.0),
            self.detailsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20.0),
            
            self.nodataLabel.leadingAnchor.constraint(equalTo: self.guageView.trailingAnchor, constant: 10.0),
            self.nodataLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10.0),
            self.nodataLabel.centerYAnchor.constraint(equalTo: self.guageView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.cornerRadius = 5.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor =
            (insightData?.isExpanded ?? false) ? UIColor.themeColor.cgColor : UIColor.borderColor.cgColor
        contentView.layer.masksToBounds = true
    }
}
