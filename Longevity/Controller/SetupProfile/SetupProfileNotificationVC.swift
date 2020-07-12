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
    }
    
    
    
    @IBAction func handleEnableNotification(_ sender: Any) {
        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()
        if let snsArnCreatedAlready = UserDefaults.standard.value(forKey: keys.endpointArnForSNS) as? String{
            guard !(snsArnCreatedAlready.isEmpty) else {
                return
            }
            self.registerForPushNotifications()
            self.performSegue(withIdentifier: "SetupNotificationsToDevices", sender: self)

        }else{
            self.performSegue(withIdentifier: "SetupNotificationsToDevices", sender: self)
        }
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current() // 1
            .requestAuthorization(options: [.alert, .sound, .badge]) { // 2
                [weak self] granted, error in
                print("Permission granted: \(granted)")
                guard granted else { return }
                self?.getNotificationSettings()
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
