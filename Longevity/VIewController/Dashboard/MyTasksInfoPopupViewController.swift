//
//  MyTasksInfoPopupViewController.swift
//  Longevity
//
//  Created by vivek on 07/09/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class MyTasksInfoPopupViewController: BasePopUpModalViewController {
       
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.containerView.addSubview(self.actionButton)
        self.actionButton.setTitle("Ok", for: .normal)
        self.titleLabel.text = "My Tasks"

        let infoTitleText = "Available Surveys\n\n"
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-SemiBold", size: 18.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
        let attributedInfoText = NSMutableAttributedString(string: infoTitleText, attributes: attributes)
        
        let infoDescText = "Rejuve Surveys allow you to learn more about your health in an easy and quick way. Using survey data, data from your connected wearables, and your HealthKit, we generate personalized AI insight reports just for you.\n\nThe AI used to compute your personalized insight report is powered by SingularityNET and available on the SingularityNET marketplace. More specifically, we are using a bayesian network which allows for prediction, anomaly detection, diagnostics, automated insight, reasoning, time series prediction, and decision making based on the data you provide it."
        
        let descAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Regular", size: 16.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
            let descAttributesText = NSMutableAttributedString(string: infoDescText, attributes: descAttributes)
            attributedInfoText.append(descAttributesText)
        self.infoLabel.attributedText = attributedInfoText
        
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(greaterThanOrEqualTo: infoLabel.bottomAnchor, constant: 30.0),
            actionButton.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 30.0),
            actionButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -30.0),
            actionButton.heightAnchor.constraint(equalToConstant: 48),
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -27)
        ])
        
        
    }
}
