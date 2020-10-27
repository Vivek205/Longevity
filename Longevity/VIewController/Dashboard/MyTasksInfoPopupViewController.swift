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

//        let infoTitleText = "Available Surveys\n\n"
//        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-SemiBold", size: 18.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
//        let attributedInfoText = NSMutableAttributedString(string: infoTitleText, attributes: attributes)
        
        let infoDescText = "These survey(s) allow you to learn more about your health and COVID-19 risks in a more detailed way. The app uses your survey data to add deeper context to the COVID risk categories and generate more personalized AI insight reports just for you.\n\nNew surveys will be available periodically to help address new conditions and research centering around COVID-19."
        
        let descAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.regular, size: 16.0),.foregroundColor: UIColor.sectionHeaderColor]
//            let descAttributesText = NSMutableAttributedString(string: infoDescText, attributes: descAttributes)
        let attributedInfoText = NSMutableAttributedString(string: infoDescText, attributes: descAttributes)
//            attributedInfoText.append(descAttributesText)
        self.infoLabel.attributedText = attributedInfoText
        
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(greaterThanOrEqualTo: infoLabel.bottomAnchor, constant: 30.0),
            actionButton.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 59.0),
            actionButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -59.0),
            actionButton.heightAnchor.constraint(equalToConstant: 48),
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -27)
        ])
    }

    override func primaryButtonPressed(_ sender: UIButton) {
        super.primaryButtonPressed(sender)
        self.dismiss(animated: true, completion: nil)
    }
}
