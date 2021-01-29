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
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var rejuveLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "rejuveNamedLogo")
        imageView.contentMode = .scaleAspectFit
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
        self.view.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            rejuveLogo.widthAnchor.constraint(equalToConstant: 277.0),
            rejuveLogo.heightAnchor.constraint(equalToConstant: 379.0),
            rejuveLogo.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            rejuveLogo.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),

            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.topAnchor.constraint(equalTo:rejuveLogo.bottomAnchor, constant: 20)
        ])

        self.checkAppUpdates()
        
//        AppSyncManager.instance.internetConnectionAvailable.addAndNotify(observer: self) { [weak self] in
//            if AppSyncManager.instance.internetConnectionAvailable.value == .connected &&
//                AppSyncManager.instance.prevInternetConnnection != .connected {
//                self?.checkAppUpdates()
//            }
//        }
    }
    
    func checkAppUpdates() {
        checkIfAppUpdated { signedOut in
            if !signedOut {
                DispatchQueue.main.async {
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                    appDelegate.setRootViewController()
                }
            } else {
                DispatchQueue.main.async {
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                    let storyboard = UIStoryboard(name: "UserLogin", bundle: nil)
                    let onBoardingViewController = storyboard.instantiateInitialViewController()
                    appDelegate.window?.rootViewController = onBoardingViewController
                }
            }
        }
    }

    func checkIfAppUpdated(completion: @escaping(_ signedOut: Bool) -> Void) {
        let previousBuild = UserDefaults.standard.string(forKey: "build")
        let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        UserDefaults.standard.set(currentBuild, forKey: "build")
        if previousBuild == nil {
            // MARK: Fresh install
            _ = Amplify.Auth.signOut { (result) in
                switch result {
                case .success:
                    try? KeyChain(service: KeychainConfiguration.serviceName,
                                  account: KeychainKeys.idToken).deleteItem()
                    completion(true)
                case .failure(let error):
                    print("Sign out failed with error \(error)")
                    completion(false)
                }
            }
        } else {
            completion(false)
        }
    }
    
//    deinit {
//        AppSyncManager.instance.internetConnectionAvailable.remove(observer: self)
//    }
}
