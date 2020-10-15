//
//  CompletionStep.swift
//  Longevity
//
//  Created by vivek on 13/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

class CompletionStepVC: ORKStepViewController {
    lazy var completedMessage: DashboardTaskCompletedCell = {
        let view = DashboardTaskCompletedCell()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel.text = "All questions are completed"
        view.info.text = "Great, you have answered all the questions! Enjoy your day. We will analyze the response and notify you once the report is ready"
        return view
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
        buttonView.setTitle("Done", for: .normal)
        return buttonView
    }()

    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Thanks for participating in the survey. We will notify you once your results are ready"
        label.numberOfLines = 0
        return label
    }()

    override func viewDidLoad() {
        self.backButtonItem = nil
        self.completeSurvey()
        self.presentViews()
        self.navigationItem.hidesBackButton = true
    }

    func completeSurvey() {
        func completion() {
            print("survey completed")
        }
        func onFailure(_ error: Error) {
            print("failed to complete the survey")
        }
        SurveyTaskUtility.shared.completeSurvey(completion: completion, onFailure: onFailure(_:))
    }

    func presentViews() {
        self.view.addSubview(footerView)
        self.view.addSubview(completedMessage)
        footerView.addSubview(continueButton)
        let footerViewHeight = CGFloat(130)

        NSLayoutConstraint.activate([
            completedMessage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            completedMessage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            completedMessage.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            completedMessage.heightAnchor.constraint(equalToConstant: 200),

            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: footerViewHeight),

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
