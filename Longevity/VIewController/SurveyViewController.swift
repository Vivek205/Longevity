//
//  SurveyViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 25/09/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

class SurveyViewController: ORKTaskViewController, ORKTaskViewControllerDelegate {
    
    var isFirstTask: Bool = false
    var isFirstCheckIn: Bool = false
    
    init(task: ORKOrderedTask?, isFirstTask: Bool = false, isFirstCheckin: Bool = false) {
        super.init(task: task, taskRun: nil)
        self.isFirstTask = isFirstTask
        self.isFirstCheckIn = isFirstCheckin
        self.delegate = self
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.isFirstTask {
            self.navigationItem.backBarButtonItem = nil
            self.navigationItem.hidesBackButton = true
        }
        
        self.view.backgroundColor = .appBackgroundColor
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController,
                            stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        let taskViewAppearance =
            UIView.appearance(whenContainedInInstancesOf: [ORKTaskViewController.self])
        taskViewAppearance.tintColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)

        if let step = stepViewController.step {
            if step is ORKInstructionStep || step is ORKCompletionStep {
                return
            }
            SurveyTaskUtility.shared.addTraversedQuestion(questionId: step.identifier)
        }
    }

    func taskViewController(_ taskViewController: ORKTaskViewController,
                            didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {        
        if self.isFirstCheckIn {
            DispatchQueue.main.async {
                let tabbarViewController = LNTabBarViewController()
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                appDelegate.window?.rootViewController = tabbarViewController
            }
        } else {
            let isCoughTest = SurveyTaskUtility.shared.currentSurveyId?.contains("COUGH") ?? false
            if isCoughTest {
                SurveyTaskUtility.shared.clearSurvey()
                guard let documentURL = FileManager.default.urls(for: .documentDirectory,
                                                                 in: .userDomainMask).first else { return }
                let path = documentURL.appendingPathComponent(SurveyTaskUtility.shared.coughTestFolderName).absoluteURL
                
                try? FileManager.default.removeItem(at: path)
            }
            DispatchQueue.main.async {
                self.removeSpinner()
                taskViewController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
//    func getSurveyList() {
//        self.showSpinner()
//
//        func completion(_ surveys:[SurveyListItem]) {
//            DispatchQueue.main.async {
//                self.removeSpinner()
//            }
//        }
//
//        func onFailure(_ error:Error) {
//            DispatchQueue.main.async {
//                print(error)
//                self.removeSpinner()
//            }
//        }
//        SurveysAPI.instance.getSurveys(completion: completion(_:), onFailure: onFailure(_:))
//    }

    func taskViewController(_ taskViewController: ORKTaskViewController,
                            viewControllerFor step: ORKStep) -> ORKStepViewController? {

        if step is ORKInstructionStep {
            let isCoughTest = SurveyTaskUtility.shared.currentSurveyId?.contains("COUGH") ?? false
            if step is ORKCompletionStep {
                if isCoughTest {
                    let completeVC = CoughTestCompleteViewController()
                    completeVC.step = step
                    return completeVC
                } else {
                    let stepVC = CompletionStepVC()
                    stepVC.step = step
                    return stepVC
                }
            } else if step is ORKInstructionStep {
                let stepVC = SurveyIntroViewController(isCoughTest: isCoughTest)
                stepVC.step = step
                return stepVC
            }
            // Default View Controller will be used
            return nil
        } else if step is ORKFormStep {
            let formStepVC = FormStepVC()
            formStepVC.step = step
            return formStepVC
        } else if step is ORKQuestionStep {
            guard let questionStep = step as? ORKQuestionStep else {return nil}
            if questionStep.answerFormat is ORKTextChoiceAnswerFormat {
                let stepVC = TextChoiceAnswerVC()
                stepVC.step = step
                return stepVC
            } else if questionStep.answerFormat is ORKContinuousScaleAnswerFormat {
                let questionDetails = SurveyTaskUtility.shared.getCurrentSurveyQuestionDetails(questionId: step.identifier)
                switch questionDetails?.quesType {
                case .temperatureScale:
                    let stepVC = TemperatureScaleAnswerVC()
                    stepVC.step = step
                    return stepVC
                default:
                    let stepVC = ContinuousScaleAnswerVC()
                    stepVC.step = step
                    return stepVC
                }
            } else if questionStep.answerFormat is ORKTextAnswerFormat {
                let stepVC = TextAnswerVC()
                stepVC.step = step
                return stepVC
            } else if questionStep.answerFormat is ORKValuePickerAnswerFormat {
                let stepVC = ValuePickerAnswerVC()
                stepVC.step = step
                return stepVC
            } else if questionStep.answerFormat is ORKLocationAnswerFormat {
                let stepViewController = CoughRecorderViewController()
                stepViewController.step = step
                return stepViewController
            }
        }
        return nil
    }

    func taskViewControllerShouldConfirmCancel(_ taskViewController: ORKTaskViewController?) -> Bool {
        return false
    }
}
