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
    var surveyList: [SurveyResponse]?
    var currentTask: ORKOrderedTask?
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.showsVerticalScrollIndicator = false
        table.alwaysBounceVertical = false
        table.backgroundColor = .clear
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
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: CGFloat(self.headerHeight)),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }

    func getSurveyList() {
        self.showSpinner()

        func completion(_ surveys:[SurveyResponse]) {
            DispatchQueue.main.async {
                self.surveyList = surveys
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
            if surveyList != nil {
                return self.surveyList!.count
            }
            return 0
        }
        if section == 1 {
            return 1
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let checkinCell = tableView.getCell(with: DashboardCheckInCell.self, at: indexPath) as? DashboardCheckInCell else {
                preconditionFailure("Invalid device cell")
            }
            print("row", indexPath.row)
            return checkinCell
        }
        else if indexPath.section == 1 {
            guard let devicesCell = tableView.getCell(with: DashboardDevicesCell.self, at: indexPath) as? DashboardDevicesCell else {
                preconditionFailure("Invalid device cell")
            }
            return devicesCell
        } else {
            guard let cell = tableView.getCell(with: DashboardTaskCell.self, at: indexPath) as? DashboardTaskCell else {
                preconditionFailure("Invalid task cell")
            }
            return cell
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
        guard let headerView = tableView.getHeader(with: UITableViewHeaderFooterView.self, index: section) else {
            preconditionFailure("Invalid header view")
        }
        headerView.backgroundColor = .lightGray
        
        var header: UIView = UIView()
        
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
        if selectedCell is DashboardCheckInCell{
            self.showSurvey(selectedCell)
        }
    }
}

extension HomeViewController {
    func showSurvey(_ selectedSurveyCell: Any) {
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
                    self.present(taskViewController, animated: true, completion: nil)
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
        let surveyTaskUtility = SurveyTaskUtility()
        surveyTaskUtility.createSurvey(surveyId: "COVID_CHECK_IN_001", completion: onCreateSurveyCompletion(_:),
                     onFailure: onCreateSurveyFailure(_:))
    }
}

extension HomeViewController: ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController,
                            stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        let taskViewAppearance =
            UIView.appearance(whenContainedInInstancesOf: [ORKTaskViewController.self])
        taskViewAppearance.tintColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
    }

    func taskViewController(_ taskViewController: ORKTaskViewController,
                            didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        let surveyTaskUtility = SurveyTaskUtility()

        switch reason {
        case .completed:
            surveyTaskUtility.clearSurvey()
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
            let stepVC = TextChoiceAnswerVC()
            stepVC.step = step
            return stepVC
        }
        return nil
    }

    func showConsent() {
        let taskViewController = ORKTaskViewController(task: consentTask, taskRun: nil)
        taskViewController.delegate = self
        present(taskViewController, animated: true, completion: nil)
    }
}

extension HomeViewController: ORKTaskResultSource {
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

