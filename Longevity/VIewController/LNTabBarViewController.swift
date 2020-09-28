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
        
        AppSyncManager.instance.syncUserProfile()
        retrieveARN()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppSyncManager.instance.isTermsAccepted.addAndNotify(observer: self) {
            DispatchQueue.main.async {
                if !(AppSyncManager.instance.isTermsAccepted.value ?? false) {
                    let storyboard = UIStoryboard(name: "ProfileSetup", bundle: nil)
                    guard let tosViewController = storyboard.instantiateViewController(withIdentifier: "TermsOfServiceVC") as? TermsOfServiceVC else { return }
                    let navigationController = UINavigationController(rootViewController: tosViewController)
                    NavigationUtility.presentOverCurrentContext(destination: navigationController, style: .overCurrentContext)
                }
            }
        }
    }
    
    func navigateToTheNextScreen(){
        let isTermsAccepted = AppSyncManager.instance.isTermsAccepted.value
        let devices = AppSyncManager.instance.healthProfile.value?.devices
        var healthKitConnected = false
        var fitbitConnected = false
        if let profile = AppSyncManager.instance.healthProfile.value {
            if let healthKitDevice = profile.devices?[ExternalDevices.healthkit], healthKitDevice["connected"] == 1 {
                healthKitConnected = true
            }
            if let fitbitDevice = profile.devices?[ExternalDevices.fitbit], fitbitDevice["connected"] == 1 {
                fitbitConnected = true
            }
        }
        
        let providedPreExistingMedicalConditions = !(AppSyncManager.instance.healthProfile.value?.preconditions?.isEmpty ?? true)
        
        if isTermsAccepted == true {
            let storyboard = UIStoryboard(name: "ProfileSetup", bundle: nil)
            var homeVC:UIViewController = UIViewController()
            
            if providedPreExistingMedicalConditions == true {
                homeVC = storyboard.instantiateViewController(withIdentifier: "SetupCompleteVC")
            }else if fitbitConnected {
                homeVC = storyboard.instantiateViewController(withIdentifier: "SetupProfilePreExistingConditionVC")
            }else if healthKitConnected {
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
