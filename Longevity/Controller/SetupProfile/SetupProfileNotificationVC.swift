//
//  SetupProfileNotificationVC.swift
//  Longevity
//
//  Created by vivek on 26/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class SetupProfileNotificationVC: BaseProfileSetupViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeBackButtonNavigation()
//        navigateToNextScreenIfAlreadyAuthorized()
        self.addProgressbar(progress: 60.0)
    }

//    func navigateToNextScreenIfAlreadyAuthorized() {
//        let defaults = UserDefaults.standard
//        let keys = UserDefaultsKeys()
//        guard defaults.value(forKey: keys.endpointArnForSNS) == nil else { return }
//
//        UNUserNotificationCenter.current().getNotificationSettings { settings in
//            print("Notification settings: \(settings)")
//            guard settings.authorizationStatus == .authorized else { return }
//
//            DispatchQueue.main.async {
//                let storyboard = UIStoryboard(name: "ProfileSetup", bundle: nil)
//                let devicesVC = storyboard.instantiateViewController(withIdentifier: "SetupProfileDevicesVC")
//                self.navigationController?.pushViewController(devicesVC, animated: true)
//            }
//        }
//    }
//
    @IBAction func handleEnableNotification(_ sender: Any) {
        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()

//        if let snsArnCreatedAlready = defaults.value(forKey: keys.endpointArnForSNS) as? String{
//            guard (snsArnCreatedAlready.isEmpty) else {
//                return self.performSegue(withIdentifier: "SetupNotificationsToDevices", sender: self)
//            }
//            self.registerForPushNotifications()
//        }else{

            // NOTE: For a device and a user, the setup flow will be shown only once
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            [weak self] granted, error in
            print("Permission granted: \(granted)")

            guard granted else {
                DispatchQueue.main.async {
                    self?.performSegue(withIdentifier: "SetupNotificationsToDevices", sender: self)
                }
                return
            }

            UNUserNotificationCenter.current().getNotificationSettings { settings in
                print("Notification settings: \(settings)")
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }

            DispatchQueue.main.async {
                self?.performSegue(withIdentifier: "SetupNotificationsToDevices", sender: self)
            }
        }
//        }
    }
    
    @IBAction func handleMayBeLater(_ sender: Any) {
//        let defaults = UserDefaults.standard
//        let keys = UserDefaultsKeys()
//        if let snsArnCreatedAlready = defaults.value(forKey: keys.endpointArnForSNS) as? String, !snsArnCreatedAlready.isEmpty {
//            AppSyncManager.instance.updateUserNotification(enabled: false)
//        }
//
        self.performSegue(withIdentifier: "SetupNotificationsToDevices", sender: self)
    }

}
