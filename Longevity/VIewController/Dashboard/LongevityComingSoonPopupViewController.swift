//
//  LongevityComingSoonPopupViewController.swift
//  Longevity
//
//  Created by vivek on 07/09/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class LongevityComingSoonPopupViewController: BasePopUpModalViewController {

    lazy var emailNotification: UILabel = {
        let notification = UILabel()
        notification.font = UIFont(name: "Montserrat-Medium", size: 16.0)
        notification.text = "Send email notification when Longevity is ready"
        notification.textColor = UIColor(hexString: "#4E4E4E")
        notification.numberOfLines = 0
        notification.lineBreakMode = .byWordWrapping
        notification.translatesAutoresizingMaskIntoConstraints = false
        return notification
    }()
    
    lazy var notificationSwitch: UISwitch = {
        let notificationswitch = UISwitch()
        notificationswitch.onTintColor = .themeColor
        notificationswitch.translatesAutoresizingMaskIntoConstraints = false
        notificationswitch.addTarget(self, action: #selector(handleNotificationSwitch), for: .valueChanged)
        return notificationswitch
    }()
    
    lazy var primaryButton: CustomButtonFill = {
        let button = CustomButtonFill()
        button.setTitle("Ok", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 24.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.containerView.addSubview(emailNotification)
        self.containerView.addSubview(notificationSwitch)
        self.containerView.addSubview(primaryButton)
        
        self.titleLabel.text = "Longevity"
        
        let infoText = "Coming soon to you!"
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-SemiBold", size: 18.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
        let attributedInfoText = NSMutableAttributedString(string: infoText, attributes: attributes)
        
        let infoText2 = "\n\nCalculate your longevity age, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
        let attributes2: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Regular", size: 16.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
        let attributedInfoText2 = NSMutableAttributedString(string: infoText2, attributes: attributes2)
        
        attributedInfoText.append(attributedInfoText2)
        self.infoLabel.attributedText = attributedInfoText
        
        NSLayoutConstraint.activate([
            emailNotification.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 24.0),
            emailNotification.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 18.0),
            self.notificationSwitch.centerYAnchor.constraint(equalTo: emailNotification.centerYAnchor),
            notificationSwitch.leadingAnchor.constraint(equalTo: emailNotification.trailingAnchor, constant: 11.0),
            notificationSwitch.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -30.0),
            primaryButton.topAnchor.constraint(equalTo: emailNotification.bottomAnchor, constant: 24.0),
            primaryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            primaryButton.widthAnchor.constraint(equalToConstant: view.bounds.width - 120),
            primaryButton.heightAnchor.constraint(equalToConstant: 48),
            primaryButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24.0)
        ])

        AppSyncManager.instance.userSubscriptions.addAndNotify(observer: self) {
            [weak self] in
            guard let userSubscriptions = AppSyncManager.instance.userSubscriptions.value,
            let subscription = userSubscriptions.first(where: {
                (subscription) -> Bool in
                return subscription.subscriptionType == .longevityRelease && subscription.communicationType == .email
            })
            else {return}

            DispatchQueue.main.async {
                self?.notificationSwitch.isOn = subscription.status
            }
        }
    }
    
    @objc func handleNotificationSwitch() {
        if self.notificationSwitch.isOn {
            AppSyncManager.instance.updateUserSubscription(subscriptionType: .longevityRelease, communicationType: .email, status: true)
        } else {
            AppSyncManager.instance.updateUserSubscription(subscriptionType: .longevityRelease, communicationType: .email, status: false)
            self.closeView()
        }
    }
}
