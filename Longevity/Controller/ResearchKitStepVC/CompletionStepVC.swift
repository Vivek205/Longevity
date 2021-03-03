//
//  CompletionStep.swift
//  Longevity
//
//  Created by vivek on 13/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

class CompletionStepVC: CompleteStepBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.isCurrentSurveyRepetitive ?? false {
            self.infoLabel.text = "Your results are being processed by our AI analyzer. This may take few seconds to process and update your personalized report.\n\nYou can continue using the app and you will be notified results are ready."
            self.secondaryActionButton.setTitle("COVID Risk Assessment", for: .normal)
            self.navigationItem.title = "Check-in Complete!"
        }
        else
        {
            self.infoLabel.text = "Thank you for completing COVID Risk Assessment. Your results are being processed by our AI analyzer.\n\nThis may take few seconds to process and update.  You can continue using the app and you will be notified when your personalized report is ready."
            self.secondaryActionButton.setTitle("Start Your Check-in", for: .normal)
            self.navigationItem.title = "Survey Complete!"
        }
        
        self.primaryActionButton.addTarget(self, action: #selector(handleContinue(sender:)), for: .touchUpInside)
        self.secondaryActionButton.addTarget(self, action: #selector(doViewResults), for: .touchUpInside)
        
        self.secondaryActionButton.disableSecondaryButton()
        self.completeSurvey()
    }
    
    func shouldViewResultButtonBeEnabled() {
        DispatchQueue.main.async {
            self.secondaryActionButton.disableSecondaryButton()
        }
        if let isCurrentSurveyRepetitive = self.isCurrentSurveyRepetitive {
            if isCurrentSurveyRepetitive {
                let lastSubmissionId = SurveyTaskUtility.shared.oneTimeSurveyList.value?.first?.lastSubmissionId
                DispatchQueue.main.async {
                    if lastSubmissionId == nil {
                        self.secondaryActionButton.enableButton()
                    } else {
                        self.secondaryActionButton.disableSecondaryButton()
                    }
                }
            } else {
                let lastSubmissionDate = SurveyTaskUtility.shared.repetitiveSurveyList.value?.first?.lastSubmission
                DispatchQueue.main.async {
                    if !self.isDateToday(date: lastSubmissionDate) {
                        self.secondaryActionButton.enableButton()
                    } else {
                        self.secondaryActionButton.disableSecondaryButton()
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
                self.secondaryActionButton.disableSecondaryButton()
            }
        }
        
        super.completeSurvey(completion: completion, onFailure: onFailure(_:))
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
