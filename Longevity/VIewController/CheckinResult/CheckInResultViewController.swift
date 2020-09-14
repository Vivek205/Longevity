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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let headerHeight = UIDevice.hasNotch ? 100.0 : 80.0
        self.view.backgroundColor = UIColor(hexString: "#F5F6FA")
        
        self.view.addSubview(checkInResultCollection)
        self.view.addSubview(titleView)
        
        NSLayoutConstraint.activate([titleView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                     titleView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                                     titleView.topAnchor.constraint(equalTo: self.view.topAnchor),
                                     titleView.heightAnchor.constraint(equalToConstant: CGFloat(headerHeight)),
                                     checkInResultCollection.topAnchor.constraint(equalTo: self.view.topAnchor),
                                     checkInResultCollection.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                     checkInResultCollection.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                                     checkInResultCollection.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        guard let layout = checkInResultCollection.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        layout.itemSize = CGSize(width: Double(self.view.bounds.width) - 20.0, height: 75.0)
        layout.sectionInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .vertical
        layout.invalidateLayout()
        
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
}

extension CheckInResultViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return (self.userInsights?.count ?? 0) + 1
        } else if section == 1 {
            return self.checkinResult?.insights.count ?? 0
        } else {
            return self.checkinResult?.goals.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
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
                return cell
            }
        } else if indexPath.section == 1 {
            guard let cell = collectionView.getCell(with: CheckInInsightCell.self, at: indexPath) as? CheckInInsightCell else {
                preconditionFailure("Invalid insight cell")
            }
            if let insight = self.checkinResult?.insights[indexPath.item] {
                cell.inSight = insight
            }
            return cell
        } else {
            guard let cell = collectionView.getCell(with: CheckInGoalCell.self, at: indexPath) as? CheckInGoalCell else {
                preconditionFailure("Invalid cell type")
            }
            if let goal = self.checkinResult?.goals[indexPath.item] {
                cell.setup(checkIngoal: goal, goalIndex: indexPath.item + 1)
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
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
        
        if indexPath.section == 0 {
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
            headerView.setup(comletedDate: "")
            return headerView
        } else if indexPath.section == 1 {
            guard let headerView = collectionView.getSupplementaryView(with: CheckInInsightsHeader.self, viewForSupplementaryElementOfKind: kind, at: indexPath) as? CheckInInsightsHeader else { preconditionFailure("Invalid header type") }
            return headerView
        } else {
            guard let headerView = collectionView.getSupplementaryView(with: CheckInNextGoals.self, viewForSupplementaryElementOfKind: kind, at: indexPath) as? CheckInNextGoals else { preconditionFailure("Invalid header type") }
            return headerView
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: collectionView.bounds.width, height: 120.0)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 40.0)
        }
    }
}
