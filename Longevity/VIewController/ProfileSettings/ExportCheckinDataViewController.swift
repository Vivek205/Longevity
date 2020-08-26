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

        self.containerView.addSubview(self.actionButton)
        
        let infoText = "Your data will be formatted as a PDF and sent to your email address here:\n\n"
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Regular", size: 16.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
        let attributedInfoText = NSMutableAttributedString(string: infoText, attributes: attributes)
        
        guard let email = UserDefaults.standard.string(forKey: "email") else { return }
        
        let emailText = email
        let emailAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Medium", size: 16.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
        let emailAttributesText = NSMutableAttributedString(string: emailText, attributes: emailAttributes)
        
        attributedInfoText.append(emailAttributesText)
        self.infoLabel.attributedText = attributedInfoText
        self.infoLabel.sizeToFit()
        
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(greaterThanOrEqualTo: infoLabel.bottomAnchor, constant: 20.0),
            actionButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 60.0),
            actionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -60.0),
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -45.0)
        ])
    }
}
