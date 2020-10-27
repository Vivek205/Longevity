//
//  LoaderAnimationViewController.swift
//  Longevity
//
//  Created by vivek on 03/09/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify

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
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        _ = Amplify.Auth.fetchAuthSession { (result) in
            switch result {
            case .success(let session):
                if session.isSignedIn {
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

//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        ConnectionManager.instance.addConnectionObserver()
//    }
}
