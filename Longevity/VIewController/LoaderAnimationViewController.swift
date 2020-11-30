//
//  LoaderAnimationViewController.swift
//  Longevity
//
//  Created by vivek on 03/09/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify
import AWSPluginsCore
import SwiftyJSON

class LoaderAnimationViewController: UIViewController {
    
    lazy var backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "splashScreen")
        return imageView
    }()
    
    lazy var rejuveLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "rejuveNamedLogo")
        return imageView
    }()
    
    lazy var poweredByLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "POWERED BY"
        label.font = UIFont(name: "Muli-Regular", size: 14)
        label.textColor = .white
        return label
    }()
    
    lazy var singularityLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "snetNamedLogo")
        return imageView
    }()
    
    lazy var singularityStudioLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "studioNamedLogo")
        return imageView
    }()
    
    
    lazy var spinner:UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        return spinner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(backgroundImage)
        self.view.addSubview(rejuveLogo)
        self.view.addSubview(poweredByLabel)
        self.view.addSubview(singularityLogo)
        self.view.addSubview(singularityStudioLogo)
        self.view.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            rejuveLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rejuveLogo.bottomAnchor.constraint(equalTo: view.centerYAnchor,  constant: -20),
            
            poweredByLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            poweredByLabel.topAnchor.constraint(equalTo: rejuveLogo.bottomAnchor, constant: 65),
            
            singularityLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            singularityLogo.topAnchor.constraint(equalTo: poweredByLabel.bottomAnchor, constant: 20),
            
            singularityStudioLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            singularityStudioLogo.topAnchor.constraint(equalTo: singularityLogo.bottomAnchor, constant: 20),
            //
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.topAnchor.constraint(equalTo:singularityStudioLogo.bottomAnchor, constant: 20)
        ])

        checkIfAppUpdated { [weak self] signedOut in
            if !signedOut {
                self?.fetchCurrentSession()
            }
        }
    }

    func fetchCurrentSession() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}

        _ = Amplify.Auth.fetchAuthSession { (result) in
            switch result {
            case .success(let session):
                if session.isSignedIn {
                    guard let session = try? result.get() as? AuthCognitoTokensProvider,
                          let tokens = try? session.getCognitoTokens().get() else {
                        return
                    }

                    try? KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.idToken).saveItem(tokens.idToken)
                                        
                    DispatchQueue.main.async {
                        let tabbarViewController = LNTabBarViewController()
                        tabbarViewController.modalPresentationStyle = .fullScreen
                        appDelegate.window?.rootViewController = tabbarViewController
                    }
                } else {
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "UserLogin", bundle: nil)
                        let onBoardingViewController = storyboard.instantiateInitialViewController()
                        appDelegate.window?.rootViewController = onBoardingViewController
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "UserLogin", bundle: nil)
                    let onBoardingViewController = storyboard.instantiateInitialViewController()
                    appDelegate.window?.rootViewController = onBoardingViewController
                }
            }
        }
    }

    func checkIfAppUpdated(completion: @escaping(_ signedOut: Bool) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}

        let previousBuild = UserDefaults.standard.string(forKey: "build")
        let currentBuild = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        UserDefaults.standard.set(currentBuild, forKey: "build")
        if previousBuild == nil {
            // MARK: Fresh install
            _ = Amplify.Auth.signOut() { [weak self] (result) in
                switch result {
                case .success:
                    try? KeyChain(service: KeychainConfiguration.serviceName,
                                  account: KeychainKeys.idToken).deleteItem()
                    print("Successfully signed out")
                    completion(true)
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "UserLogin", bundle: nil)
                        let onBoardingViewController = storyboard.instantiateInitialViewController()
                        appDelegate.window?.rootViewController = onBoardingViewController
                    }
                case .failure(let error):
                    print("Sign out failed with error \(error)")
                    completion(false)
                }
            }
        } else {
            completion(false)
        }
    }
}
