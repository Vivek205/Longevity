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
        label.font = UIFont(name: AppFontName.regular, size: 20.0)
        label.textColor = UIColor(hexString: "#4E4E4E")
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
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
    
    lazy var nextSurveyButton: UIButton = {
        let nextsurvey = UIButton()
        nextsurvey.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 24.0)
        nextsurvey.translatesAutoresizingMaskIntoConstraints = false
        return nextsurvey
    }()
    
    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .appBackgroundColor
        self.backButtonItem = nil
        
        self.currentSurveyId = SurveyTaskUtility.shared.currentSurveyId
        self.currentSurveyName = SurveyTaskUtility.shared.getCurrentSurveyName()
        self.isCurrentSurveyRepetitive = SurveyTaskUtility.shared.isCurrentSurveyRepetitive()
        self.navigationItem.hidesBackButton = true
        
        self.presentViews()
        
        if (self.currentSurveyId?.starts(with: "COUGH_TEST") == true) {
            self.nextSurveyButton.removeFromSuperview()
            self.continueButton.anchor(.bottom(footerView.bottomAnchor))
            self.navigationItem.title = "\(SurveyTaskUtility.shared.getCurrentSurveyName() ?? "") Complete!"
        } else {
            if let isCurrentSurveyRepetitive = self.isCurrentSurveyRepetitive {
                if isCurrentSurveyRepetitive {
                    self.nextSurveyButton.setTitle("COVID Risk Assessment", for: .normal)
                    self.navigationItem.title = "Check-in Complete!"
                } else {
                    self.nextSurveyButton.setTitle("Start Your Check-in", for: .normal)
                    self.navigationItem.title = "Survey Complete!"
                }
            }
        }
        SurveyTaskUtility.shared.setStatus(surveyId: self.currentSurveyId!)
        
        self.nextSurveyButton.disableSecondaryButton()
        
        if (self.currentSurveyId?.starts(with: "COUGH_TEST") == true) {
            self.uploadFiles { [unowned self] in
                self.completeSurvey()
            } failure: { [unowned self] in
                self.goForward()
            }
        } else {
            self.completeSurvey()
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "closex"),
                                                                 style: .plain, target: self, action: #selector(handleContinue(sender:)))
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor(hexString: "#4E4E4E"),
                              .font: UIFont(name: AppFontName.semibold, size: 22.0)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes as [NSAttributedString.Key : Any]
        self.navigationController?.navigationBar.barTintColor = .appBackgroundColor
    }
    
    fileprivate func uploadFiles(success: @escaping() -> Void, failure: @escaping() -> Void) {
        self.showSpinner()
        let coughRecordUploader = CoughRecordUploader()
        coughRecordUploader.uploadCoughTestFiles {
            success()
            coughRecordUploader.removeDirectory()
        } failure: { [unowned self] (message) in
            DispatchQueue.main.async {
                self.removeSpinner()
                let tryAction = UIAlertAction(title: "Try Again", style: .default) { [unowned self] (_) in
                    self.uploadFiles(success: success, failure: failure)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
                    coughRecordUploader.removeDirectory()
                    failure()
                }
                Alert(title: "Upload Error", message: "Unable to upload cough recordings. Would you like to try again?", actions: tryAction, cancelAction)
            }
        }
    }
    
    func isDateToday(date: String?) -> Bool {
        guard let date = date else {return false}
        let dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // referring to the timezon of the date provided for comparision
        var calendar = Calendar.current
        if let lastSubmissionDate = dateFormatter.date(from: date)
        {
            calendar.timeZone = .current // referring to the local timezone to be checked against
            if calendar.isDateInToday(lastSubmissionDate) {
                return true
            }
        }
        return false
    }
    
    func shouldViewResultButtonBeEnabled() {
        DispatchQueue.main.async {
            self.nextSurveyButton.disableSecondaryButton()
        }
        if let isCurrentSurveyRepetitive = self.isCurrentSurveyRepetitive {
            if isCurrentSurveyRepetitive {
                let lastSubmissionId = SurveyTaskUtility.shared.oneTimeSurveyList.value?.first?.lastSubmissionId
                DispatchQueue.main.async {
                    if lastSubmissionId == nil {
                        self.nextSurveyButton.enableButton()
                    } else {
                        self.nextSurveyButton.disableSecondaryButton()
                    }
                }
            } else {
                let lastSubmissionDate = SurveyTaskUtility.shared.repetitiveSurveyList.value?.first?.lastSubmission
                DispatchQueue.main.async {
                    if !self.isDateToday(date: lastSubmissionDate) {
                        self.nextSurveyButton.enableButton()
                    } else {
                        self.nextSurveyButton.disableSecondaryButton()
                    }
                }
            }
        }
    }
    
    func completeSurvey() {
        func completion() {
            DispatchQueue.main.async {
                self.removeSpinner()
            }
            shouldViewResultButtonBeEnabled()
        }
        func onFailure(_ error: Error) {
            DispatchQueue.main.async {
                self.removeSpinner()
                self.nextSurveyButton.disableSecondaryButton()
            }
        }
        DispatchQueue.main.async {
            self.showSpinner()
        }
        SurveyTaskUtility.shared.completeSurvey(completion: completion, onFailure: onFailure(_:))
    }
    
    func presentViews() {
        
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(iconView)
        self.scrollView.addSubview(infoLabel)
        self.scrollView.addSubview(footerView)
        self.footerView.addSubview(continueButton)
        self.footerView.addSubview(nextSurveyButton)
        
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
            footerView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor),
            footerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            continueButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 15),
            continueButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -15),
            continueButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 60),
            continueButton.heightAnchor.constraint(equalToConstant: 48),
            nextSurveyButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 15),
            nextSurveyButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -15),
            nextSurveyButton.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: 24),
            nextSurveyButton.heightAnchor.constraint(equalToConstant: 48),
            nextSurveyButton.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: bottomMargin)
        ])
        continueButton.isEnabled = true
        continueButton.addTarget(self, action: #selector(handleContinue(sender:)), for: .touchUpInside)
        nextSurveyButton.addTarget(self, action: #selector(doViewResults), for: .touchUpInside)
        
        if (self.currentSurveyId?.starts(with: "COUGH_TEST") == true) {
            self.infoLabel.text = "Thank you for completing the cough test. Your data is being processed by our AI analyzer.\n\nResults will not be avaliable at this time. Once there is sufficent amount of data to ensure accurate results, results will be avaliable. It is recommend to perform this test daily for optimal accuracy."
        } else if self.isCurrentSurveyRepetitive ?? false {
            self.infoLabel.text = "Your results are being processed by our AI analyzer. This may take few seconds to process and update your personalized report.\n\nYou can continue using the app and you will be notified results are ready."
        }
        else
        {
            self.infoLabel.text = "Thank you for completing COVID Risk Assessment. Your results are being processed by our AI analyzer.\n\nThis may take few seconds to process and update.  You can continue using the app and you will be notified when your personalized report is ready."
        }
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
}
