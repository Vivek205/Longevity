//
//  DashboardHeaderView.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 07/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class DashboardHeaderView: UITableViewHeaderFooterView {
    
    let vTop = UIDevice.hasNotch ? 100.0 : 60.0
    
    var userInsights: [UserInsight]? {
        didSet {
            DispatchQueue.main.async {
                self.dashboardTilesCollection.reloadData()
            }
        }
    }
    
    lazy var bgImageView: UIImageView = {
        let bgImage = UIImageView()
        bgImage.image = UIImage(named: "home-bg")
        bgImage.contentMode = .scaleAspectFill
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()
    
    lazy var dashboardTilesCollection: UICollectionView = {
        let dashboardTiles = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        dashboardTiles.backgroundColor = .clear
        dashboardTiles.delegate = self
        dashboardTiles.dataSource = self
        dashboardTiles.showsHorizontalScrollIndicator = false
        dashboardTiles.translatesAutoresizingMaskIntoConstraints = false
        dashboardTiles.allowsSelection = false
        return dashboardTiles
    }()
    
    let topMargin = 10.0
    let bottomMargin = 10.0
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.addSubview(bgImageView)
        self.addSubview(dashboardTilesCollection)
        
        NSLayoutConstraint.activate([
            bgImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bgImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bgImageView.topAnchor.constraint(equalTo: self.topAnchor),
            bgImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            dashboardTilesCollection.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            dashboardTilesCollection.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            dashboardTilesCollection.topAnchor.constraint(equalTo: self.topAnchor, constant: CGFloat(vTop)),
            dashboardTilesCollection.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        guard let layout = dashboardTilesCollection.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        layout.sectionInset = UIEdgeInsets(top: CGFloat(topMargin), left: 30.0, bottom: CGFloat(bottomMargin), right: 0.0)
        layout.scrollDirection = .horizontal
        
        AppSyncManager.instance.userInsights.addAndNotify(observer: self) { [weak self] in
            self?.userInsights = AppSyncManager.instance.userInsights.value?.filter({ $0.name != .logs })
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        //Removing all existing layers
        if let layers = bgImageView.layer.sublayers {
            for layer in layers {
                if let name = layer.name, name.contains("gradLayer") {
                    layer.removeFromSuperlayer()
                }
            }
        }

        let layerGradient = CAGradientLayer()
        layerGradient.name = "gradLayer"
        layerGradient.frame = CGRect(x: 0, y: 0, width: bgImageView.bounds.width, height: bgImageView.bounds.height)
        layerGradient.colors = [UIColor(hexString: "#F5F6FA").withAlphaComponent(0.0).cgColor, UIColor(hexString: "#F5F6FA").cgColor]
        layerGradient.startPoint = CGPoint(x: 0, y: 0.5)
        layerGradient.endPoint = CGPoint(x: 0, y: 1.0)

        bgImageView.layer.insertSublayer(layerGradient, at: 0)
        
        self.layer.masksToBounds = true
    }
}

extension DashboardHeaderView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if userInsights == nil || (userInsights?.isEmpty ?? false) {
            return 0
        }
        return (userInsights?.count ?? 0) + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item < 3 {
            guard let tileCell = collectionView.getCell(with: DashboardCollectionTileCell.self, at: indexPath) as? DashboardCollectionTileCell else {
                preconditionFailure("Invalid tile cell type")
            }
            
            //Workaround for the hexagons sequence
            let index = indexPath.item == 1 ? 2 : indexPath.item == 2 ? 1 : indexPath.item
            
            tileCell.insightData = self.userInsights?[index]
            tileCell.setupCell(index: indexPath.item)
            return tileCell
        } else {
            guard let tileCell = collectionView.getCell(with: DashboardCollectionEmptyCell.self, at: indexPath) as? DashboardCollectionEmptyCell else {
                preconditionFailure("Invalid tile cell type")
            }
            return tileCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height - CGFloat(topMargin + bottomMargin)
        let cellwidth = (collectionView.bounds.width - 50.0) / 2
        
        return CGSize(width: cellwidth, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let cellwidth = (collectionView.bounds.width - 30.0) / 2
        return -(cellwidth / 2.0)
    }
}
