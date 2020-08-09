//
//  DashboardCheckInCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 09/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

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
        title2.font = UIFont(name: "Montserrat-SemiMedium", size: 16.0)
        title2.translatesAutoresizingMaskIntoConstraints = false
        return title2
    }()
    
    lazy var lastUpdated: UILabel = {
        let lastupdated = UILabel()
        lastupdated.font = UIFont(name: "Montserrat-SemiMedium", size: 16.0)
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
