//
//  HomeViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 06/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

class HomeViewController: BaseViewController {
    var surveyId: String?
    //    var surveyList: [SurveyListItem]?
    var currentTask: ORKOrderedTask?
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.showsVerticalScrollIndicator = false
        table.alwaysBounceVertical = false
        table.backgroundColor = UIColor(hexString: "#F5F6FA")
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    init() {
        super.init(viewTab: .home)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getSurveyList()
        self.view.addSubview(tableView)
        
        tableView.tableHeaderView = nil
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -UIApplication.shared.statusBarFrame.height * 2),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }

    func getSurveyList() {
        self.showSpinner()

        func completion(_ surveys:[SurveyListItem]) {
            DispatchQueue.main.async {
                self.tableView.reloadData()
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
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            let count = SurveyTaskUtility.shared.repetitiveSurveyList.count
            return count
        }
        if section == 1 {
            return 1
        }
        return SurveyTaskUtility.shared.oneTimeSurveyList.isEmpty ? 1 : SurveyTaskUtility.shared.oneTimeSurveyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let checkinCell = tableView.getCell(with: DashboardCheckInCell.self, at: indexPath) as? DashboardCheckInCell else {
                preconditionFailure("Invalid device cell")
            }
            
            checkinCell.surveyResponse = SurveyTaskUtility.shared.repetitiveSurveyList[indexPath.row]
            
            return checkinCell
        }
        else if indexPath.section == 1 {
            guard let devicesCell = tableView.getCell(with: DashboardDevicesCell.self, at: indexPath) as? DashboardDevicesCell else {
                preconditionFailure("Invalid device cell")
            }
            return devicesCell
        } else {
            if SurveyTaskUtility.shared.oneTimeSurveyList.isEmpty {
                guard let completionCell = tableView.getCell(with: DashboardTaskCompletedCell.self, at: indexPath) as? DashboardTaskCompletedCell else {
                    preconditionFailure("Invalid completion cell")
                }
                return completionCell
            }
            guard let checkinCell = tableView.getCell(with: DashboardCheckInCell.self, at: indexPath) as? DashboardCheckInCell else {
                preconditionFailure("Invalid device cell")
            }


            checkinCell.surveyResponse = SurveyTaskUtility.shared.oneTimeSurveyList[indexPath.row]
            return checkinCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            let heightFactor: CGFloat = UIDevice.hasNotch ? 0.50 : 0.60
            let height = tableView.bounds.height * heightFactor
            return height
        } else {
            return 40.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 120.0
        } else if indexPath.section == 1 {
            return 170.0
        } else {
            return 140.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.getHeader(with: HomeViewHeader.self, index: section) else {
            preconditionFailure("Invalid header view")
        }
        
        var header = UIView()
        if section == 0 {
            header = DashboardHeaderView()
        } else {
            header = DashboardSectionHeader(section: section)
        }
        header.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(header)
        
        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            header.topAnchor.constraint(equalTo: headerView.topAnchor),
            header.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCell = tableView.cellForRow(at: indexPath)
        if let dashboardCheckInCell = selectedCell as? DashboardCheckInCell {
            self.showSurvey(dashboardCheckInCell)
        }
    }
}

extension HomeViewController {
    func showSurvey(_ selectedSurveyCell: DashboardCheckInCell) {
        self.showSpinner()

        func onCreateSurveyCompletion(_ task: ORKOrderedTask?) {
            DispatchQueue.main.async {
                if task != nil {
                    let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
                    self.currentTask = task
                    taskViewController.delegate = self
                    taskViewController.navigationBar.backgroundColor = .white
                    taskViewController.navigationBar.barTintColor = .white
                    taskViewController.view.backgroundColor = .white
                    NavigationUtility.presentOverCurrentContext(destination: taskViewController, style: .overCurrentContext)
                } else {
                    self.showAlert(title: "Survey Not available",
                                   message: "No questions are found for the survey. Please try after sometime")
                }
                self.removeSpinner()
            }
        }
        func onCreateSurveyFailure(_ error: Error) {
            DispatchQueue.main.async {
                self.removeSpinner()
            }
        }
        SurveyTaskUtility.shared.createSurvey(surveyId: selectedSurveyCell.surveyId, completion: onCreateSurveyCompletion(_:),
                                              onFailure: onCreateSurveyFailure(_:))
    }
}

extension HomeViewController: ORKTaskViewControllerDelegate {
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

        taskViewController.dismiss(animated: true) {
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

class HomeViewHeader: UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "#F5F6FA")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
