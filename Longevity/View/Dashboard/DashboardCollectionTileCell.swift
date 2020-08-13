//
//  DashboardCollectionTileView.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 08/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class DashboardCollectionTileCell: UICollectionViewCell {
    
    var insightData: UserInsight! {
        didSet {
            self.tileTitle.text = insightData.details.name
            self.riskType.text = insightData.details.riskLevel.text
            self.trendDirection.text = insightData.details.trend.text
            self.trendDirection.textColor = insightData.details.trend.tintColor
            self.trendImage.image = insightData.details.trend.trendIcon
            self.trendImage.isHidden = insightData.details.trend == .same
        }
    }
    
    lazy var hexagonView : HexagonView = {
        let hexagon = HexagonView()
        hexagon.backgroundColor = .hexagonColor
        hexagon.translatesAutoresizingMaskIntoConstraints = false
        return hexagon
    }()
    
    lazy var tileTitle: UILabel = {
        let title = UILabel()
        title.textAlignment = .center
        title.text = "COVID-19 Infection"
        title.font = UIFont(name: "Montserrat-Medium", size: 14)
        title.textColor = .checkinCompleted
        title.numberOfLines = 0
        title.lineBreakMode = .byWordWrapping
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    lazy var guageView: InsightGuageView = {
        let guage = InsightGuageView()
        guage.translatesAutoresizingMaskIntoConstraints = false
        return guage
    }()
    
    lazy var riskType: UILabel = {
        let risk = UILabel()
        risk.textAlignment = .center
        risk.text = "Medium Risk"
        risk.font = UIFont(name: "Montserrat-SemiBold", size: 18)
        risk.textColor = .themeColor
        risk.numberOfLines = 0
        risk.lineBreakMode = .byWordWrapping
        risk.translatesAutoresizingMaskIntoConstraints = false
        return risk
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
    
    lazy var trendImage: UIImageView = {
        let trendimage = UIImageView()
        trendimage.image = UIImage(named: "trending_up")
        trendimage.tintColor = .red
        trendimage.contentMode = .scaleAspectFit
        trendimage.translatesAutoresizingMaskIntoConstraints = false
        return trendimage
    }()
    
    lazy var emptyCellMessage: UILabel = {
        let emptyMessage = UILabel()
        emptyMessage.font = UIFont(name: "Montserrat-Medium", size: 14.0)
        emptyMessage.numberOfLines = 0
        emptyMessage.lineBreakMode = .byWordWrapping
        emptyMessage.textColor = .white
        emptyMessage.text = "Coming Soon"
        emptyMessage.textAlignment = .center
        emptyMessage.translatesAutoresizingMaskIntoConstraints = false
        return emptyMessage
    }()
    
    lazy var infoButton: UIButton = {
        let info = UIButton()
        info.setImage(UIImage(named: "icon-info"), for: .normal)
        info.tintColor = .white
        info.translatesAutoresizingMaskIntoConstraints = false
        return info
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(hexagonView)
        NSLayoutConstraint.activate([
            hexagonView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hexagonView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hexagonView.heightAnchor.constraint(equalTo: widthAnchor)
        ])
    }
    
    func setupCell(index: Int, isEmpty : Bool) {
        let isEvenCell = index % 2 == 0
        let vTop = isEvenCell ? 0.0 : self.bounds.height * 0.40
        
        self.hexagonView.addSubview(tileTitle)
        
        NSLayoutConstraint.activate([
            hexagonView.topAnchor.constraint(equalTo: topAnchor, constant: vTop),
            tileTitle.widthAnchor.constraint(equalTo: hexagonView.widthAnchor, multiplier: 0.60),
            tileTitle.centerXAnchor.constraint(equalTo: hexagonView.centerXAnchor),
            tileTitle.topAnchor.constraint(equalTo: hexagonView.topAnchor, constant: 25.0),
        ])
        
        if isEmpty {
            self.hexagonView.backgroundColor = .clear
            self.hexagonView.borderColor = .white
            self.hexagonView.isEmptyCell = true
            
            self.tileTitle.text = "Longevity"
            self.tileTitle.textColor = .white
            self.infoButton.tintColor = .white
            
            self.hexagonView.addSubview(emptyCellMessage)
            self.hexagonView.addSubview(infoButton)
            
            NSLayoutConstraint.activate([
                emptyCellMessage.widthAnchor.constraint(equalTo: hexagonView.widthAnchor, multiplier: 0.60),
                emptyCellMessage.centerXAnchor.constraint(equalTo: hexagonView.centerXAnchor),
                emptyCellMessage.centerYAnchor.constraint(equalTo: hexagonView.centerYAnchor),
                infoButton.topAnchor.constraint(equalTo: emptyCellMessage.bottomAnchor, constant: 20.0),
                infoButton.centerXAnchor.constraint(equalTo: emptyCellMessage.centerXAnchor),
                infoButton.widthAnchor.constraint(equalToConstant: 30.0),
                infoButton.heightAnchor.constraint(equalTo: infoButton.widthAnchor)
            ])
        } else {
            self.hexagonView.backgroundColor = .hexagonColor
            self.hexagonView.borderColor = .borderColor
            self.hexagonView.isEmptyCell = false

            self.hexagonView.addSubview(guageView)
            self.hexagonView.addSubview(riskType)
            self.hexagonView.addSubview(trendDirection)
            self.hexagonView.addSubview(trendImage)
            
            NSLayoutConstraint.activate([
                guageView.topAnchor.constraint(equalTo: tileTitle.bottomAnchor, constant: 5.0),
                guageView.heightAnchor.constraint(equalToConstant: 50.0),
                guageView.widthAnchor.constraint(equalTo: guageView.heightAnchor),
                guageView.leadingAnchor.constraint(equalTo: hexagonView.leadingAnchor, constant: 5.0),
                riskType.topAnchor.constraint(equalTo: guageView.topAnchor),
                riskType.leadingAnchor.constraint(equalTo: guageView.trailingAnchor),
                riskType.trailingAnchor.constraint(equalTo: hexagonView.trailingAnchor, constant: -20.0),
                riskType.bottomAnchor.constraint(equalTo: guageView.bottomAnchor),
                trendDirection.topAnchor.constraint(equalTo: riskType.bottomAnchor),
                trendDirection.leadingAnchor.constraint(equalTo: hexagonView.leadingAnchor, constant: 5.0),
                trendDirection.trailingAnchor.constraint(equalTo: hexagonView.trailingAnchor, constant: -5.0),
                trendImage.heightAnchor.constraint(equalToConstant: 30.0),
                trendImage.widthAnchor.constraint(equalTo: trendImage.heightAnchor),
                trendImage.centerXAnchor.constraint(equalTo: hexagonView.centerXAnchor),
                trendImage.bottomAnchor.constraint(equalTo: hexagonView.bottomAnchor, constant: -10.0)
            ])
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
