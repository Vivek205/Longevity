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
    var surveyId: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveDataAndInitializeTheViews()
    }

    func retrieveDataAndInitializeTheViews() {
        self.showSpinner()

        func completion(_ surveys:[SurveyResponse]) {
            DispatchQueue.main.async {
                self.surveysData = surveys
                self.removeSpinner()
            }
        }

        func onFailure(_ error:Error) {
            DispatchQueue.main.async {
                self.removeSpinner()
            }

        }
        getSurveys(completion: completion(_:), onFailure: onFailure(_:))
    }

//    func presentViews() {
//        let scrollView = UIScrollView()
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.isDirectionalLockEnabled = true
//        self.view.addSubview(scrollView)
//
//        let navBarHeight = UIApplication.shared.statusBarFrame.size.height +
//            (navigationController?.navigationBar.frame.height ?? 0.0)
//        print(navBarHeight)
//
//        scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
//        scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
//        scrollView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: navBarHeight).isActive = true
//        scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
//
//        let stackView = UIStackView()
//        stackView.axis = .vertical
//        stackView.alignment = .fill
//        stackView.distribution = .equalSpacing
//        stackView.spacing = 10
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//
//        scrollView.addSubview(stackView)
//
//        if  self.surveysData != nil {
//            for survey in self.surveysData! {
//                let defaultAvatar = "https://image.freepik.com/free-vector/survey-report-checklist-questionnaire-business-illustration_114835-117.jpg"
//                let avatarURL = URL(string: survey.imageUrl ?? defaultAvatar)
//
//                if let lastSubmissionTimestamp = survey.lastSubmission as? String {
//                    let currentDate = Date()
//                    let dateFormatter = DateFormatter()
//                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//                    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
//                    if let lastSubmissionDate = dateFormatter.date(from: lastSubmissionTimestamp) {
//                        let daysElapsed = Calendar.current.dateComponents([.day], from: lastSubmissionDate)
//                        print("Days elapsed", daysElapsed, lastSubmissionDate)
//                    }
//                }
//
//                let surveyCardView = SurveyCardView(surveyId: survey.surveyId, avatarUrl: avatarURL,
//                                                    header: survey.name, content: survey.description,
//                                                    extraContent: "last submission date")
//                surveyCardView.translatesAutoresizingMaskIntoConstraints = false
//
//                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSurveyTapped(_:)))
//                surveyCardView.addGestureRecognizer(tapGesture)
//
//                stackView.addArrangedSubview(surveyCardView)
//                //                FIXME: Unable to set the height of the surveyCardView
//                surveyCardView.heightAnchor.constraint(equalToConstant: CGFloat(111)).isActive = true
//            }
//        }
//
//        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
//        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20).isActive = true
//        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20).isActive = true
//        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
//
//        stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -40).isActive = true
//    }

