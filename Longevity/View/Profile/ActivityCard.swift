//
//  ActivityCard.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 18/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class ActivityCard : UIView {
    var activity:UserActivityDetails? {
        didSet {
            activityTitle.text = activity?.title
            activitySubTitle.text = activity?.description
            let dateString = UTCStringToLocalDateString(dateString: activity?.loggedAt ?? "",
                                                        dateFormat: "yyyy-MM-dd HH:mm:ss",
                                                        outputDateFormat: "E. MMM. d")
            activityDate.text = dateString

            if activity?.activityType == nil {
                activityDate.isHidden = true
                spinner.startAnimating()
            }else {
                activityDate.isHidden = false
                spinner.stopAnimating()
            }
        }
    }

    lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            spinner.style = .medium
        } else {
            spinner.style = .gray
        }
        spinner.color = .gray

        return spinner
    }()
    
    lazy var activityTitle: UILabel = {
        let activitytitle = UILabel()
        activitytitle.font = UIFont(name: "Montserrat-Medium", size: 14.0)
        activitytitle.textColor = UIColor.black.withAlphaComponent(0.87)
        activitytitle.translatesAutoresizingMaskIntoConstraints = false
        activitytitle.numberOfLines = 0
        return activitytitle
    }()
    
    lazy var activityDate: UILabel = {
        let activitydate = UILabel()
        activitydate.font = UIFont(name: "Montserrat-Medium", size: 12.0)
        activitydate.textColor = UIColor(hexString: "#4A4A4A")
        activitydate.translatesAutoresizingMaskIntoConstraints = false
        return activitydate
    }()
    
    lazy var activitySubTitle: UILabel = {
        let activitysubtitle = UILabel()
        activitysubtitle.font = UIFont(name: "Montserrat-Regular", size: 12.0)
        activitysubtitle.textColor = UIColor(hexString: "#4A4A4A")
        activitysubtitle.translatesAutoresizingMaskIntoConstraints = false
        activitysubtitle.numberOfLines = 0
        return activitysubtitle
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(activityTitle)
        addSubview(activityDate)
        addSubview(activitySubTitle)
        
        NSLayoutConstraint.activate([
            activityTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 7.0),
            activityTitle.topAnchor.constraint(equalTo: topAnchor, constant: 7.0),
            activitySubTitle.topAnchor.constraint(equalTo: activityTitle.topAnchor, constant: 10.0),
            activitySubTitle.leadingAnchor.constraint(equalTo: activityTitle.leadingAnchor),
            activitySubTitle.trailingAnchor.constraint(equalTo: activityTitle.trailingAnchor, constant: -10.0),
            activitySubTitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7.0),
            activityDate.centerYAnchor.constraint(equalTo: activityTitle.centerYAnchor),
            activityDate.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.0),
            activityDate.leadingAnchor.constraint(greaterThanOrEqualTo: activityTitle.trailingAnchor, constant: 10.0)
        ])

        addSubview(spinner)
        bringSubviewToFront(spinner)
        spinner.hidesWhenStopped = true
        spinner.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.cornerRadius = 5.0
        layer.shadowRadius = 1.0
        layer.shadowOpacity = 0.25
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
}
