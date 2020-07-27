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

    override func viewDidLoad() {
        super.viewDidLoad()
        customizeResearchKit()
        // Do any additional setup after loading the view.
    }

    @IBAction func handleCovidCheckinPressed(_ sender: Any) {
        showCovidCheckinSurvey()
    }

    @IBAction func handleBranchedTaskPressed(_ sender: Any) {
    }


    func customizeResearchKit() {
        //        ORKTaskViewController().
        //        ORKStepViewController.init().continueButtonItem?.customView?.backgroundColor = UIColor.red
    }
    
}

extension HomeVC:ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        let taskViewAppearance = UIView.appearance(whenContainedInInstancesOf: [ORKTaskViewController.self])
        taskViewAppearance.tintColor = UIColor.red
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
