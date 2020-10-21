//
//  SetupProfileNotificationVC.swift
//  Longevity
//
//  Created by vivek on 26/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class SetupProfileNotificationVC: BaseProfileSetupViewController {
    @IBOutlet weak var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeBackButtonNavigation()
        let descriptionLabelWidth:CGFloat = UIScreen.main.bounds.width - 30.0
        descriptionLabel.anchor(.width(descriptionLabelWidth))

        self.addProgressbar(progress: 60.0)
    }


    @IBAction func handleEnableNotification(_ sender: Any) {
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
        self.performSegue(withIdentifier: "SetupNotificationsToDevices", sender: self)
    }

}
