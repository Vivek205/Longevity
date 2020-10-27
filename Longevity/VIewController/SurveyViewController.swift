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

    func reloadSurveys() {

    }

    
    var isFirstTask: Bool = false
    
    init(task: ORKOrderedTask?, isFirstTask: Bool = false) {
        super.init(task: task, taskRun: nil)
        self.isFirstTask = isFirstTask
        self.delegate = self
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationBar.backgroundColor = .white
//        self.navigationBar.barTintColor = .blue
        if self.isFirstTask {
            self.navigationItem.backBarButtonItem = nil
            self.navigationItem.hidesBackButton = true
        }
        
        self.view.backgroundColor = .white
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController,
                            stepViewControllerWillAppear stepViewController: ORKStepViewController) {
//        taskViewController.navigationBar.barTintColor = .orange
        let taskViewAppearance =
            UIView.appearance(whenContainedInInstancesOf: [ORKTaskViewController.self])
        taskViewAppearance.tintColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
//        taskViewAppearance.tint
        if let step = stepViewController.step {
            if step is ORKInstructionStep || step is ORKCompletionStep {
//                self.navigationItem.backBarButtonItem = UIBarButtonItem()

                return
            }
            SurveyTaskUtility.shared.addTraversedQuestion(questionId: step.identifier)
        }
    }

    func taskViewController(_ taskViewController: ORKTaskViewController,
                            didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        switch reason {
        case .completed:
            print("completed")
            self.getSurveyList()
        case .discarded:
            print("discarded")
        case .failed:
            print("failed")
        case .saved:
            print("saved")
        @unknown default:
            print("unknown reason")
        }
        taskViewController.dismiss(animated: true) {print("task view controller dismissed")}
        getSurveys{ (_) in
            DispatchQueue.main.async {
                self.removeSpinner()
                taskViewController.dismiss(animated: true) {print("task view controller dismissed")}
            }
        } onFailure: { (_) in
            DispatchQueue.main.async {
                self.removeSpinner()
                taskViewController.dismiss(animated: true) {print("task view controller dismissed")}
            }
        }


    }
    
    func getSurveyList() {
        self.showSpinner()

        func completion(_ surveys:[SurveyListItem]) {
            DispatchQueue.main.async {
                self.removeSpinner()
            }
        }

        func onFailure(_ error:Error) {
            DispatchQueue.main.async {
                print(error)
                self.removeSpinner()
            }
        }
        getSurveys(completion: completion(_:), onFailure: onFailure(_:))
    }

    func taskViewController(_ taskViewController: ORKTaskViewController,
                            viewControllerFor step: ORKStep) -> ORKStepViewController? {

        if step is ORKInstructionStep {
            if step is ORKCompletionStep {
                let stepVC = CompletionStepVC()
                stepVC.step = step
                return stepVC
            } else if step is ORKInstructionStep {
                let stepVC = SurveyIntroViewController()
                stepVC.step = step
                return stepVC
            }
            // Default View Controller will be used
            return nil
        } else if step is ORKFormStep {
            let formStepVC = FormStepVC()
//            formStepVC.isFirstQuestion = isFirstQuestion
            formStepVC.step = step
            return formStepVC
        } else if step is ORKQuestionStep {
            guard let questionStep = step as? ORKQuestionStep else {return nil}
            if questionStep.answerFormat is ORKTextChoiceAnswerFormat {
                let stepVC = TextChoiceAnswerVC()
//                stepVC.isFirstQuestion = isFirstQuestion
                stepVC.step = step
                return stepVC
            }
            if questionStep.answerFormat is ORKContinuousScaleAnswerFormat {
                let questionDetails = SurveyTaskUtility.shared.getCurrentSurveyQuestionDetails(questionId: step.identifier)
                switch questionDetails?.quesType {
                case .temperatureScale:
                    let stepVC = TemperatureScaleAnswerVC()
//                    stepVC.isFirstQuestion = isFirstQuestion
                    stepVC.step = step
                    return stepVC
                default:
                    let stepVC = ContinuousScaleAnswerVC()
                    stepVC.step = step
                    return stepVC
                }
            }

            if questionStep.answerFormat is ORKTextAnswerFormat {
                let stepVC = TextAnswerVC()
                stepVC.step = step
                return stepVC
            }
        }
        return nil
    }

    func taskViewControllerShouldConfirmCancel(_ taskViewController: ORKTaskViewController?) -> Bool {
        return false
    }
}
