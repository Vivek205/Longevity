//
//  CheckInResultViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 06/09/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CheckInResultViewController: UIViewController {
    var isCellExpanded: [Int:Bool] = [Int:Bool]()
    
    var userInsights: [UserInsight]? {
        didSet {
            DispatchQueue.main.async {
                self.checkInResultCollection.reloadData()
            }
        }
    }
    
    var checkinResult: History? {
        didSet {
            DispatchQueue.main.async {
                self.checkInResultCollection.reloadData()
            }
        }
    }
    
    var isSymptomsExpanded: Bool = false
    
    var currentResultView: CheckInResultView! {
        didSet {
            self.checkInResultCollection.reloadData()
        }
    }
    
    lazy var titleView: CheckInTitleView = {
        let title = CheckInTitleView()
        title.closeButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    lazy var checkInResultCollection: UICollectionView = {
        let resultCollection = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        resultCollection.backgroundColor = .clear
        resultCollection.showsVerticalScrollIndicator = false
        resultCollection.delegate = self
        resultCollection.dataSource = self
        resultCollection.translatesAutoresizingMaskIntoConstraints = false
        return resultCollection
    }()
    
    lazy var closeViewPanel: UIView = {
        let closePanel = UIView()
        closePanel.backgroundColor = .white
        closePanel.translatesAutoresizingMaskIntoConstraints = false
        
        let closeButton = UIButton()
        closeButton.setTitle("Done", for: .normal)
        closeButton.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 24.0)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = .themeColor
        closeButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        let logButton = UIButton()
        logButton.setTitle("Check-in Log", for: .normal)
        logButton.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 24.0)
        logButton.setTitleColor(.themeColor, for: .normal)
        logButton.backgroundColor = .clear
        logButton.addTarget(self, action: #selector(showLogs), for: .touchUpInside)
        logButton.translatesAutoresizingMaskIntoConstraints = false
        
        closePanel.addSubview(closeButton)
        closePanel.addSubview(logButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: closePanel.topAnchor, constant: 22.0),
            closeButton.leadingAnchor.constraint(equalTo: closePanel.leadingAnchor, constant: 15.0),
            closeButton.trailingAnchor.constraint(equalTo: closePanel.trailingAnchor, constant: -15.0),
            closeButton.heightAnchor.constraint(equalToConstant: 48.0),
            logButton.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 24.0),
            logButton.leadingAnchor.constraint(equalTo: closePanel.leadingAnchor, constant: 15.0),
            logButton.trailingAnchor.constraint(equalTo: closePanel.trailingAnchor, constant: -15.0),
            logButton.heightAnchor.constraint(equalToConstant: 48.0)
        ])
        
        closeButton.layer.cornerRadius = 10.0
        closeButton.layer.masksToBounds = true
        
        logButton.layer.cornerRadius = 10.0
        logButton.layer.borderWidth = 1.5
        logButton.layer.borderColor = UIColor.themeColor.cgColor
        logButton.layer.masksToBounds = true
        
        return closePanel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let headerHeight = UIDevice.hasNotch ? 100.0 : 80.0
        self.view.backgroundColor = UIColor(hexString: "#F5F6FA")
        
        self.view.addSubview(checkInResultCollection)
        self.view.addSubview(titleView)
        self.view.addSubview(closeViewPanel)
        
        NSLayoutConstraint.activate([titleView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                     titleView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                                     titleView.topAnchor.constraint(equalTo: self.view.topAnchor),
                                     titleView.heightAnchor.constraint(equalToConstant: CGFloat(headerHeight)),
                                     checkInResultCollection.topAnchor.constraint(equalTo: self.view.topAnchor),
                                     checkInResultCollection.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                     checkInResultCollection.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                                    closeViewPanel.topAnchor.constraint(equalTo: checkInResultCollection.bottomAnchor),
                                     closeViewPanel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                     closeViewPanel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                                     closeViewPanel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                                     closeViewPanel.heightAnchor.constraint(equalToConstant: 200.0)
        ])
        
        guard let layout = checkInResultCollection.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        layout.itemSize = CGSize(width: Double(self.view.bounds.width) - 20.0, height: 75.0)
        layout.sectionInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .vertical
        layout.invalidateLayout()
        
        self.currentResultView = .analysis
        
        AppSyncManager.instance.userInsights.addAndNotify(observer: self) { [weak self] in
            self?.userInsights = AppSyncManager.instance.userInsights.value?.filter({ $0.name != .logs })
            if  let result  = AppSyncManager.instance.userInsights.value?.filter({ $0.name == .logs }), !result.isEmpty {
                self?.checkinResult = result[0].details?.history?[0]
            }
        }
        AppSyncManager.instance.syncUserInsights()
    }
    
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func showLogs() {
        if let history = AppSyncManager.instance.userInsights.value?.first(where: { $0.name == .logs })?.details?.history {
            let checkinLogViewController: CheckinLogViewController = CheckinLogViewController()
            checkinLogViewController.history = history
            NavigationUtility.presentOverCurrentContext(destination: checkinLogViewController, style: .overCurrentContext)
        }
    }
}

