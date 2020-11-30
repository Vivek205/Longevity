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
    
    lazy var iconView:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "SetupComplete")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Montserrat-Regular", size: 20.0)
        label.textColor = UIColor(hexString: "#4E4E4E")
        label.text = "Thank you for completing \(SurveyTaskUtility.shared.getCurrentSurveyName() ?? ""). Your results are being processed by our AI analyzer.\n\nThis may take 1-2 minutes to process and update. You can continue using the app and you will be notified when your personalized report is ready."
        label.numberOfLines = 0
        return label
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

    override func viewDidLoad() {
        self.view.backgroundColor = .appBackgroundColor
        self.backButtonItem = nil
        self.presentViews()
        self.navigationItem.hidesBackButton = true
        
        SurveyTaskUtility.shared.surveyInProgress.addAndNotify(observer: self) { [weak self] in
            DispatchQueue.main.async {
                self?.viewResultsButton.isEnabled = SurveyTaskUtility.shared.surveyInProgress.value != .pending &&
                    SurveyTaskUtility.shared.surveyInProgress.value != .unknown
            }
        }
        self.completeSurvey()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "closex"),
                                                                 style: .plain, target: self, action: #selector(handleContinue(sender:)))
        self.navigationItem.title = "\(SurveyTaskUtility.shared.getCurrentSurveyName() ?? "") Complete!"
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor(hexString: "#4E4E4E"),
                              .font: UIFont(name: "Montserrat-SemiBold", size: 22.0)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.barTintColor = .appBackgroundColor
    }

    func completeSurvey() {
        func completion() {
            print("survey completed")
        }
        func onFailure(_ error: Error) {
            print("failed to complete the survey")
        }
        self.viewResultsButton.isEnabled = false
        SurveyTaskUtility.shared.completeSurvey(completion: completion, onFailure: onFailure(_:))
    }

    func presentViews() {
        
        self.view.addSubview(iconView)
        self.view.addSubview(infoLabel)
        self.view.addSubview(footerView)
        footerView.addSubview(continueButton)
        footerView.addSubview(viewResultsButton)
           
        let bottomMargin: CGFloat = UIDevice.hasNotch ? -54.0 : -30.0
        
        NSLayoutConstraint.activate([
            
            iconView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 24.0),
            iconView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            iconView.heightAnchor.constraint(equalToConstant: 200.0),
            iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor),
            
            infoLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 24.0),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15.0),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0),
            infoLabel.bottomAnchor.constraint(greaterThanOrEqualTo: footerView.topAnchor, constant: 20.0),

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
            viewResultsButton.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: bottomMargin)
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
        NavigationUtility.presentOverCurrentContext(destination: checkInResultViewController,
                                                    style: .overCurrentContext)
    }
}
