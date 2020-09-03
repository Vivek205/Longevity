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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showSpinner()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        _ = Amplify.Auth.fetchAuthSession { (result) in
            switch result {
            case .success(let session):
                if session.isSignedIn {
                    DispatchQueue.main.async {
                        self.removeSpinner()
                        let tabbarViewController = LNTabBarViewController()
                        tabbarViewController.modalPresentationStyle = .fullScreen
                        appDelegate.window?.rootViewController = tabbarViewController
                    }
                }else {
                    DispatchQueue.main.async {
                        self.removeSpinner()
                        let storyboard = UIStoryboard(name: "UserLogin", bundle: nil)
                        let onBoardingViewController = storyboard.instantiateInitialViewController()
                        appDelegate.window?.rootViewController = onBoardingViewController
                    }
                }
                
                
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.removeSpinner()
                    let storyboard = UIStoryboard(name: "UserLogin", bundle: nil)
                    let onBoardingViewController = storyboard.instantiateInitialViewController()
                    appDelegate.window?.rootViewController = onBoardingViewController
                }
                
            }
        }
    }
}
