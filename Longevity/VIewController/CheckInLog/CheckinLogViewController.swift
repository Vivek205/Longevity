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
    
    var history: [History]! {
        didSet {
            DispatchQueue.main.async {self.updateLogDetails()}
            self.logsCollectionView.reloadData()
        }
    }
    
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
        self.titleView.titleLabel.text = "Check-in Log"
        
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
        
        self.checkinlognodataView.checkinButton.addTarget(self, action: #selector(showSurvey), for: .touchUpInside)
    }

    init() {
        super.init(viewTab: .myData)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateLogDetails() {
        self.showSpinner()
        let submissionIdList = history.map{$0.submissionID}
        print("submissionIdList", submissionIdList)
        SurveysAPI.instance.surveySubmissionDetails(submissionIdList: submissionIdList) {
            [weak self] (response) in
            DispatchQueue.main.async {self?.removeSpinner()}
            guard let response = response,let history = self?.history else {return}
            for index in 0..<history.count {
                if let surveyName = response[history[index].submissionID]?.surveyName {
                    self?.history[index].surveyName = surveyName
                }
            }
            print("submissionIdList response",response)
        } onFailure: { (error) in
            print("error", error)
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
        cell.history = self.history?[indexPath.item]
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
