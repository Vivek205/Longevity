//
//  MyDataViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 06/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class MyDataViewController: BaseViewController {
    
    var userInsights: [UserInsight]? {
        didSet {
            DispatchQueue.main.async {
                self.myDataCollectionView.reloadData()
            }
        }
    }
    
    lazy var myDataCollectionView: UICollectionView = {
        let mydataCollection = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        mydataCollection.backgroundColor = .clear
        mydataCollection.showsVerticalScrollIndicator = false
        mydataCollection.delegate = self
        mydataCollection.dataSource = self
        mydataCollection.translatesAutoresizingMaskIntoConstraints = false
        return mydataCollection
    }()

    lazy var aiProcessingBand: AIProgressBandView = {
        let processingband = AIProgressBandView()
        processingband.translatesAutoresizingMaskIntoConstraints = false
        return processingband
    }()
    
    init() {
        super.init(viewTab: .myData)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(myDataCollectionView)
        self.titleView.addSubview(aiProcessingBand)
        
        NSLayoutConstraint.activate([
            myDataCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            myDataCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            myDataCollectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            myDataCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            aiProcessingBand.leadingAnchor.constraint(equalTo: self.titleView.leadingAnchor),
            aiProcessingBand.trailingAnchor.constraint(equalTo: self.titleView.trailingAnchor),
            aiProcessingBand.heightAnchor.constraint(equalToConstant: 40.0),
            aiProcessingBand.bottomAnchor.constraint(equalTo: self.titleView.bottomAnchor, constant: -10.0)
        ])

        SurveyTaskUtility.shared.surveyInProgress.addAndNotify(observer: self) {
            DispatchQueue.main.async {
                self.aiProcessingBand.isHidden = SurveyTaskUtility.shared.surveyInProgress.value != .pending
            }
        }
        
        guard let layout = myDataCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        layout.itemSize = CGSize(width: Double(self.view.bounds.width) - 20.0, height: 75.0)
        layout.sectionInset = UIEdgeInsets(top: 100.0, left: 10.0, bottom: 10.0, right: 10.0)
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .vertical
        layout.invalidateLayout()
        AppSyncManager.instance.userInsights.addAndNotify(observer: self) { [weak self] in
            self?.userInsights = AppSyncManager.instance.userInsights.value
        }
    }
    
    func expandItemfor(insightType: CardType) {
        guard let expandedIndex = self.userInsights?.firstIndex(where: { $0.name == insightType }) else { return }
        for index in 0..<(self.userInsights?.count ?? 0) {
            self.userInsights?[index].isExpanded = expandedIndex == index
        }
        self.myDataCollectionView.reloadData()
        self.myDataCollectionView.scrollToItem(at: IndexPath(item: expandedIndex, section: 0),
                                               at: .bottom, animated: true)
    }
    
    deinit {
        SurveyTaskUtility.shared.surveyInProgress.remove(observer: self)
        AppSyncManager.instance.userInsights.remove(observer: self)
    }
}

extension MyDataViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.userInsights?.count ?? 0
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let insightData = self.userInsights?[indexPath.item] else {
            return collectionView.getCell(with: UICollectionViewCell.self, at: indexPath)
        }
        
        if insightData.name == .logs || insightData.name == .coughlogs {
            guard let cell = collectionView.getCell(with: MyDataLogCell.self, at: indexPath) as? MyDataLogCell else {
                preconditionFailure("Invalid insight cell")
            }
            cell.logData = insightData
            return cell
        } else {
            guard let cell = collectionView.getCell(with: MyDataInsightCell.self, at: indexPath) as? MyDataInsightCell else {
                preconditionFailure("Invalid insight cell")
            }
            cell.insightData = insightData
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let insightData = self.userInsights?[indexPath.item] else { return }
        
        if insightData.name != .logs {
            self.userInsights?[indexPath.item].isExpanded = !(insightData.isExpanded ?? false)
        } else {
            let checkinLogViewController: CheckinLogViewController = CheckinLogViewController()
            NavigationUtility.presentOverCurrentContext(destination: checkinLogViewController, style: .overCurrentContext)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = CGFloat(collectionView.bounds.width) - 20.0
        var height: CGFloat = 80.0

        guard let insightData = self.userInsights?[indexPath.item] else { return CGSize(width: width, height: height) }

        if insightData.name != .logs && insightData.name != .coughlogs && (insightData.isExpanded ?? false) {
            
            let headerHeight:CGFloat = 80.0
            let descriptionHeight:CGFloat = insightData.userInsightDescription.height(withConstrainedWidth: width - 50.0,
                                                                                      font: UIFont(name: "Montserrat-Regular", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0))
            let gapsheight: CGFloat = 33.0
            let histogramTitleHeight: CGFloat = 20.0
            let histogramHeight:CGFloat = 120
            let histogramDescriptionHeight: CGFloat = insightData.details?.histogram?.histogramDescription.height(withConstrainedWidth: width - 50.0, font: UIFont(name: "Montserrat-Regular", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)) ?? 0
            let bottomMarginHeight: CGFloat = 20.0
            height = headerHeight + descriptionHeight + gapsheight + histogramTitleHeight +
                histogramHeight + histogramDescriptionHeight + bottomMarginHeight
        }

        return CGSize(width: width, height: height)
    }
}
