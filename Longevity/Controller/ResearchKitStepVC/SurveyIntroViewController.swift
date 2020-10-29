//
//  SurveyIntroViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 05/10/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

class SurveyIntroViewController: ORKInstructionStepViewController {
    var keyboardHeight: CGFloat?
    var initialYOrigin: CGFloat = CGFloat(0)

    lazy var containerView: UIView = {
        let container = UIView()
        container.backgroundColor = .appBackgroundColor
        return container
    }()

    lazy var headerView: UIView = {
        let headerView = UIView()
        headerView.backgroundColor = .white
        return headerView
    }()

    lazy var headerLabel: UILabel = {
        let headerLabel  = UILabel(text: "title", font: UIFont(name: AppFontName.semibold, size: 24), textColor: .sectionHeaderColor, textAlignment: .center, numberOfLines: 0)
        return headerLabel
    }()

    lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel(text: "title", font: UIFont(name: AppFontName.regular, size: 20), textColor: .sectionHeaderColor, textAlignment: .left, numberOfLines: 0)
        descriptionLabel.sizeToFit()
        return descriptionLabel
    }()

    lazy var footerView:UIView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.backgroundColor = .white
        return uiView
    }()

    lazy var continueButton: CustomButtonFill = {
        let buttonView = CustomButtonFill()
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.setTitle("Begin", for: .normal)
        return buttonView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationItem.hidesBackButton = true
        
        presentViews()
        print("did load", self.view.frame.origin.y )
        self.initialYOrigin = self.view.frame.origin.y
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.addBottomRoundedEdge(desiredCurve: 0.5)
    }

    func presentViews() {
        if let step = self.step as? ORKInstructionStep {
            descriptionLabel.text = step.text
        }

        self.view.addSubview(containerView)
        self.view.addSubview(headerView)
        self.view.addSubview(footerView)
        footerView.addSubview(continueButton)
        let footerViewHeight = CGFloat(130)
        headerView.addSubview(headerLabel)
        containerView.addSubview(descriptionLabel)

        containerView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: footerView.topAnchor, trailing: view.trailingAnchor)

        headerView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor)
        headerView.anchor(.height(71))

        headerLabel.text = SurveyTaskUtility.shared.getCurrentSurveyName()
        headerLabel.anchor(top: headerView.topAnchor, leading: headerView.leadingAnchor, bottom: nil, trailing: headerView.trailingAnchor, padding: .init(top: 0, left: 15, bottom: 0, right: 15))
        headerLabel.anchor(.height(47))

        descriptionLabel.anchor(top: headerView.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 21, left: 15, bottom: 0, right: 15))
        let descriptionLabelHeight:CGFloat = descriptionLabel.text?.height(withConstrainedWidth: view.frame.size.width - 30.0, font: descriptionLabel.font) ?? 0
        descriptionLabel.anchor(.height(descriptionLabelHeight))

        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: footerViewHeight)
        ])

        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 15),
            continueButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -15),
            continueButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 24),
            continueButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        continueButton.isEnabled = true
        continueButton.addTarget(self, action: #selector(handleContinue(sender:)), for: .touchUpInside)


    }

    @objc func handleContinue(sender: UIButton) {
        self.goForward()
    }
}
