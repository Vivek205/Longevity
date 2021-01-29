//
//  BaseStepViewController.swift
//  COVID Signals
//
//  Created by Jagan Kumar Mudila on 10/12/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

class BaseStepViewController: ORKStepViewController {
    
    lazy var footerView:UIView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.backgroundColor = .white
        return uiView
    }()

    lazy var continueButton: CustomButtonFill = {
        let buttonView = CustomButtonFill()
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.setTitle("Continue", for: .normal)
        buttonView.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        buttonView.isEnabled = false
        return buttonView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = .white
        
        self.view.addSubview(footerView)
        footerView.addSubview(continueButton)
        
        let bottomMargin: CGFloat = UIDevice.hasNotch ? -54.0 : -30.0

        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            continueButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 15),
            continueButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -15),
            continueButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 24),
            continueButton.heightAnchor.constraint(equalToConstant: 48.0),
            continueButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: bottomMargin)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.footerView.layer.shadowColor = UIColor.black.cgColor
        self.footerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.footerView.layer.shadowRadius = 3.0
        self.footerView.layer.shadowOpacity = 0.14
        self.footerView.layer.masksToBounds = false
        self.footerView.layer.shadowPath = UIBezierPath(roundedRect: self.footerView.bounds,
                                                        cornerRadius: self.footerView.layer.cornerRadius).cgPath
    }

    @objc func handleContinue() {
        self.goForward()
    }
}
