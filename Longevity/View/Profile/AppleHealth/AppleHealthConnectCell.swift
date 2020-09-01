//
//  AppleHealthConnectCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 01/09/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class AppleHealthConnectCell: UITableViewCell {
    lazy var connectButton: UIButton = {
        let connect = UIButton()
        connect.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 24.0)
        connect.setTitle("Connect", for: .normal)
        connect.setTitleColor(.white, for: .normal)
        connect.backgroundColor = .themeColor
        connect.translatesAutoresizingMaskIntoConstraints = false
        return connect
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        
        self.addSubview(connectButton)
        
       NSLayoutConstraint.activate([
            connectButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15.0),
            connectButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15.0),
            connectButton.topAnchor.constraint(equalTo: topAnchor, constant: 2.0),
            connectButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2.0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setConnection(isConnected: Bool) {
        connectButton.layer.cornerRadius = 10.0
        connectButton.layer.masksToBounds = true
        if isConnected {
            connectButton.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 24.0)
            connectButton.setTitle("Disconnect", for: .normal)
            connectButton.setTitleColor(UIColor(hexString: "#E67381"), for: .normal)
            connectButton.backgroundColor = .clear
            connectButton.layer.borderWidth = 2.0
            connectButton.layer.borderColor = UIColor(hexString: "#E67381").cgColor
            connectButton.layer.shadowColor = UIColor.clear.cgColor
        } else {
            connectButton.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 24.0)
            connectButton.setTitle("Connect", for: .normal)
            connectButton.setTitleColor(.white, for: .normal)
            connectButton.backgroundColor = .themeColor
            
            connectButton.layer.borderWidth = 0.0
            connectButton.layer.borderColor = UIColor.clear.cgColor
            connectButton.layer.shadowColor = UIColor.black.cgColor
            connectButton.layer.shadowOffset = CGSize(width: 0, height: 1.0)
            connectButton.layer.cornerRadius = 10.0
            connectButton.layer.shadowRadius = 0
            connectButton.layer.shadowOpacity = 0.25
            connectButton.layer.masksToBounds = false
            connectButton.layer.shadowPath = UIBezierPath(roundedRect: connectButton.bounds, cornerRadius: connectButton.layer.cornerRadius).cgPath
        }
    }
}

