//
//  HomeVC.swift
//  Longevity
//
//  Created by vivek on 20/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

class HomeVC: UIViewController {
    var surveysData: [SurveyResponse]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveDataAndInitializeTheViews()
    }

//    @IBAction func handleCovidCheckinPressed(_ sender: Any) {
//        showCovidCheckinSurvey()
//    }
//
//    @IBAction func handleBranchedTaskPressed(_ sender: Any) {
//    }

    func retrieveDataAndInitializeTheViews() {
        self.showSpinner()

        func completion(_ surveys:[SurveyResponse])->Void {
            DispatchQueue.main.async {
                print(surveys)
                self.surveysData = surveys
                self.presentViews()
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

    func presentViews() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isDirectionalLockEnabled = true
        self.view.addSubview(scrollView)

        scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(stackView)

        if  self.surveysData != nil {
            for survey in self.surveysData! {
                let avatarURL = URL(string: survey.imageUrl)
                let surveyCardView = SurveyCardView(avatarUrl: avatarURL, header: survey.name, content: survey.description, extraContent: "last submission date")
                surveyCardView.translatesAutoresizingMaskIntoConstraints = false

                stackView.addArrangedSubview(surveyCardView)
//                FIXME: Unable to set the height of the surveyCardView
//                surveyCardView.heightAnchor.constraint(equalToConstant: CGFloat(111)).isActive = true

            }
        }

        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true

        stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -40).isActive = true
    }

}

extension HomeVC:ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        let taskViewAppearance = UIView.appearance(whenContainedInInstancesOf: [ORKTaskViewController.self])
        taskViewAppearance.tintColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
    }

    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        taskViewController.dismiss(animated: true) {
            print("task view controller dismissed", taskViewController.result)
        }

    }

    func taskViewController(_ taskViewController: ORKTaskViewController, viewControllerFor step: ORKStep) -> ORKStepViewController? {
        print("step", step)
        if step is ORKInstructionStep {
            // Default View Controller will be used
            return nil
        }else {
            let storyboard = UIStoryboard(name: "CovidCheckin", bundle: nil)
            var stepVC:ORKStepViewController = ORKStepViewController()
            stepVC = storyboard.instantiateViewController(withIdentifier: "TextChoiceAnswerVC") as! ORKStepViewController
            stepVC.step = step
            return stepVC
        }

    }

    func showConsent() {
        let taskViewController = ORKTaskViewController(task: consentTask, taskRun: nil)
        taskViewController.delegate = self
        present(taskViewController, animated: true, completion: nil)
    }

    func showCovidCheckinSurvey() {
        self.showSpinner()
        let covidCheckinSurveyTask = createCovidCheckinSurveyTask()
        self.removeSpinner()
        let taskViewController = ORKTaskViewController(task: covidCheckinSurveyTask, taskRun: nil)
        taskViewController.delegate = self
        present(taskViewController, animated: true, completion: nil)
    }
}

extension HomeVC: ORKTaskResultSource {
    func stepResult(forStepIdentifier stepIdentifier: String) -> ORKStepResult? {
        switch stepIdentifier {
        case "TextChoiceQuestionStep":
            let result = ORKChoiceQuestionResult(identifier: "TextChoiceQuestionStep")
            let stepResult = ORKStepResult(stepIdentifier: "TextChoiceQuestionStep", results: [result])
            return stepResult
        default:
            return ORKStepResult()
        }
    }
}
