//
//  ResetCheckInDataViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 27/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class ResetCheckInDataViewController: BasePopUpModalViewController {
    
    lazy var cancelButton: UIButton = {
        let cancel = UIButton()
        cancel.setTitle("Cancel", for: .normal)
        cancel.setTitleColor(.themeColor, for: .normal)
        cancel.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 18.0)
        cancel.backgroundColor = .white
        cancel.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        cancel.translatesAutoresizingMaskIntoConstraints = false
        return cancel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.containerView.addSubview(self.cancelButton)
        self.containerView.addSubview(self.actionButton)
        
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(greaterThanOrEqualTo: infoLabel.bottomAnchor, constant: 20.0),
            cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 23.0),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -45.0),
            actionButton.topAnchor.constraint(greaterThanOrEqualTo: infoLabel.bottomAnchor, constant: 20.0),
            actionButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 24.0),
            actionButton.widthAnchor.constraint(equalToConstant: 190.0),
            actionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -23.0),
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -45.0)
        ])
        
        self.titleLabel.text = "Reset Check-in Data"
        let infoText = "WARNING: this will erase all your check-in data permanently and lower the accuracy of your health assessments."
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Regular", size: 16.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
        let attributedInfoText = NSMutableAttributedString(string: infoText, attributes: attributes)
        
        self.infoLabel.attributedText = attributedInfoText
        
        self.actionButton.setTitle("Reset", for: .normal)
        self.actionButton.backgroundColor = UIColor(hexString: "#E67381")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.cancelButton.layer.cornerRadius = 10.0
        self.cancelButton.layer.masksToBounds = true
        self.cancelButton.layer.borderWidth = 2
        self.cancelButton.layer.borderColor = UIColor.themeColor.cgColor
    }
}
