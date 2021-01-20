//
//  DashboardSectionHeader.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 08/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

enum HeaderType: Int {
    case devices = 1
    case tasks
}

extension HeaderType {
    var title : String {
        switch self {
            case .devices:
                return "DEVICE CONNECTIONS"
            case .tasks:
                return "MY TASKS"
        }
    }
}

class DashboardSectionHeader: UICollectionReusableView {
    
    var headerType: HeaderType! {
        didSet {
            self.sectionTitle.text = headerType.title
        }
    }

    lazy var sectionTitle: UILabel = {
        let title = UILabel()
        title.textColor = .sectionHeaderColor
        title.font = UIFont(name: "Montserrat-Medium", size: 14.0)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    lazy var actionButton: UIButton = {
        let action = UIButton()
        action.setImage(UIImage(named: "icon-info"), for: .normal)
        action.tintColor = UIColor(hexString: "#C2C2C2")
        action.addTarget(self, action: #selector(doAction), for: .touchUpInside)
        action.translatesAutoresizingMaskIntoConstraints = false
        return action
    }()
       
    override init(frame: CGRect) {
        super.init(frame: frame)
    
         self.addSubview(sectionTitle)
         self.addSubview(actionButton)
        
         NSLayoutConstraint.activate([
             sectionTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.0),
             sectionTitle.topAnchor.constraint(equalTo: topAnchor, constant: 5.0),
             sectionTitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5.0),
             actionButton.centerYAnchor.constraint(equalTo: sectionTitle.centerYAnchor),
             actionButton.heightAnchor.constraint(equalToConstant: 30.0),
             actionButton.widthAnchor.constraint(equalTo: actionButton.heightAnchor),
             actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.0),
             actionButton.leadingAnchor.constraint(greaterThanOrEqualTo: sectionTitle.trailingAnchor, constant: 20.0)
         ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func doAction() {
        switch self.headerType {
        case .devices:
            NavigationUtility.presentOverCurrentContext(destination: DeviceConnectionsPopupViewController(), style: .overCurrentContext, transitionStyle: .crossDissolve, completion: nil)
        case .tasks:
            NavigationUtility.presentOverCurrentContext(destination: MyTasksInfoPopupViewController(), style: .overCurrentContext, transitionStyle: .crossDissolve, completion: nil)
        default:
            return
        }

    }
}
