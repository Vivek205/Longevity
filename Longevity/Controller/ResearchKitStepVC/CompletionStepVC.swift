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
    let footerView:UIView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.backgroundColor = .white
        return uiView
    }()

    let continueButton: CustomButtonFill = {
        let buttonView = CustomButtonFill()
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.setTitle("Done", for: .normal)
        return buttonView
    }()

    let resultTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = "The results of the survey will be displayed here"
        return textView
    }()

    override func viewDidLoad() {
        self.backButtonItem = nil
        self.completeSurvey()
        self.presentViews()
    }

    func completeSurvey() {
        func completion() {
            DispatchQueue.main.async {
                self.removeSpinner()
            }
        }
        func onFailure(_ error: Error) {
            DispatchQueue.main.async {
                self.removeSpinner()
            }
        }
        self.showSpinner()
        let surveyTaskUtility = SurveyTaskUtility()
        surveyTaskUtility.completeSurvey(completion: completion, onFailure: onFailure(_:))
    }

    func presentViews() {
        self.view.addSubview(footerView)
        self.view.addSubview(resultTextView)
        footerView.addSubview(continueButton)
        let footerViewHeight = CGFloat(130)

        NSLayoutConstraint.activate([
            resultTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultTextView.topAnchor.constraint(equalTo: view.topAnchor),
            resultTextView.bottomAnchor.constraint(equalTo: footerView.topAnchor)
        ])

        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