//    @objc func handleSurveyTapped(_ sender: UITapGestureRecognizer) {
//        let tappedSurvey = sender.view as! SurveyCardView
//        self.showSpinner()
//
//        func onCreateSurveyCompletion(_ task: ORKOrderedTask?) {
//            DispatchQueue.main.async {
//                if task != nil {
//                    let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
//                    taskViewController.delegate = self
////                    taskViewController.isNavigationBarHidden = true
//                    print("nav bar hidden", taskViewController.isNavigationBarHidden)
//                    self.present(taskViewController, animated: true, completion: nil)
//                } else {
//                    self.showAlert(title: "Survey Not available",
//                                   message: "No questions are found for the survey. Please try after sometime")
//                }
//                self.removeSpinner()
//            }
//        }
//
//        func onCreateSurveyFailure(_ error: Error) {
//            DispatchQueue.main.async {
//                self.removeSpinner()
//            }
//        }
//        self.surveyId = tappedSurvey.surveyId
//        let surveyTaskUtility = SurveyTaskUtility()
//        surveyTaskUtility.createSurvey(surveyId: tappedSurvey.surveyId!, completion: onCreateSurveyCompletion(_:),
//                     onFailure: onCreateSurveyFailure(_:))
//    }
}
//
//extension HomeVC:ORKTaskViewControllerDelegate {
//    func taskViewController(_ taskViewController: ORKTaskViewController,
//                            stepViewControllerWillAppear stepViewController: ORKStepViewController) {
//        let taskViewAppearance =
//            UIView.appearance(whenContainedInInstancesOf: [ORKTaskViewController.self])
//        taskViewAppearance.tintColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
//    }
//
//    func taskViewController(_ taskViewController: ORKTaskViewController,
//                            didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
//
//        func parseResult() {
//            var answersToSubmit: [SubmitAnswerPayload] = [SubmitAnswerPayload]()
//            if let stepResults = taskViewController.result.results as? [ORKStepResult] {
//                for stepResult in stepResults {
//                    if stepResult.identifier == "IntroStep" || stepResult.identifier == "SummaryStep" {
//                        print("skipped ", stepResult.identifier)
//                        continue
//                    }
//
//                    if SurveyTaskUtility.currentSurveyDetails != nil {
//                        let currentQuestion =
//                            SurveyTaskUtility.currentSurveyDetails!.questions.first { $0.quesId == stepResult.identifier }
//                        let latestStepResult = stepResult.results?.last
//                        if latestStepResult is ORKChoiceQuestionResult {
//                            let answer = (latestStepResult as! ORKChoiceQuestionResult).choiceAnswers?.first as! NSNumber
//                            print("answervalue", answer.intValue, answer.stringValue)
//                            let answerPaylaod = SubmitAnswerPayload(categoryId: currentQuestion!.categoryId,
//                                                                    moduleId: currentQuestion!.moduleId,
//                                                                    answer: answer.stringValue,
//                                                                    quesId: currentQuestion!.quesId)
//                            answersToSubmit += [answerPaylaod]
//                        }
//                    }
//                }
//                if self.surveyId != nil {
//                    saveSurveyAnswers(surveyId: self.surveyId!, answers: answersToSubmit)
//                }
//
//            }
//        }
//
//        print("reason", reason.rawValue)
//        switch reason {
//        case .completed:
//            parseResult()
//            print("completed")
//        case .discarded:
//            print("discarded")
//        case .failed:
//            print("failed")
//        case .saved:
//            print("saved")
//        @unknown default:
//            print("unknown reason")
//        }
//        print("error", error)
//        taskViewController.dismiss(animated: true) {
//            print("task view controller dismissed")
//        }
//
//    }
//
//    func taskViewController(_ taskViewController: ORKTaskViewController,
//                            viewControllerFor step: ORKStep) -> ORKStepViewController? {
//        print("step", step)
//        if step is ORKInstructionStep {
//            // Default View Controller will be used
//            return nil
//        } else if step is ORKFormStep {
//            return nil
//        } else {
////            let storyboard = UIStoryboard(name: "CovidCheckin", bundle: nil)
////            var stepVC:ORKStepViewController = ORKStepViewController()
////            stepVC = storyboard.instantiateViewController(withIdentifier: "TextChoiceAnswerVC")
////                as! ORKStepViewController
////
//            var stepVC = TextChoiceAnswerVC()
//            stepVC.step = step
//            return stepVC
//        }
//
//    }
//
//    func showConsent() {
//        let taskViewController = ORKTaskViewController(task: consentTask, taskRun: nil)
//        taskViewController.delegate = self
//        present(taskViewController, animated: true, completion: nil)
//    }
//}
//
//extension HomeVC: ORKTaskResultSource {
//    func stepResult(forStepIdentifier stepIdentifier: String) -> ORKStepResult? {
//        switch stepIdentifier {
//        case "TextChoiceQuestionStep":
//            let result = ORKChoiceQuestionResult(identifier: "TextChoiceQuestionStep")
//            let stepResult = ORKStepResult(stepIdentifier: "TextChoiceQuestionStep", results: [result])
//            return stepResult
//        default:
//            return ORKStepResult()
//        }
//    }
//}
