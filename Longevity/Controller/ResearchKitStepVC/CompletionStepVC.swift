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
    var currentSurveyId: String?
    var currentSurveyName: String?
    var isCurrentSurveyRepetitive: Bool?
    
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
        uiView.backgroundColor = .clear
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

    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()

    override func viewDidLoad() {
        self.view.backgroundColor = .appBackgroundColor
        self.backButtonItem = nil
        self.presentViews()
        self.navigationItem.hidesBackButton = true

        self.currentSurveyId = SurveyTaskUtility.shared.currentSurveyId
        self.currentSurveyName = SurveyTaskUtility.shared.getCurrentSurveyName()
        self.isCurrentSurveyRepetitive = SurveyTaskUtility.shared.isCurrentSurveyRepetitive()

        if ((self.currentSurveyId?.starts(with: "COUGH_TEST")) != nil){
            viewResultsButton.removeFromSuperview()
            continueButton.anchor(.bottom(footerView.bottomAnchor))
        }else {
            if let isCurrentSurveyRepetitive = self.isCurrentSurveyRepetitive {
                if isCurrentSurveyRepetitive {
                    viewResultsButton.setTitle("COVID Risk Assessment", for: .normal)
                }else {
                    viewResultsButton.setTitle("Start Your Check-in", for: .normal)
                }
            }
        }

        SurveyTaskUtility.shared.surveyInProgress.value = .unknown
        viewResultsButton.isEnabled = false
        self.completeSurvey()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "closex"),
                                                                 style: .plain, target: self, action: #selector(handleContinue(sender:)))
        self.navigationItem.title = "\(SurveyTaskUtility.shared.getCurrentSurveyName() ?? "") Complete!"
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor(hexString: "#4E4E4E"),
                              .font: UIFont(name: "Montserrat-SemiBold", size: 22.0)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.barTintColor = .appBackgroundColor
    }

    func isDateToday(date: String?) -> Bool {
        guard let date = date else {return false}
        let dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        var calendar = Calendar.current
        if let lastSubmissionDate = dateFormatter.date(from: date),
           let timezone = TimeZone(abbreviation: "UTC"){
            calendar.timeZone = timezone
            if calendar.isDateInToday(lastSubmissionDate) {
                return true
            }
        }
        return false
    }

    func shouldViewResultButtonBeEnabled() {
        DispatchQueue.main.async {self.viewResultsButton.isEnabled = false}
        if let isCurrentSurveyRepetitive = self.isCurrentSurveyRepetitive {
            if isCurrentSurveyRepetitive {
                let lastSubmissionId = SurveyTaskUtility.shared.oneTimeSurveyList.value?.first?.lastSubmissionId
                DispatchQueue.main.async {self.viewResultsButton.isEnabled = lastSubmissionId == nil}

            }else {
                let lastSubmissionDate = SurveyTaskUtility.shared.repetitiveSurveyList.value?.first?.lastSubmission
                DispatchQueue.main.async {self.viewResultsButton.isEnabled = !self.isDateToday(date: lastSubmissionDate)}
            }
        }
    }

    func completeSurvey() {
        func completion() {
            print("survey completed")
            shouldViewResultButtonBeEnabled()
        }
        func onFailure(_ error: Error) {
            print("failed to complete the survey")
        }
        SurveyTaskUtility.shared.completeSurvey(completion: completion, onFailure: onFailure(_:))
    }

    func presentViews() {

        self.view.addSubview(scrollView)
        self.scrollView.addSubview(iconView)
        self.scrollView.addSubview(infoLabel)
        self.scrollView.addSubview(footerView)
        self.footerView.addSubview(continueButton)
        self.footerView.addSubview(viewResultsButton)

        let bottomMargin: CGFloat = UIDevice.hasNotch ? -54.0 : -30.0
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 10),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor,constant: 10),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -10),

            iconView.topAnchor.constraint(equalTo: self.scrollView.topAnchor, constant: 24.0),
            iconView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            iconView.heightAnchor.constraint(equalToConstant: 200.0),
            iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor),
            
            infoLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 24.0),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15.0),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0),
            infoLabel.bottomAnchor.constraint(greaterThanOrEqualTo: footerView.topAnchor, constant: 20.0),

            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant:54),
            footerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            continueButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 15),
            continueButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -15),
            continueButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 40),
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
        self.showSpinner()
        guard let isCurrentSurveyRepetitive = self.isCurrentSurveyRepetitive else {return self.removeSpinner()}
        var surveyId: String?
        if isCurrentSurveyRepetitive {
            surveyId = SurveyTaskUtility.shared.oneTimeSurveyList.value?.first?.surveyId
        }else {
            surveyId = SurveyTaskUtility.shared.repetitiveSurveyList.value?.first?.surveyId
        }
        if surveyId == nil {return self.removeSpinner()}
        SurveyTaskUtility.shared.createSurvey(surveyId: surveyId) { (task) in
            DispatchQueue.main.async {
                let taskViewController = SurveyViewController(task: task, isFirstTask: true, isFirstCheckin: true)
                self.removeSpinner()
                NavigationUtility.presentOverCurrentContext(destination: taskViewController, style: .overCurrentContext)
            }
        } onFailure: { (error) in
            DispatchQueue.main.async {
                Alert(title: "Survey Unavailable",
                               message: "Unable to open the survey. Please try again later.")
                self.removeSpinner()
            }

        }


//        guard let surveyId = self.currentSurveyId,
//              let surveyName = self.currentSurveyName,
//              let isCheckIn = self.isCurrentSurveyRepetitive,
//              let submissionId = SurveyTaskUtility.shared.getLastSubmissionID(for: surveyId) else {return}
//
//        let checkInResultViewController = CheckInResultViewController(submissionID: submissionId, surveyName: surveyName, isCheckIn: isCheckIn)
//        NavigationUtility.presentOverCurrentContext(destination: checkInResultViewController,
//                                                    style: .overCurrentContext)
    }
}
