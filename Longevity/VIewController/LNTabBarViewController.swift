//
//  LNTabBarViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 06/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify

class LNTabBarViewController: UITabBarController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.barStyle = .black
        self.tabBar.isTranslucent = true
        self.tabBar.backgroundImage = UIImage()
        self.tabBar.backgroundColor = .clear
        
        self.navigationController?.isNavigationBarHidden = true
        
        if #available(iOS 13.0, *) {
            let appearance = self.tabBarController?.tabBar.standardAppearance
            appearance?.shadowImage = nil
            appearance?.shadowColor = nil
            self.tabBarController?.tabBar.standardAppearance = appearance!
        } else {
            self.tabBar.shadowImage = UIImage()
        }
        self.tabBar.tintColor = .themeColor
        self.tabBar.unselectedItemTintColor = .unselectedColor
        
        let homeViewController = HomeViewController()
        let myDataViewController = MyDataViewController()
        let profileViewController = ProfileViewController()
        let shareAppViewController = ShareAppViewController()
        let loggerViewController = LoggerViewController()
        
        self.viewControllers = [homeViewController, myDataViewController,
                                profileViewController, shareAppViewController, loggerViewController]
        
        let bgImageView = UIImageView(image: UIImage.imageWithColor(color: .white, size: tabBar.frame.size))
        tabBar.insertSubview(bgImageView, at: 0)
        
        getCurrentUser()
    }
        
        func getCurrentUser() {
            getProfile()
                self.navigateToTheNextScreen()
                retrieveARN()
        }
        
        func navigateToTheNextScreen(){
            let defaults = UserDefaults.standard
            let keys = UserDefaultsKeys()

            let isTermsAccepted = defaults.bool(forKey: keys.isTermsAccepted)
            let devices = (defaults.dictionary(forKey: keys.devices) ?? [:]) as [String:[String:Int]]
            let fitbitStatus = (devices[ExternalDevices.FITBIT] ?? [:]) as [String:Int]
            let healthkitStatus = (devices[ExternalDevices.HEALTHKIT] ?? [:]) as [String:Int]
            let providedPreExistingMedicalConditions = defaults.bool(forKey: keys.providedPreExistingMedicalConditions)
            
            if isTermsAccepted == true {
                let storyboard = UIStoryboard(name: "ProfileSetup", bundle: nil)
                var homeVC:UIViewController = UIViewController()

                if providedPreExistingMedicalConditions == true {
                    homeVC = storyboard.instantiateViewController(withIdentifier: "SetupCompleteVC")
                }else if fitbitStatus["connected"] == 1 {
                    homeVC = storyboard.instantiateViewController(withIdentifier: "SetupProfilePreExistingConditionVC")
                }else if healthkitStatus["connected"] == 1 {
                    homeVC = storyboard.instantiateViewController(withIdentifier: "SetupProfileNotificationVC")
                } else {
                    homeVC = storyboard.instantiateViewController(withIdentifier: "SetupProfileDisclaimerVC")
                }
                
                let navigationController = UINavigationController(rootViewController: homeVC)
                navigationController.modalPresentationStyle = .fullScreen

                self.present(navigationController, animated: true, completion: nil)

            } else {
                performSegue(withIdentifier: "OnboardingToProfileSetup", sender: self)
            }
        }

}
