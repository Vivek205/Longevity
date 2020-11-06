//
//  SetupCompleteVC.swift
//  Longevity
//
//  Created by vivek on 14/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//
//
import UIKit
import ResearchKit

class SetupCompleteVC: BaseProfileSetupViewController {
    @IBOutlet weak var noteLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeBackButtonNavigation()
        
        let footerheight: CGFloat = UIDevice.hasNotch ? 130.0 : 96.0
        
        let headingAttributes:[NSAttributedString.Key:Any] =
            [.font: UIFont(name: "Montserrat-SemiBold", size: CGFloat(18)), .foregroundColor: UIColor.sectionHeaderColor]
        let heading = NSMutableAttributedString(string: "Note: ", attributes: headingAttributes)

        let detailsAttributes:[NSAttributedString.Key:Any] =
            [.font: UIFont(name: "Montserrat-Italic", size: CGFloat(18)),
             .foregroundColor: UIColor.sectionHeaderColor
        ]

        let details =
            NSMutableAttributedString(
                string: "You can edit your health profile any time from your Profile Settings",attributes: detailsAttributes)

        var noteContent: NSMutableAttributedString = NSMutableAttributedString()
        noteContent.append(heading)
        noteContent.append(details)

        noteLabel.attributedText = noteContent
    }

    func navigateForward() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setRootViewController()
    }
    
    @IBAction func onShowDashboard(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        appDelegate.setRootViewController()
    }

    @IBAction func handleBeginSurvey(_ sender: Any) {
        self.showSpinner()
        func onCreateSurveyCompletion(_ task: ORKOrderedTask?) {
            DispatchQueue.main.async {
                self.removeSpinner()
                if task != nil {
                    self.dismiss(animated: false) { [weak self] in
                        let taskViewController = SurveyViewController(task: task, isFirstTask: true)
                        NavigationUtility.presentOverCurrentContext(destination: taskViewController, style: .overCurrentContext)
                    }
                } else {
                    Alert(title: "Survey Not available",
                                   message: "No questions are found for the survey. Please try after sometime")
                    self.navigateForward()
                }
            }
        }
        func onCreateSurveyFailure(_ error: Error) {
            DispatchQueue.main.async {
                self.removeSpinner()
                self.navigateForward()
            }
        }
        
        SurveyTaskUtility.shared.createSurvey(surveyId: nil, completion: onCreateSurveyCompletion(_:),
                                              onFailure: onCreateSurveyFailure(_:))
    }
}

extension SetupCompleteVC: ORKTaskViewControllerDelegate {
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

        switch reason {
        case .completed:
            print("completed")
        case .discarded:
            print("discarded")
        case .failed:
            print("failed")
        case .saved:
            print("saved")
        @unknown default:
            print("unknown reason")
        }

        taskViewController.dismiss(animated: true) {
            [weak self] in
            self?.navigateForward()
            print("task view controller dismissed")
        }

    }

    func taskViewController(_ taskViewController: ORKTaskViewController,
                            viewControllerFor step: ORKStep) -> ORKStepViewController? {
        if step is ORKInstructionStep {
            if step is ORKCompletionStep {
                let stepVC = CompletionStepVC()
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
            }
            if questionStep.answerFormat is ORKContinuousScaleAnswerFormat {
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
