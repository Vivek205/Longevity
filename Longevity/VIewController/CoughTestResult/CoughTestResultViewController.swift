//
//  CoughTestResultViewController.swift
//  COVID Signals
//
//  Created by Jagan Kumar Mudila on 19/02/2021.
//  Copyright © 2021 vivek. All rights reserved.
//

import UIKit

class CoughTestResultViewController: UIViewController {
    
    var submissionID: String = ""
    var isCheckInResult: Bool = true
    var surveyName: String = ""
    
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
                self.removeSpinner()
            }
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
        closeButton.titleLabel?.font = UIFont(name: AppFontName.medium, size: 24.0)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = .themeColor
        closeButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closePanel.addSubview(closeButton)
        
        let checkInLogHeight: CGFloat = self.isCheckInResult ? 48.0 : 0.0
        let bottomMargin: CGFloat = UIDevice.hasNotch ? -54.0 : -30.0
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: closePanel.topAnchor, constant: 22.0),
            closeButton.leadingAnchor.constraint(equalTo: closePanel.leadingAnchor, constant: 15.0),
            closeButton.trailingAnchor.constraint(equalTo: closePanel.trailingAnchor, constant: -15.0),
            closeButton.heightAnchor.constraint(equalToConstant: 48.0),
       ])
        
        closeButton.layer.cornerRadius = 10.0
        closeButton.layer.masksToBounds = true
        
        return closePanel
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
        
    init(submissionID: String, surveyName: String = "", isCheckIn: Bool = true) {
        super.init(nibName: nil, bundle: nil)
        self.submissionID = submissionID
        self.surveyName = surveyName
        self.isCheckInResult = isCheckIn
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let headerHeight = UIDevice.hasNotch ? 100.0 : 80.0
        
        self.titleView.bgImageView.alpha = 0.0
        
        self.view.backgroundColor = UIColor(hexString: "#F5F6FA")
        
        self.view.addSubview(checkInResultCollection)
        self.view.addSubview(titleView)
        self.view.addSubview(closeViewPanel)

        let window = UIApplication.shared.keyWindow
        let safeAreaBottomInset = window?.safeAreaInsets.bottom ?? 0
        let closeViewPanelHeight = 100 + safeAreaBottomInset
        
        NSLayoutConstraint.activate([titleView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                     titleView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                                     titleView.topAnchor.constraint(equalTo: self.view.topAnchor),
                                     titleView.heightAnchor.constraint(equalToConstant: CGFloat(headerHeight)),
                                     checkInResultCollection.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -UIApplication.shared.statusBarFrame.height),
                                     checkInResultCollection.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                     checkInResultCollection.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                                     checkInResultCollection.bottomAnchor.constraint(equalTo: closeViewPanel.topAnchor),
                                     closeViewPanel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                     closeViewPanel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                                     closeViewPanel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                                     closeViewPanel.heightAnchor.constraint(equalToConstant: closeViewPanelHeight)
        ])
        
        guard let layout = checkInResultCollection.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        layout.itemSize = CGSize(width: Double(self.view.bounds.width) - 20.0, height: 75.0)
        layout.sectionInset = UIEdgeInsets(top: 10.0, left: 15.0, bottom: 10.0, right: 15.0)
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .vertical
        layout.invalidateLayout()

        UserInsightsAPI.instance.get(submissionID: self.submissionID) { [weak self] (insights) in
            self?.userInsights = insights?.filter({ $0.insightType != .logs }).sorted(by: { $0.defaultOrder <= $1.defaultOrder })
            if  let result  = insights?.filter({ $0.insightType == .logs }), !result.isEmpty {
                self?.checkinResult = result[0].details?.history?[0]
            }
        }
        
        self.titleView.titleLabel.text = self.isCheckInResult ? "Check-in Results" : "Results"
        self.showSpinner()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        closeViewPanel.setupShadow(opacity: 0.12, radius: 8, offset: .init(width: 0, height: 3), color: .black)
    }
    
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CoughTestResultViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.checkinResult?.goals.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      if indexPath.section == 1 {
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = CGFloat(collectionView.bounds.width) - 30.0
        var height: CGFloat = 80.0
        
        if indexPath.section == 0 {
            if let inSight = self.checkinResult?.insights[indexPath.row] {
                let insightTitle = inSight.text
                let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.semibold, size: 24.0),
                                                                 .foregroundColor: UIColor(hexString: "#4E4E4E")]
                let attributedinsightTitle = NSMutableAttributedString(string: insightTitle, attributes: attributes)
                
                if !inSight.goalDescription.isEmpty {
                    let insightDesc = "\n\n\(inSight.goalDescription)"
                    
                    let descAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.regular, size: 14.0),
                                                                         .foregroundColor: UIColor(hexString: "#4E4E4E")]
                    let attributedDescText = NSMutableAttributedString(string: insightDesc, attributes: descAttributes)
                    attributedinsightTitle.append(attributedDescText)
                }
                
                let textAreaWidth = width
                
                let textHeight = attributedinsightTitle.height(containerWidth: textAreaWidth) + 40.0
                return CGSize(width: width, height: textHeight)
            }
        } else if indexPath.section == 1 { //Calculating Goal Height
            if let goal = self.checkinResult?.goals[indexPath.item] {
                let insightTitle = goal.text
                let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.semibold, size: 18.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
                let attributedinsightTitle = NSMutableAttributedString(string: insightTitle, attributes: attributes)
                
                let textAreaWidth = width - 66.0
                
                var goalHeight = 14.0 + attributedinsightTitle.height(containerWidth: textAreaWidth)
                
                if !goal.goalDescription.isEmpty {
                    let insightDesc = "\n\n\(goal.goalDescription)"
                    
                    let descAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.regular,
                                                                                       size: 14.0),
                                                                         .foregroundColor: UIColor(hexString: "#4E4E4E")]
                    let attributedDescText = NSMutableAttributedString(string: insightDesc, attributes: descAttributes)
                    attributedinsightTitle.append(attributedDescText)
                    
                    goalHeight += attributedinsightTitle.height(containerWidth: textAreaWidth)
                }
                
                if let citation = goal.citation, !citation.isEmpty {
                    let linkAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.regular,
                                                                                       size: 14.0),
                                                                         .foregroundColor: UIColor(red: 0.05,
                                                                                                   green: 0.4, blue: 0.65, alpha: 1.0),
                                                                         .underlineStyle: NSUnderlineStyle.single]
                    let attributedCitationText = NSMutableAttributedString(string: citation,
                                                                           attributes: linkAttributes)
                    goalHeight += attributedCitationText.height(containerWidth: textAreaWidth)
                    goalHeight += 10.0
                }
                
                goalHeight += 14.0
                
                return CGSize(width: width, height: goalHeight)
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
            headerView.setup(comletedDate: recoredDate, surveyName: self.surveyName, isCheckIn: self.isCheckInResult)
            return headerView
        } else {
            guard let headerView = collectionView.getSupplementaryView(with: CheckInNextGoals.self, viewForSupplementaryElementOfKind: kind, at: indexPath) as? CheckInNextGoals else { preconditionFailure("Invalid header type") }
            return headerView
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0  {
            return CGSize(width: collectionView.bounds.width, height: 260.0)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 10.0)
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
