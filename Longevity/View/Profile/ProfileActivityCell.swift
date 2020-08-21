//
//  ProfileActivityCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 18/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

fileprivate var defaultActivityImageName = "checkindone"

class ProfileActivityCell: UITableViewCell {
    var activity: UserActivity? {
        didSet {
            activityCard.activity = activity
            if let activityType = activity?.activityType {
//                activityImage.image = UIImage(named: activityImageName[activityType] ?? defaultActivityImageName)
                activityImage.image = activityType.activityIcon ?? UIImage(named: defaultActivityImageName)
            }
        }
    }
  
    lazy var activityImage: UIImageView = {
        let activityimage = UIImageView()
        activityimage.image = UIImage(named: defaultActivityImageName)
        activityimage.contentMode = .scaleAspectFill
        activityimage.translatesAutoresizingMaskIntoConstraints = false
        return activityimage
    }()
    
    lazy var activityVerticalLine: UIView = {
        let verticalLine = UIView()
        verticalLine.backgroundColor = UIColor(hexString: "#D6D6D6")
        verticalLine.translatesAutoresizingMaskIntoConstraints = false
        return verticalLine
    }()
    
    lazy var activityCard: ActivityCard = {
        let activitycard = ActivityCard()
        activitycard.translatesAutoresizingMaskIntoConstraints = false
        return activitycard
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        
        self.addSubview(activityVerticalLine)
        self.addSubview(activityImage)
        self.addSubview(activityCard)
        
        NSLayoutConstraint.activate([
            activityImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.0),
            activityImage.topAnchor.constraint(equalTo: topAnchor),
            activityImage.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.75),
            activityImage.widthAnchor.constraint(equalTo: activityImage.heightAnchor),
            activityVerticalLine.widthAnchor.constraint(equalToConstant: 2.0),
            activityVerticalLine.centerXAnchor.constraint(equalTo: activityImage.centerXAnchor, constant: -2.0),
            activityVerticalLine.topAnchor.constraint(equalTo: activityImage.topAnchor, constant: 5.0),
            activityVerticalLine.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 1.0),
            activityCard.leadingAnchor.constraint(equalTo: activityImage.trailingAnchor, constant: 15.0),
            activityCard.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
            activityCard.topAnchor.constraint(equalTo: topAnchor),
            activityCard.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20.0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let shapePath = activityImage.roundedPolygonPath(rect: activityImage.bounds, lineWidth: 1.0, sides: 6, cornerRadius: 5.0)
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.path = shapePath.cgPath
        activityImage.layer.mask = maskLayer
    }
}
