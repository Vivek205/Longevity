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
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeBackButtonNavigation()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Do any additional setup after loading the view.
//        styleNavigationBar()
    }

    func navigateForward() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setRootViewController()
    }
    
    @IBAction func onShowDashboard(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setRootViewController()
    }

    @IBAction func handleBeginSurvey(_ sender: Any) {
        self.showSpinner()
//        SurveyTaskUtility.shared.createSurvey(surveyId: "COVID_CHECK_IN_01", completion: { [weak self] (task) in
//            guard let task = task else {
//                self?.removeSpinner()
//                self?.navigateForward()
//                return }
//            DispatchQueue.main.async {
//                let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
//                taskViewController.delegate = self
//                taskViewController.navigationBar.backgroundColor = .white
//                taskViewController.navigationBar.barTintColor = .white
//                taskViewController.view.backgroundColor = .white
//                self?.removeSpinner()
//                NavigationUtility.presentOverCurrentContext(destination: taskViewController, style: .overCurrentContext)
//            }
//        }) { (error) in
//            self.removeSpinner()
//            self.navigateForward()
//        }
        
        
        func onCreateSurveyCompletion(_ task: ORKOrderedTask?) {
            DispatchQueue.main.async {
                self.removeSpinner()
                if task != nil {
                    self.dismiss(animated: false) { [weak self] in
                        let taskViewController = SurveyViewController(task: task, isFirstTask: true)
                        NavigationUtility.presentOverCurrentContext(destination: taskViewController, style: .overCurrentContext)
                    }
                } else {
                    self.showAlert(title: "Survey Not available",
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

extension SetupCompleteVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SetupProfileCompleteCell", for: indexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 30.0
        return CGSize(width: width, height: collectionView.bounds.height)
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
//            self.getSurveyList()
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
