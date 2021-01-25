//
//  CheckinLogViewController.swift
//  Longevity
//
//  Created by vivek on 27/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

class CheckinLogViewController: BaseViewController {
    
    var history: [History]!
    
    lazy var checkinlognodataView: CheckInLogNoDataView = {
        let checkinlognodata = CheckInLogNoDataView()
        checkinlognodata.translatesAutoresizingMaskIntoConstraints = false
        return checkinlognodata
    }()

    lazy var logsCollectionView: UICollectionView = {
        let logsCollection = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        logsCollection.backgroundColor = .clear
        logsCollection.showsVerticalScrollIndicator = false
        logsCollection.delegate = self
        logsCollection.dataSource = self
        logsCollection.translatesAutoresizingMaskIntoConstraints = false
        return logsCollection
    }()
    
    lazy var closeButton: UIButton = {
        let close = UIButton()
        close.setImage(UIImage(named: "closex")?.withRenderingMode(.alwaysTemplate), for: .normal)
        close.setImage(UIImage(named: "closex")?.withRenderingMode(.alwaysTemplate), for: .highlighted)
        close.tintColor = .white
        close.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        close.translatesAutoresizingMaskIntoConstraints = false
        return close
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleView.titleLabel.text = "Results Data Log"
        
        self.titleView.addSubview(closeButton)
        self.view.addSubview(logsCollectionView)
        self.view.addSubview(checkinlognodataView)
        
        NSLayoutConstraint.activate([
            logsCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            logsCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            logsCollectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            logsCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 30.0),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
            closeButton.leadingAnchor.constraint(equalTo: self.titleView.leadingAnchor, constant: 20.0),
            closeButton.centerYAnchor.constraint(equalTo: self.titleView.titleLabel.centerYAnchor),
            
            checkinlognodataView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: CGFloat(self.headerHeight + 30.0)),
            checkinlognodataView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            checkinlognodataView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        
        guard let layout = logsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        layout.sectionInset = UIEdgeInsets(top: 20.0, left: 15.0, bottom: 20.0, right: 15.0)
        layout.minimumInteritemSpacing = 18
        layout.scrollDirection = .vertical
        layout.invalidateLayout()
        
        self.checkinlognodataView.checkinButton.addTarget(self, action: #selector(showSurvey), for: .touchUpInside)
        
        AppSyncManager.instance.userInsights.addAndNotify(observer: self) { [unowned self] in
            self.showSpinner()
            if let insights = AppSyncManager.instance.userInsights.value,
               let dataLog = insights.first(where: { $0.name == .logs }),
               let history = dataLog.details?.history {
                self.history = history
                self.updateLogHistory()
            } else {
                self.history = nil
                DispatchQueue.main.async {
                    self.removeSpinner()
                    self.logsCollectionView.reloadData()
                }
            }
        }
    }

    init() {
        super.init(viewTab: .myData)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        AppSyncManager.instance.userInsights.remove(observer: self)
    }

    func updateLogHistory() {
        if self.history != nil {
            let submissionIdList = history.map{ $0.submissionID }
            SurveysAPI.instance.surveySubmissionDetails(submissionIdList: submissionIdList) {
                [weak self] (response) in
                guard let response = response else {
                    self?.reloadLogData()
                    return
                }
                for index in 0..<(self?.history.count ?? 0) {
                    if let submissionID = self?.history[index].submissionID,
                       !submissionID.isEmpty,
                       let surveyName = response[submissionID]?.surveyName {
                        self?.history[index].surveyName = surveyName
                    }
                }
                self?.history.removeAll(where: { $0.surveyName == "Cough Test" })
                self?.reloadLogData()
            } onFailure: { [weak self] (error) in
                self?.reloadLogData()
            }
        } else {
            self.reloadLogData()
        }
    }
    
    fileprivate func reloadLogData() {
        DispatchQueue.main.async {
            self.removeSpinner()
            self.logsCollectionView.reloadData()
        }
    }
    
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func showSurvey() {
        self.showSpinner()

        func onCreateSurveyCompletion(_ task: ORKOrderedTask?) {
            DispatchQueue.main.async {
                self.removeSpinner()
                if task != nil {
                    self.navigationController?.navigationBar.barTintColor = .orange
                    self.navigationController?.navigationBar.backgroundColor = .black
//                    self.navigationItem.ba
                    self.dismiss(animated: false) { [weak self] in
                        let taskViewController = SurveyViewController(task: task, isFirstTask: true)
                        NavigationUtility.presentOverCurrentContext(destination: taskViewController, style: .overCurrentContext)
                    }
                } else {
                    Alert(title: "Survey Not available", message: "No questions are found for the survey. Please try after sometime")
                }
            }
        }
        func onCreateSurveyFailure(_ error: Error) {
            DispatchQueue.main.async {
                self.removeSpinner()
            }
        }
        
        SurveyTaskUtility.shared.createSurvey(surveyId: nil, completion: onCreateSurveyCompletion(_:),
                                              onFailure: onCreateSurveyFailure(_:))
    }
}

extension CheckinLogViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.history?.count ?? 0
        self.checkinlognodataView.isHidden = !(self.history?.isEmpty ?? true)
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.getSupplementaryView(with: CheckinLogHeader.self, viewForSupplementaryElementOfKind: kind, at: indexPath) as? CheckinLogHeader else {
            preconditionFailure("Invalid header")
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let sectionHeight = (self.history?.count ?? 0) > 0 ? 100.0 : 0.0
        return CGSize(width: collectionView.bounds.width, height: CGFloat(sectionHeight))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.getCell(with: CheckinLogCell.self, at: indexPath) as? CheckinLogCell else {
            preconditionFailure("Invalid log cell type")
        }
        
        if indexPath.item < (self.history.count ?? 0) {
            cell.history = self.history?[indexPath.item]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 30.0
        return CGSize(width: width, height: 92.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let cell = collectionView.cellForItem(at: indexPath) as? CheckinLogCell else {
            return
        }
        cell.onViewDetails()
    }
}
