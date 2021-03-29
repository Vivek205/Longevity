//
//  CheckInResultViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 06/09/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CheckInResultViewController: UIViewController {
    
    var submissionID: String = ""
    var isCheckInResult: Bool = true
    var surveyName: String = ""
    
    var isCellExpanded: [Int:Bool] = [Int:Bool]()
    
    var userInsights: [UserInsight]? {
        didSet {
            DispatchQueue.main.async {
                self.checkInResultCollection.reloadData()
                self.removeSpinner()
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
            closeButton.heightAnchor.constraint(equalToConstant: 48.0)
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
        
    init(checkinResult: History) {
        super.init(nibName: nil, bundle: nil)
        self.checkinResult = checkinResult
        self.surveyName = checkinResult.surveyName ?? ""
        self.submissionID = checkinResult.submissionID
        if let surveyid = checkinResult.surveyID, surveyid.starts(with: Strings.covidCheckIn) {
            self.isCheckInResult = true
        } else {
            self.isCheckInResult = false
        }
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
                                     checkInResultCollection.topAnchor.constraint(equalTo: self.view.topAnchor,
                                                                                  constant: -UIApplication.shared.statusBarFrame.height),
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
        
        self.currentResultView = .analysis

        UserInsightsAPI.instance.get(submissionID: self.submissionID) { [weak self] (insights) in
            self?.userInsights = insights?.sorted(by: { $0.defaultOrder <= $1.defaultOrder })
        }
        
        if self.checkinResult == nil {
            UserInsightsAPI.instance.getLog(submissionID: self.submissionID) { [weak self] (checkinlog) in
                guard let loghistory = checkinlog?.details?.history else {
                    return
                }
                self?.checkinResult = loghistory.first
            }
        }
        
        self.titleView.titleLabel.text = self.isCheckInResult ? "Check-in Results" : "Results"
        self.showSpinner()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        closeViewPanel.setupShadow(opacity: 0.12, radius: 8,
                                   offset: .init(width: 0, height: 3),
                                   color: .black)
    }
    
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
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
                guard let cell = collectionView.getUniqueCell(with: MyDataInsightCell.self, at: indexPath) as? MyDataInsightCell else {
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
                    let headerHeight:CGFloat = 80.0
                    let descriptionHeight:CGFloat = insightData.userInsightDescription.height(withConstrainedWidth: width - 50.0,
                                                                                              font: UIFont(name: AppFontName.regular, size: 14.0) ?? UIFont.systemFont(ofSize: 14.0))
                    let gapsheight: CGFloat = 33.0
                    let histogramTitleHeight: CGFloat = 20.0
                    let histogramHeight:CGFloat = 120.0
                    let histogramDescriptionHeight: CGFloat = insightData.details?.histogram?.histogramDescription.height(withConstrainedWidth: width - 50.0,
                                                                                                                          font: UIFont(name: AppFontName.regular, size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)) ?? 0
                    let bottomMarginHeight: CGFloat = 20.0
                    height = headerHeight + descriptionHeight + gapsheight + histogramTitleHeight +
                        histogramHeight + histogramDescriptionHeight + bottomMarginHeight
                }
            } else {
                if isSymptomsExpanded {
                    if let symptoms = self.checkinResult?.symptoms {
                        let headerHeight: CGFloat = 140.0
                        let symptomsHeight: CGFloat = 37.0 * CGFloat(symptoms.count)
                        height = headerHeight + symptomsHeight
                    }else {
                        height = 430.0
                    }

                }
            }
        } else if indexPath.section == 0 {
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
            
            var recoredDate = ""
            if let datestring = checkinResult?.recordDate, !datestring.isEmpty {
                recoredDate = DateUtility.getString(from: datestring, toFormat: "EEE.MMM.dd")
            }
            headerView.setup(comletedDate: recoredDate, surveyName: self.surveyName, isCheckIn: self.isCheckInResult)
            headerView.currentView = self.currentResultView
            headerView.delegate = self
            return headerView
        } else {
            guard let headerView = collectionView.getSupplementaryView(with: CheckInNextGoals.self, viewForSupplementaryElementOfKind: kind, at: indexPath) as? CheckInNextGoals else { preconditionFailure("Invalid header type") }
            return headerView
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        if section == 0 && self.currentResultView == .analysis  {
//            return CGSize(width: collectionView.bounds.width, height: 220.0)
//        } else
        if section == 0  {
            return CGSize(width: collectionView.bounds.width, height: 220.0)
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

extension CheckInResultViewController: CheckInResultHeaderDelegate {
    func selected(resultView: CheckInResultView) {
        self.currentResultView = resultView
    }
}