extension CheckInResultViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if self.currentResultView == .analysis {
            return 1
        } else {
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 && self.currentResultView == .analysis {
            return (self.userInsights?.count ?? 0) + 1
        } else if section == 1 {
            return self.checkinResult?.goals.count ?? 0
        } else {
            return self.checkinResult?.insights.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 && self.currentResultView == .analysis {
            if indexPath.item < (self.userInsights?.count ?? 0) {
                guard let cell = collectionView.getCell(with: MyDataInsightCell.self, at: indexPath) as? MyDataInsightCell else {
                    preconditionFailure("Invalid insight cell")
                }
                cell.insightData = self.userInsights?[indexPath.item]
                return cell
            } else {
                guard let cell = collectionView.getCell(with: RecordedSymptomsCell.self, at: indexPath) as? RecordedSymptomsCell else {
                    preconditionFailure("Invalid insight cell")
                }
                if let symptoms = self.checkinResult?.symptoms {
                    cell.symptoms = symptoms
                }
                cell.isCellExpanded = self.isSymptomsExpanded
                return cell
            }
        } else if indexPath.section == 1 {
            guard let cell = collectionView.getCell(with: CheckInGoalCell.self, at: indexPath) as? CheckInGoalCell else {
                preconditionFailure("Invalid cell type")
            }
            if let goal = self.checkinResult?.goals[indexPath.item] {
                cell.setup(checkIngoal: goal, goalIndex: indexPath.item + 1)
            }
            return cell
        } else {
            guard let cell = collectionView.getCell(with: CheckInInsightCell.self, at: indexPath) as? CheckInInsightCell else {
                preconditionFailure("Invalid insight cell")
            }
            if let insight = self.checkinResult?.insights[indexPath.item] {
                cell.inSight = insight
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 && self.currentResultView == .analysis {
            if indexPath.item < (self.userInsights?.count ?? 0) {
                guard let insightData = self.userInsights?[indexPath.item] else { return }
                self.userInsights?[indexPath.item].isExpanded = !(insightData.isExpanded ?? false)
            } else {
                self.isSymptomsExpanded = !self.isSymptomsExpanded
                collectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = CGFloat(collectionView.bounds.width) - 20.0
        var height: CGFloat = 80.0
        
        if indexPath.section == 0 && self.currentResultView == .analysis {
            if indexPath.item < (self.userInsights?.count ?? 0) {
                guard let insightData = self.userInsights?[indexPath.item] else { return CGSize(width: width, height: height) }
                
                if (insightData.isExpanded ?? false) {
                    height = 430.0
                }
            } else {
                if isSymptomsExpanded {
                    height = 430.0
                }
            }
        }
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 {
            guard let headerView = collectionView.getSupplementaryView(with: CheckInResultHeader.self, viewForSupplementaryElementOfKind: kind, at: indexPath) as? CheckInResultHeader else { preconditionFailure("Invalid header type") }
            
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd"
            var recoredDate = ""
            if let datestring = checkinResult?.recordDate, !datestring.isEmpty, let date = dateformatter.date(from: datestring) {
                dateformatter.dateFormat = "EEE.MMM.dd"
                recoredDate = dateformatter.string(from: date)
            }
            headerView.setup(comletedDate: recoredDate)
            headerView.currentView = self.currentResultView
            headerView.delegate = self
            return headerView
        } else {
            guard let headerView = collectionView.getSupplementaryView(with: CheckInNextGoals.self, viewForSupplementaryElementOfKind: kind, at: indexPath) as? CheckInNextGoals else { preconditionFailure("Invalid header type") }
            return headerView
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: collectionView.bounds.width, height: 225.0)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 40.0)
        }
    }
}

extension CheckInResultViewController: CheckInResultHeaderDelegate {
    func selected(resultView: CheckInResultView) {
        self.currentResultView = resultView
    }
}
