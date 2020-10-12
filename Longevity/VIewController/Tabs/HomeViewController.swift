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
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor,
                                           constant: -UIApplication.shared.statusBarFrame.height * 2),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        
        SurveyTaskUtility.shared.repetitiveSurveyList.addAndNotify(observer: self) { [weak self] in
            DispatchQueue.main.async {
                self?.removeSpinner()
                self?.tableView.reloadData()
            }
        }
        
        SurveyTaskUtility.shared.oneTimeSurveyList.addAndNotify(observer: self) { [weak self] in
            DispatchQueue.main.async {
                self?.removeSpinner()
                self?.tableView.reloadData()
            }
        }
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
            return SurveyTaskUtility.shared.repetitiveSurveyList.value?.count ?? 0
        } else if section == 1 {
            return 1
        } else {
            if SurveyTaskUtility.shared.oneTimeSurveyList.value?.isEmpty ?? true {
                return 1
            } else {
                return SurveyTaskUtility.shared.oneTimeSurveyList.value?.count ?? 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let checkinCell = tableView.getCell(with: DashboardCheckInCell.self, at: indexPath) as? DashboardCheckInCell else {
                preconditionFailure("Invalid device cell")
            }
            checkinCell.surveyResponse = SurveyTaskUtility.shared.repetitiveSurveyList.value?[indexPath.row]
            checkinCell.isRepetitiveSurveyList = true
            return checkinCell
        }
        else if indexPath.section == 1 {
            guard let devicesCell = tableView.getCell(with: DashboardDevicesCell.self, at: indexPath) as? DashboardDevicesCell else {
                preconditionFailure("Invalid device cell")
            }
            devicesCell.delegate = self
            return devicesCell
        } else {
            if SurveyTaskUtility.shared.oneTimeSurveyList.value?.isEmpty ?? true {
                guard let completionCell = tableView.getCell(with: DashboardTaskCompletedCell.self, at: indexPath) as? DashboardTaskCompletedCell else {
                    preconditionFailure("Invalid completion cell")
                }
                return completionCell
            }
            guard let taskCell = tableView.getCell(with: DashboardTaskCell.self, at: indexPath) as? DashboardTaskCell else {
                preconditionFailure("Invalid device cell")
            }
            taskCell.surveyDetails = SurveyTaskUtility.shared.oneTimeSurveyList.value?[indexPath.row]

            return taskCell
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
            if SurveyTaskUtility.shared.oneTimeSurveyList.value?.isEmpty ?? true {
                return 100
            }
            if let surveyDetails = SurveyTaskUtility.shared.oneTimeSurveyList.value?[indexPath.row],
               let surveyId = surveyDetails.surveyId as? String,
               let details = SurveyTaskUtility.shared.surveyDetails[surveyId] as? SurveyDetails,
               let localAnswers = SurveyTaskUtility.shared.localSavedAnswers[surveyId] as? [String:String], !localAnswers.isEmpty {
                return 140.0
                }
            return 125.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            guard let headerView = tableView.getHeader(with: DashboardHeaderView.self, index: section) as? DashboardHeaderView else {
                preconditionFailure("Invalid header view")
            }
            return headerView
        } else {
            guard let headerView = tableView.getHeader(with: DashboardSectionHeader.self, index: section) as? DashboardSectionHeader else {
                preconditionFailure("Invalid header view")
            }
            headerView.headerType = HeaderType(rawValue: section) ?? .devices
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let selectedCell = tableView.cellForRow(at: indexPath) as? DashboardCheckInCell,
           let surveyId = selectedCell.surveyId
        {
            self.showSurvey(surveyId)
            return }

        if let taskCell = tableView.cellForRow(at: indexPath) as? DashboardTaskCell,
           let surveyId = taskCell.surveyDetails?.surveyId
        {
            self.showSurvey(surveyId)
            return
        }
    }
}

extension HomeViewController {
    func showSurvey(_ surveyId: String) {
        self.showSpinner()

        func onCreateSurveyCompletion(_ task: ORKOrderedTask?) {
            DispatchQueue.main.async {
                if task != nil {
                    let taskViewController = SurveyViewController(task: task, isFirstTask: true)
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
        SurveyTaskUtility.shared.createSurvey(surveyId: surveyId, completion: onCreateSurveyCompletion(_:),
                                              onFailure: onCreateSurveyFailure(_:))
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

extension HomeViewController:DashboardDevicesCellDelegate {
    func showError(forDeviceCollectionCell cell: DashboardDeviceCollectionCell) {
        DispatchQueue.main.async {
            self.showAlert(title: "Enable Notification", message: "Please enable device notifications to connect external devices")
        }
    }
}
