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
    var currentTask: ORKOrderedTask?
    
    var isAIProcessPending: Bool = false {
        didSet {
            self.aiProcessingBand.isHidden = !isAIProcessPending
        }
    }
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.showsVerticalScrollIndicator = false
        table.alwaysBounceVertical = false
        table.backgroundColor = UIColor(hexString: "#F5F6FA")
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    lazy var aiProcessingBand: AIProgressBandView = {
        let processingband = AIProgressBandView()
        processingband.translatesAutoresizingMaskIntoConstraints = false
        return processingband
    }()
    
    init() {
        self.isAIProcessPending = false
        super.init(viewTab: .home)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(tableView)
        self.titleView.addSubview(aiProcessingBand)
        
        self.titleView.bgImageView.alpha = 0.0
        
        tableView.tableHeaderView = nil
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.bounces = false
        tableView.tableFooterView = UIView()

        self.navigationController?.navigationBar.barTintColor = .orange
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor,
                                           constant: -UIApplication.shared.statusBarFrame.height * 2),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            aiProcessingBand.leadingAnchor.constraint(equalTo: self.titleView.leadingAnchor),
            aiProcessingBand.trailingAnchor.constraint(equalTo: self.titleView.trailingAnchor),
            aiProcessingBand.heightAnchor.constraint(equalToConstant: 40.0),
            aiProcessingBand.bottomAnchor.constraint(equalTo: self.titleView.bottomAnchor, constant: -10.0)
        ])
        
        SurveyTaskUtility.shared.repetitiveSurveyList.addAndNotify(observer: self) { [weak self] in
            DispatchQueue.main.async {
                self?.removeSpinner()
                self?.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
            }
        }
        
        SurveyTaskUtility.shared.oneTimeSurveyList.addAndNotify(observer: self) { [weak self] in
            DispatchQueue.main.async {
                self?.removeSpinner()
                self?.tableView.reloadSections(IndexSet(integer: 2), with: .fade)
            }
        }

        self.aiProcessingBand.isHidden = !isAIProcessPending
        
        SurveyTaskUtility.shared.surveyInProgress.addAndNotify(observer: self) {
            DispatchQueue.main.async {
                self.aiProcessingBand.isHidden = SurveyTaskUtility.shared.surveyInProgress.value != .pending
            }
        }
        
        AppSyncManager.instance.syncSurveyList()
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
            let surveyResponse = SurveyTaskUtility.shared.repetitiveSurveyList.value?[indexPath.row]
            
            if surveyResponse?.lastSurveyStatus == .pending {
                self.isAIProcessPending = true
            }
            checkinCell.surveyResponse = surveyResponse
            return checkinCell
        } else if indexPath.section == 1 {
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
            let surveyDetails = SurveyTaskUtility.shared.oneTimeSurveyList.value?[indexPath.row]
            
            if surveyDetails?.lastSurveyStatus == .pending {
                self.isAIProcessPending = true
            }
            
            taskCell.surveyDetails = surveyDetails
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
            return 140.0
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
            //If Survey is submitted today and is under processing
//            if selectedCell.status == .pending && selectedCell.isSurveySubmittedToday {
//                return
//            } else if selectedCell.status == .completedToday { //If survey is completed today
//                let checkInResultViewController = CheckInResultViewController()
//                NavigationUtility.presentOverCurrentContext(destination: checkInResultViewController,
//                                                            style: .overCurrentContext)
//                return
//            } else if selectedCell.status != .completedToday { //If not submitted today / ever
                self.showSurvey(surveyId)
//                return
//            }
        }

        if let taskCell = tableView.cellForRow(at: indexPath) as? DashboardTaskCell,
           let surveyId = taskCell.surveyDetails?.surveyId
        {
            self.showSurvey(surveyId)
            return
        }
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let topGap = 44.0 + scrollView.contentOffset.y
        self.titleView.bgImageView.alpha = topGap > 1 ? 1 : topGap
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
                   Alert(title: "Survey Not available",
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
            Alert(title: "Enable Notification", message: "Please enable device notifications to connect external devices")
        }
    }
}
