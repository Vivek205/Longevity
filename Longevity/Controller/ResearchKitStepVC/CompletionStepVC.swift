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
    
    lazy var viewResultsButton: CustomButtonFill = {
        let viewresults = CustomButtonFill()
        viewresults.translatesAutoresizingMaskIntoConstraints = false
        viewresults.setTitle("View Results", for: .normal)
        return viewresults
    }()

    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Thank you for completing COVID Risk Assessment. Your results are being processed by our AI analyzer.\nThis may take 1-2 minutes to process and update. You can continue using the app and you will be notified when your personalized report is ready."
        label.numberOfLines = 0
        return label
    }()

    override func viewDidLoad() {
        self.backButtonItem = nil
        self.presentViews()
        self.navigationItem.hidesBackButton = true
        
        SurveyTaskUtility.shared.surveyInProgress.addAndNotify(observer: self) { [weak self] in
            DispatchQueue.main.async {
                self?.viewResultsButton.isEnabled = SurveyTaskUtility.shared.surveyInProgress.value != .pending
            }
        }
        self.completeSurvey()
    }

    func completeSurvey() {
        func completion() {
            print("survey completed")
            AppSyncManager.instance.syncSurveyList()
        }
        func onFailure(_ error: Error) {
            print("failed to complete the survey")
        }
        self.viewResultsButton.isEnabled = false
        SurveyTaskUtility.shared.completeSurvey(completion: completion, onFailure: onFailure(_:))
    }

    func presentViews() {
        self.view.addSubview(footerView)
        self.view.addSubview(completedMessage)
        footerView.addSubview(continueButton)
        footerView.addSubview(viewResultsButton)

        NSLayoutConstraint.activate([
            completedMessage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            completedMessage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            completedMessage.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
//            completedMessage.heightAnchor.constraint(equalToConstant: 200),

            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            continueButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 15),
            continueButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -15),
            continueButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 22),
            continueButton.heightAnchor.constraint(equalToConstant: 48),
            viewResultsButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 15),
            viewResultsButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -15),
            viewResultsButton.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: 24),
            viewResultsButton.heightAnchor.constraint(equalToConstant: 48),
            viewResultsButton.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -30.0)
        ])
        continueButton.isEnabled = true
        continueButton.addTarget(self, action: #selector(handleContinue(sender:)), for: .touchUpInside)
        viewResultsButton.addTarget(self, action: #selector(doViewResults), for: .touchUpInside)
    }

    @objc func handleContinue(sender: UIButton) {
        self.goForward()
    }
    
    @objc func doViewResults() {
        let checkInResultViewController = CheckInResultViewController()
        NavigationUtility.presentOverCurrentContext(destination: checkInResultViewController, style: .overCurrentContext)
    }
}
