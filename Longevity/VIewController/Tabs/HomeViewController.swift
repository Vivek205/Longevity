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

    var isAIProcessPending: Bool = false {
        didSet {
            self.aiProcessingBand.isHidden = !isAIProcessPending
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let collectionview = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionview.alwaysBounceVertical = false
        collectionview.showsVerticalScrollIndicator = false
        collectionview.showsHorizontalScrollIndicator = false
        collectionview.backgroundColor = UIColor(hexString: "#F5F6FA")
        collectionview.translatesAutoresizingMaskIntoConstraints = false
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.isScrollEnabled = true
        return collectionview
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
        
        self.view.addSubview(collectionView)
        self.titleView.addSubview(aiProcessingBand)
        
        self.titleView.bgImageView.alpha = 0.0

        self.navigationController?.navigationBar.barTintColor = .orange
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor,
                                           constant: -UIApplication.shared.statusBarFrame.height),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            aiProcessingBand.leadingAnchor.constraint(equalTo: self.titleView.leadingAnchor),
            aiProcessingBand.trailingAnchor.constraint(equalTo: self.titleView.trailingAnchor),
            aiProcessingBand.heightAnchor.constraint(equalToConstant: 40.0),
            aiProcessingBand.bottomAnchor.constraint(equalTo: self.titleView.bottomAnchor, constant: -10.0)
        ])
        
        SurveyTaskUtility.shared.repetitiveSurveyList.addAndNotify(observer: self) { [unowned self] in
            DispatchQueue.main.async {
                self.removeSpinner()
                self.collectionView.reloadSections([0])
            }
        }
        
        SurveyTaskUtility.shared.oneTimeSurveyList.addAndNotify(observer: self) { [unowned self] in
            DispatchQueue.main.async {
                self.removeSpinner()
                self.collectionView.reloadSections([2])
            }
        }

        self.aiProcessingBand.isHidden = !isAIProcessPending
        
        SurveyTaskUtility.shared.surveyInProgress.addAndNotify(observer: self) { [unowned self] in
            DispatchQueue.main.async {
                let status = SurveyTaskUtility.shared.containsInprogress()
                self.aiProcessingBand.isHidden = !status
                if !status {
                    AppSyncManager.instance.syncUserInsights()
                }
            }
        }
        
        AppSyncManager.instance.syncSurveyList()
        
        guard let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        layout.itemSize = CGSize(width: Double(self.view.bounds.width) - 20.0, height: 75.0)
        layout.sectionInset = UIEdgeInsets(top: 2.0, left: 0.0, bottom: 10.0, right: 0.0)
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .vertical
        layout.invalidateLayout()
    }
    
    deinit {
        SurveyTaskUtility.shared.repetitiveSurveyList.remove(observer: self)
        SurveyTaskUtility.shared.oneTimeSurveyList.remove(observer: self)
        SurveyTaskUtility.shared.surveyInProgress.remove(observer: self)
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            let count = SurveyTaskUtility.shared.repetitiveSurveyList.value?.count ?? 0
            return count
        } else if section == 1 {
            return 1
        } else {
            let count = SurveyTaskUtility.shared.oneTimeSurveyList.value?.count ?? 0
            return count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let checkinCell = collectionView.getUniqueCell(with: DashboardCheckInCell.self,
                                                                 at: indexPath) as? DashboardCheckInCell else {
                preconditionFailure("Invalid device cell")
            }
            if let surveyResponse = SurveyTaskUtility.shared.repetitiveSurveyList.value?[indexPath.row] {
                checkinCell.surveyResponse = surveyResponse
            }
            return checkinCell
        } else if indexPath.section == 1 {
            guard let devicesCell = collectionView.getCell(with: DashboardDevicesCell.self,
                                                           at: indexPath) as? DashboardDevicesCell else {
                preconditionFailure("Invalid device cell")
            }
            devicesCell.delegate = self
            return devicesCell
        } else {
            guard let taskCell = collectionView.getCell(with: DashboardTaskCell.self,
                                                        at: indexPath) as? DashboardTaskCell else {
                preconditionFailure("Invalid device cell")
            }
            if let surveyDetails = SurveyTaskUtility.shared.oneTimeSurveyList.value?[indexPath.row] {
                taskCell.surveyDetails = surveyDetails
            }
            return taskCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedCell = collectionView.cellForItem(at: indexPath) as? DashboardCheckInCell
           {
            //If Survey is submitted today and is under processing
            if selectedCell.status == .pending && selectedCell.isSurveySubmittedToday {
                return
            } else if selectedCell.status == .completedToday { //If survey is completed today
                guard let submissionID = selectedCell.submissionID else { return }
                let checkInResultViewController = CheckInResultViewController(submissionID: submissionID)
                NavigationUtility.presentOverCurrentContext(destination: checkInResultViewController,
                                                            style: .overCurrentContext)
                return
            } else if selectedCell.status != .completedToday { //If not submitted today / ever
                guard let surveyID = selectedCell.surveyId else { return }
                self.showSurvey(surveyID)
                return
            }
        }
        
        if let taskCell = collectionView.cellForItem(at: indexPath) as? DashboardTaskCell
        {
            guard let surveyDetails = SurveyTaskUtility.shared.oneTimeSurveyList.value?[indexPath.row] else { return }
            if surveyDetails.lastSurveyStatus == .pending {
                return
            } else if surveyDetails.lastSurveyStatus == .completed {
                guard let submissionID = surveyDetails.lastSubmissionId else { return }
                let checkInResultViewController = CheckInResultViewController(submissionID: submissionID,
                                                                              surveyName: surveyDetails.name,
                                                                              isCheckIn: false)
                NavigationUtility.presentOverCurrentContext(destination: checkInResultViewController,
                                                            style: .overCurrentContext)
                return
            } else {
                guard let surveyId = taskCell.surveyDetails?.surveyId else { return }
                self.showSurvey(surveyId)
                return
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: collectionView.bounds.width - 20.0, height: 100.0)
        } else if indexPath.section == 1 {
            return CGSize(width: collectionView.bounds.width, height: 170.0)
        } else if SurveyTaskUtility.shared.oneTimeSurveyList.value?[indexPath.row].lastSurveyStatus == .completed ||
                    SurveyTaskUtility.shared.oneTimeSurveyList.value?[indexPath.row].lastSurveyStatus == .pending {
            return CGSize(width: collectionView.bounds.width - 20.0, height: 90.0)
        } else {
            return CGSize(width: collectionView.bounds.width - 20.0, height: 120.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            let heightFactor: CGFloat = UIDevice.hasNotch ? 0.50 : 0.58
            let height = collectionView.bounds.height * heightFactor
            return CGSize(width: collectionView.bounds.width, height: height)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 40.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 {
            guard let headerView = collectionView.getSupplementaryView(with: DashboardHeaderView.self, viewForSupplementaryElementOfKind: kind, at: indexPath) as? DashboardHeaderView else {
                preconditionFailure("Invalid header view")
            }
            return headerView
        } else {
            guard let headerView = collectionView.getSupplementaryView(with: DashboardSectionHeader.self, viewForSupplementaryElementOfKind: kind, at: indexPath) as? DashboardSectionHeader else {
                preconditionFailure("Invalid header view")
            }
            headerView.headerType = HeaderType(rawValue: indexPath.section) ?? .devices
            return headerView
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let topY = -UIApplication.shared.statusBarFrame.height
        if scrollView.contentOffset.y < topY {
            scrollView.contentOffset.y = topY
        }
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
                    NavigationUtility.presentOverCurrentContext(destination: taskViewController,
                                                                style: .overCurrentContext)
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

extension HomeViewController:DashboardDevicesCellDelegate {
    func showError(forDeviceCollectionCell cell: DashboardDeviceCollectionCell) {
        DispatchQueue.main.async {
            Alert(title: "Enable Notification",
                  message: "Please enable device notifications to connect external devices")
        }
    }
}
