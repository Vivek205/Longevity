//
//  LongevityComingSoonPopupViewController.swift
//  Longevity
//
//  Created by vivek on 07/09/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class LongevityComingSoonPopupViewController: BasePopUpModalViewController {

    var originalStatus: Bool = false
    
    lazy var emailNotification: UILabel = {
        let notification = UILabel()
        notification.font = UIFont(name: AppFontName.medium, size: 16.0)
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
        return notificationswitch
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.containerView.addSubview(emailNotification)
        self.containerView.addSubview(notificationSwitch)
        self.containerView.addSubview(actionButton)
        self.actionButton.setTitle("Ok", for: .normal)
        self.titleLabel.text = "Longevity"
        
        let infoText = "Coming soon!"
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.semibold, size: 18.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
        let attributedInfoText = NSMutableAttributedString(string: infoText, attributes: attributes)
        
        let infoText2 = "\n\nPredicted your biological age from different data types and your health history profile.  Track your wellness in detail, helping you to control your aging and extend your healthy productive longevity.  Provide you with easy-to-do tasks on a daily basis."
        let attributes2: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.regular, size: 16.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
        let attributedInfoText2 = NSMutableAttributedString(string: infoText2, attributes: attributes2)
        
        attributedInfoText.append(attributedInfoText2)
        self.infoLabel.attributedText = attributedInfoText
        
        NSLayoutConstraint.activate([
            emailNotification.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 24.0),
            emailNotification.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 18.0),
            emailNotification.trailingAnchor.constraint(lessThanOrEqualTo: self.notificationSwitch.leadingAnchor,
                                                        constant: -20.0),
            notificationSwitch.widthAnchor.constraint(equalToConstant: 30.0),
            notificationSwitch.centerYAnchor.constraint(equalTo: emailNotification.centerYAnchor),
            notificationSwitch.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -35.0),
            actionButton.topAnchor.constraint(equalTo: emailNotification.bottomAnchor, constant: 24.0),
            actionButton.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
            actionButton.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 59.0),
            actionButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -59.0),
            actionButton.heightAnchor.constraint(equalToConstant: 48),
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24.0)
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
                self?.originalStatus = subscription.status
            }
        }
    }
    
    override func primaryButtonPressed(_ sender: UIButton) {
        let currentStatus = self.notificationSwitch.isOn
        if self.originalStatus != currentStatus {
            self.showSpinner()
            AppSyncManager.instance.updateUserSubscription(subscriptionType: .longevityRelease,
                                                           communicationType: .email,
                                                           status: currentStatus) { [weak self] in
                DispatchQueue.main.async {
                    self?.removeSpinner()
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    deinit {
        AppSyncManager.instance.userSubscriptions.remove(observer: self)
    }
}
