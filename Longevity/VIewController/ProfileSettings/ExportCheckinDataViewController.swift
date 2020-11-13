//
//  ExportCheckinDataViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 20/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class ExportCheckinDataViewController: BasePopUpModalViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showBackdrop = true
        self.containerView.addSubview(self.actionButton)

        self.titleLabel.text = "Check-in Data"
        
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(greaterThanOrEqualTo: infoLabel.bottomAnchor, constant: 20.0),
            actionButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 60.0),
            actionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -60.0),
            actionButton.heightAnchor.constraint(equalToConstant: 48.0),
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -45.0)
        ])

        AppSyncManager.instance.userProfile.addAndNotify(observer: self) { [weak self] in
            let infoText = "Your data will be sent to your email address here:\n\n"
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Regular", size: 16.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
            let attributedInfoText = NSMutableAttributedString(string: infoText, attributes: attributes)
            guard let email = AppSyncManager.instance.userProfile.value?.email else {return}

            DispatchQueue.main.async {
                let emailAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Medium", size: 16.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
                let emailAttributesText = NSMutableAttributedString(string: email, attributes: emailAttributes)
                attributedInfoText.append(emailAttributesText)
                self?.infoLabel.attributedText = attributedInfoText
            }
        }
    }

    override func primaryButtonPressed(_ sender: UIButton) {
        let userInsightsAPI = UserInsightsAPI()

        self.showSpinner()
        let action = UIAlertAction(title: "OK", style: .default, handler: self.handleUIAlertAction(_:) )

        userInsightsAPI.exportUserApplicationData(completion: {
            DispatchQueue.main.async {
                self.removeSpinner()
                Alert(title: "Success",
                               message: "Your data has been exported successfully. You will receive an email shortly.", action: action)
            }

        }) { (error) in
            DispatchQueue.main.async {
                self.removeSpinner()

                Alert(title: "Failure", message: "Unable to export your data. Please try later.", action: action)
            }
        }
    }

    func handleUIAlertAction(_ action: UIAlertAction) {
        if AppSyncManager.instance.internetConnectionAvailable.value == .connected {
            DispatchQueue.main.async {
                self.closeView()
            }
        }
    }
}
