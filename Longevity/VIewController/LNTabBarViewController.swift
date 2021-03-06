//
//  LNTabBarViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 06/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify
import HealthKit

class LNTabBarViewController: UITabBarController {
    var presentingTosVC: Bool = false
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
        
        #if DEBUG
        self.viewControllers = [homeViewController, myDataViewController,
                                profileViewController, shareAppViewController, loggerViewController]
        #else
        self.viewControllers = [homeViewController, myDataViewController,
                                profileViewController, shareAppViewController]
        #endif
        let bgImageView = UIImageView(image: UIImage.imageWithColor(color: .white, size: tabBar.frame.size))
        tabBar.insertSubview(bgImageView, at: 0)
        
        AppSyncManager.instance.healthProfile.addAndNotify(observer: self, completionHandler: {
            if HKHealthStore.isHealthDataAvailable() {
                if !(AppSyncManager.instance.healthProfile.value?.devices?.isEmpty ?? true) {
                    HealthStore.shared.getHealthStore()
                    if AppSyncManager.instance.healthProfile.value?.devices?[ExternalDevices.healthkit]?["connected"] == 1 {
                        HealthStore.shared.startObserving(device: .applehealth)
                    }
                    if AppSyncManager.instance.healthProfile.value?.devices?[ExternalDevices.watch]?["connected"] == 1 {
                        HealthStore.shared.startObserving(device: .applewatch)
                    }
                }
            }
        })
        
//        AppSyncManager.instance.syncUserProfile()
//        AppSyncManager.instance.getAppLink()
        self.handleNetworkConnectionChange()
        self.updateTabTextAttributes()
        
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(self.appcometoforeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    func handleNetworkConnectionChange() {
        AppSyncManager.instance.internetConnectionAvailable.addAndNotify(observer: self) { [unowned self] in
            if AppSyncManager.instance.internetConnectionAvailable.value == .notconnected {
                DispatchQueue.main.async {
                    self.tabBarController?.selectedIndex = 0
                    if let items = self.tabBarController?.tabBar.items {
                        items.forEach{$0.isEnabled = false}
                    }
                }
            } else if AppSyncManager.instance.internetConnectionAvailable.value == .connected &&
                        AppSyncManager.instance.prevInternetConnnection != .connected {
                AppSyncManager.instance.syncUserProfile()
                AppSyncManager.instance.getAppLink()
                DispatchQueue.main.async {
                    if let items = self.tabBarController?.tabBar.items {
                        items.forEach{$0.isEnabled = true}
                    }
                }
            }
            AppSyncManager.instance.prevInternetConnnection = AppSyncManager.instance.internetConnectionAvailable.value
        }
    }
    
    override var selectedViewController: UIViewController? {
        didSet {
            self.updateTabTextAttributes()
        }
    }
    
    fileprivate func updateTabTextAttributes() {
        guard let viewControllers = viewControllers else {
            return
        }
        
        for viewController in viewControllers {
            if viewController == selectedViewController {
                let textAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor(hexString: "#4A4A4A"), NSAttributedString.Key.font: UIFont(name: AppFontName.semibold, size: 11.0)]
                viewController.tabBarItem.setTitleTextAttributes(textAttributes, for: .normal)
            } else {
                let textAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor(hexString: "#8E8E93"), NSAttributedString.Key.font: UIFont(name: AppFontName.regular, size: 11.0)]
                viewController.tabBarItem.setTitleTextAttributes(textAttributes, for: .normal)
            }
        }
    }
    
    deinit {
        AppSyncManager.instance.healthProfile.remove(observer: self)
        AppSyncManager.instance.internetConnectionAvailable.remove(observer: self)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func appcometoforeground() {
//        AppSyncManager.instance.syncUserProfile()
//        AppSyncManager.instance.getAppLink()
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
        sharemessage.append("Hey, you should download COVID Signals.  It's great companion in protecting yourself from COVID-19 and improving health safety.")
        sharemessage.append(AppSyncManager.instance.appShareLink)
        let activityVC = UIActivityViewController(activityItems: sharemessage, applicationActivities: nil)
        activityVC.title = "Share COVID Signals"
        //        activityVC.excludedActivityTypes = [.print, .airDrop, .assignToContact, .copyToPasteboard, .postToVimeo, .addToReadingList, .message, .postToWeibo]
        activityVC.popoverPresentationController?.sourceView = self.selectedViewController?.view
        self.selectedViewController?.present(activityVC, animated: true, completion: nil)
    }
}

extension UITabBar {
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let window = UIApplication.shared.keyWindow else {
            return super.sizeThatFits(size)
        }
        var sizeThatFits = super.sizeThatFits(size)
        let height: CGFloat = 60.0
        if height > 0.0 {

            if #available(iOS 11.0, *) {
                sizeThatFits.height = height + window.safeAreaInsets.bottom
            } else {
                sizeThatFits.height = height
            }
        }
        return sizeThatFits
    }
 }
