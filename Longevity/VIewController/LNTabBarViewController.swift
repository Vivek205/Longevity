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
    
    var currentTabIndex: Int = 0
    
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
        
        self.delegate = self
        
        let homeViewController = HomeViewController()
        let myDataViewController = MyDataViewController()
        let profileViewController = ProfileViewController()
        let shareAppViewController = ShareAppViewController()
        let loggerViewController = LoggerViewController()
        
        self.viewControllers = [homeViewController, myDataViewController,
                                profileViewController, shareAppViewController, loggerViewController]
        
        let bgImageView = UIImageView(image: UIImage.imageWithColor(color: .white, size: tabBar.frame.size))
        tabBar.insertSubview(bgImageView, at: 0)
        
        //getCurrentUser()
        AppSyncManager.instance.syncUserProfile()
        
        AppSyncManager.instance.isTermsAccepted.addAndNotify(observer: self) { [weak self] in
            DispatchQueue.main.async {
                if !(AppSyncManager.instance.isTermsAccepted.value ?? false) {
                    let storyboard = UIStoryboard(name: "ProfileSetup", bundle: nil)
                    guard let tosViewController = storyboard.instantiateViewController(withIdentifier: "TermsOfServiceVC") as? TermsOfServiceVC else { return }
                    tosViewController.isFromSettings = true
                    let navigationController = UINavigationController(rootViewController: tosViewController)
                    NavigationUtility.presentOverCurrentContext(destination: navigationController )
                }
            }
        }
        retrieveARN()
    }
        
        func getCurrentUser() {
            AppSyncManager.instance.syncUserProfile()
            //getProfile()
//            self.navigateToTheNextScreen()
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

extension LNTabBarViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController is ShareAppViewController {
            tabBarController.selectedViewController = self.viewControllers?[self.currentTabIndex]
            self.showShareApp()
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag != RejuveTab.shareApp.rawValue {
            self.currentTabIndex = item.tag
        }
    }
    
    func showShareApp() {
        var sharemessage = [Any]()
        sharemessage.append("Hey, I found this interesting app for COVID19 self-checks")
        if let applink = AppSyncManager.instance.appShareLink.value, !applink.isEmpty {
            sharemessage.append(applink)
        }
        let activityVC = UIActivityViewController(activityItems: sharemessage, applicationActivities: nil)
        activityVC.title = "Share Rejuve"
//        activityVC.excludedActivityTypes = [.print, .airDrop, .assignToContact, .copyToPasteboard, .postToVimeo, .addToReadingList, .message, .postToWeibo]
        activityVC.popoverPresentationController?.sourceView = self.selectedViewController?.view
        self.selectedViewController?.present(activityVC, animated: true, completion: nil)
    }
}
