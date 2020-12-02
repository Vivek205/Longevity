//
//  SignOutCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 20/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify

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
        signoutButton.addTarget(self, action: #selector(doSignout), for: .touchUpInside)
        signoutButton.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(signoutButton)
        
        NSLayoutConstraint.activate([
            signoutButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 80.0),
            signoutButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -80.0),
            signoutButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            signoutButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func doSignout() {
        func onSuccess(isSignedOut: Bool) {
            try? KeyChain(service: KeychainConfiguration.serviceName,
                          account: KeychainKeys.idToken, accessGroup: nil).deleteItem()
            DispatchQueue.main.async {
                
                if var topController = UIApplication.shared.keyWindow?.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    
                    topController.removeSpinner()
                }
                
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                appDelegate.setRootViewController()
            }
        }
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.showSpinner()
        }
        
        UserAuthAPI.shared.signout { (error) in
            guard error == nil else {
                print("Sign out failed with error \(error)")
                Logger.log("\(error)")
                DispatchQueue.main.async {
                    Alert(title: "Signout Failed!", message: "Unable to signout. Please try again later")
                    if var topController = UIApplication.shared.keyWindow?.rootViewController {

                        topController.removeSpinner()
                    }
                }
                return
            }
            onSuccess(isSignedOut: true)
        }
    }
}
