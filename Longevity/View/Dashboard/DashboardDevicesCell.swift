//
//  DashboardDevicesCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 08/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class DashboardDevicesCell: UITableViewCell {
    
    lazy var devicesCollection: UICollectionView = {
        let devices = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        devices.backgroundColor = .clear
        devices.delegate = self
        devices.dataSource = self
        devices.showsHorizontalScrollIndicator = false
        devices.translatesAutoresizingMaskIntoConstraints = false
        return devices
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(devicesCollection)
        
        NSLayoutConstraint.activate([
            devicesCollection.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            devicesCollection.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            devicesCollection.topAnchor.constraint(equalTo: self.topAnchor),
            devicesCollection.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        guard let layout = devicesCollection.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        layout.sectionInset = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
        layout.scrollDirection = .horizontal
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DashboardDevicesCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.getCell(with: UICollectionViewCell.self, at: indexPath)
        cell.backgroundColor = .blue
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height
        return CGSize(width: 120.0, height: height - 20.0)
    }
}
