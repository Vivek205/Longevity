//
//  SignOutCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 20/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class SignOutCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        
        let signoutButton = UIButton()
        signoutButton.setTitle("Sign Out", for: .normal)
        signoutButton.setTitleColor(.themeColor, for: .normal)
        signoutButton.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 18.0)
        signoutButton.layer.borderWidth = 2
        signoutButton.layer.borderColor = UIColor.themeColor.cgColor
        signoutButton.layer.cornerRadius = 10.0
        
        self.addSubview(signoutButton)
        
        NSLayoutConstraint.activate([
            signoutButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 80.0),
            signoutButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -80.0),
            signoutButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
