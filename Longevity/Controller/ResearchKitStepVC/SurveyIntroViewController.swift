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

    lazy var container: UIView = {
        let container = UIView()
        return container
    }()

    lazy var headerView: UIView = {
        let headerView = UIView()
        headerView.backgroundColor = .appBackgroundColorWhite
        return headerView
    }()

    lazy var headerLabel: UILabel = {
        let headerLabel  = UILabel(text: "title", font: UIFont(name: AppFontName.semibold, size: 24), textColor: .sectionHeaderColor, textAlignment: .center, numberOfLines: 0)
        return headerLabel
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
//        self.view.addSubview(container)
        self.view.addSubview(headerView)
        self.view.addSubview(footerView)
        footerView.addSubview(continueButton)
        let footerViewHeight = CGFloat(130)
        headerView.addSubview(headerLabel)

        headerView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor)
        headerView.anchor(.height(71))

        headerLabel.text = SurveyTaskUtility.shared.getCurrentSurveyName()
        headerLabel.anchor(top: headerView.topAnchor, leading: headerView.leadingAnchor, bottom: nil, trailing: headerView.trailingAnchor, padding: .init(top: 11, left: 15, bottom: 0, right: 15))
        headerLabel.anchor(.height(47))


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
