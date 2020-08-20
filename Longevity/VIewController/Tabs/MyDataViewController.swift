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
            self.myDataCollectionView.reloadData()
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
    
    init() {
        super.init(viewTab: .myData)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(myDataCollectionView)
        
        NSLayoutConstraint.activate([
            myDataCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            myDataCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            myDataCollectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            myDataCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        guard let layout = myDataCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        layout.itemSize = CGSize(width: Double(self.view.bounds.width) - 20.0, height: 75.0)
        layout.sectionInset = UIEdgeInsets(top: 100.0, left: 10.0, bottom: 10.0, right: 10.0)
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .vertical
        
        UserInsightsAPI.instance.get { [weak self] (insights) in
            DispatchQueue.main.async {
                self?.userInsights = insights.sorted(by: { $0.defaultOrder <= $1.defaultOrder })
            }
        }
    }
}

extension MyDataViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userInsights?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.getCell(with: MyDataCell.self, at: indexPath) as? MyDataCell else {
            preconditionFailure("Invalid insight cell")
        }
        cell.insightData = self.userInsights?[indexPath.item]
        return cell
    }
}
