//
//  SetupProfileNotificationVC.swift
//  Longevity
//
//  Created by vivek on 26/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class SetupProfileNotificationVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeBackButtonNavigation()
        navigateToNextScreenIfAlreadyAuthorized()
    }

    func navigateToNextScreenIfAlreadyAuthorized() {
        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()
        guard defaults.value(forKey: keys.endpointArnForSNS) == nil else { return }
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }

            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "ProfileSetup", bundle: nil)
                let  homeVC = storyboard.instantiateViewController(withIdentifier: "SetupProfileDevicesVC")
                let navigationController = UINavigationController(rootViewController: homeVC)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func handleEnableNotification(_ sender: Any) {
        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()
        
        if let snsArnCreatedAlready = defaults.value(forKey: keys.endpointArnForSNS) as? String{
            guard (snsArnCreatedAlready.isEmpty) else {
                return self.performSegue(withIdentifier: "SetupNotificationsToDevices", sender: self)
            }
            self.registerForPushNotifications()
        }else{
            self.registerForPushNotifications()
        }
    }
    
    @IBAction func handleMayBeLater(_ sender: Any) {
        self.performSegue(withIdentifier: "SetupNotificationsToDevices", sender: self)
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current() // 1
            .requestAuthorization(options: [.alert, .sound, .badge]) { // 2
                [weak self] granted, error in
                print("Permission granted: \(granted)")
                guard granted else {
                    DispatchQueue.main.async {
                        self?.performSegue(withIdentifier: "SetupNotificationsToDevices", sender: self)
                    }
                    return
                }
                self?.getNotificationSettings()
                DispatchQueue.main.async {
                    self?.performSegue(withIdentifier: "SetupNotificationsToDevices", sender: self)
                }
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}
