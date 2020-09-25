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
            signoutButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func doSignout() {
        func onSuccess(isSignedOut: Bool) {
            clearUserDefaults()
            KeyChain.remove(name: KeychainKeys.idToken)
            KeyChain.remove(name: KeychainKeys.idTokenExp)
            DispatchQueue.main.async {
                
                if var topController = UIApplication.shared.keyWindow?.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    
                    topController.removeSpinner()
                }
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.setRootViewController()
            }
        }
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.showSpinner()
        }
        
        _ = Amplify.Auth.signOut() { (result) in
            switch result {
            case .success:
                print("Successfully signed out")
                onSuccess(isSignedOut: true)
            case .failure(let error):
                print("Sign out failed with error \(error)")
            }
        }
    }
}
