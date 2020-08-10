//
//  DashboardCheckInCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 09/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

enum CheckInStatus: Int {
    case notstarted
    case nottoday
    case completedtoday
}

extension CheckInStatus {
    var status: String {
        switch self {
            case .notstarted:
                return "Get started today"
            case .nottoday:
                return "Last tracked 3 days ago"
            case .completedtoday:
                return "4 days logged"
        }
    }
    
    var statusIcon: UIImage? {
        switch self {
            case .notstarted:
                return UIImage(named: "checkinnotdone")
            case .nottoday:
                return UIImage(named: "checkinnotdone")
            case .completedtoday:
                return UIImage(named: "checkindone")
        }
    }
    
    var titleColor: UIColor {
        switch self {
            case .notstarted:
                return .checkinNotCompleted
            case .nottoday:
                return .checkinNotCompleted
            case .completedtoday:
                return .checkinCompleted
        }
    }
}

class DashboardCheckInCell: UITableViewCell {
    
    lazy var checkInIcon: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    
    lazy var checkInTitle: UILabel = {
        let title = UILabel()
        title.font = UIFont(name: "Montserrat-Medium", size: 20.0)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    lazy var checkInTitle2: UILabel = {
        let title2 = UILabel()
        title2.font = UIFont(name: "Montserrat-SemiBold", size: 16.0)
        title2.translatesAutoresizingMaskIntoConstraints = false
        return title2
    }()
    
    lazy var lastUpdated: UILabel = {
        let lastupdated = UILabel()
        lastupdated.font = UIFont(name: "Montserrat-Regular", size: 14.0)
        lastupdated.translatesAutoresizingMaskIntoConstraints = false
        return lastupdated
    }()
    
    lazy var verticleStack : UIStackView = {
        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.distribution = .equalSpacing
        vStack.alignment = .fill
        vStack.addArrangedSubview(checkInTitle)
        vStack.addArrangedSubview(checkInTitle2)
        vStack.addArrangedSubview(lastUpdated)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        return vStack
    }()
    
    lazy var bgView: UIView = {
        let bgview = UIView()
        bgview.backgroundColor = .white
        bgview.translatesAutoresizingMaskIntoConstraints = false
        return bgview
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        
        self.addSubview(bgView)
        bgView.addSubview(checkInIcon)
        bgView.addSubview(verticleStack)
        
        NSLayoutConstraint.activate([
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
            bgView.topAnchor.constraint(equalTo: topAnchor, constant: 10.0),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0),
            checkInIcon.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 10.0),
            checkInIcon.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -10.0),
            checkInIcon.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 10.0),
            checkInIcon.widthAnchor.constraint(equalTo: checkInIcon.heightAnchor),
            verticleStack.leadingAnchor.constraint(equalTo: checkInIcon.trailingAnchor, constant: 10.0),
            verticleStack.topAnchor.constraint(equalTo: checkInIcon.topAnchor),
            verticleStack.bottomAnchor.constraint(equalTo: checkInIcon.bottomAnchor),
            verticleStack.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -10.0)
        ])
        
        self.setupCell(title: "COVID Check-in", status: .notstarted)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(title: String, status: CheckInStatus) {
        self.checkInIcon.image = status.statusIcon
        self.checkInTitle.text = title
        self.checkInTitle.textColor = status.titleColor
        self.checkInTitle2.text = "How are you feeling today?"
        self.checkInTitle2.textColor = .checkinCompleted
        self.lastUpdated.text = status.status
        self.lastUpdated.textColor = .statusColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bgView.layer.masksToBounds = true
        
        bgView.layer.shadowColor = UIColor.black.cgColor
        bgView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        bgView.layer.cornerRadius = 5.0
        bgView.layer.shadowRadius = 2.0
        bgView.layer.shadowOpacity = 0.25
        bgView.layer.masksToBounds = false
        bgView.layer.shadowPath = UIBezierPath(roundedRect: bgView.bounds, cornerRadius: bgView.layer.cornerRadius).cgPath
    }
}
