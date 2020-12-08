//
//  DashboardDevicesCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 08/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

enum HealthDevices: Int, CaseIterable {
    case applehealth = 0
    case fitbit = 1
    case applewatch = 2
}

extension HealthDevices {
    var icon : UIImage? {
        switch self {
        case .applehealth:
            return UIImage(named: "Icon-Apple-Health")
        case .fitbit:
            return UIImage(named: "icon:  fitbit logo")
        case .applewatch:
            return UIImage(named: "icon: apple watch")
        }
    }
    
    var deviceName: String {
        switch self {
        case .applehealth:
            return "Apple Health"
        case .fitbit:
            return "Fitbit"
        case .applewatch:
            return "Apple Watch"
        }
    }
    
    var deviceType: String {
        switch self {
        case .applehealth:
            return "HEALTHKIT"
        case .fitbit:
            return "Fitbit"
        case .applewatch:
            return "APPLEWATCH"
        }
    }
    
    var descriptions: String {
        switch self {
        case .applehealth:
            return "Sync your health information"
        case .fitbit:
            return "Connect your Fitbit product"
        case .applewatch:
            return "Connect your device"
        }
    }
}

protocol DashboardDevicesCellDelegate {
    func showError(forDeviceCollectionCell cell:DashboardDeviceCollectionCell)
}

class DashboardDevicesCell: UICollectionViewCell {
    var delegate:DashboardDevicesCellDelegate?
    
    lazy var devicesCollection: UICollectionView = {
        let devices = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        devices.backgroundColor = .clear
        devices.delegate = self
        devices.dataSource = self
        devices.showsHorizontalScrollIndicator = false
        devices.isScrollEnabled = true
        devices.isUserInteractionEnabled = true
        devices.translatesAutoresizingMaskIntoConstraints = false
        return devices
    }()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        
        self.contentView.addSubview(devicesCollection)
        self.backgroundColor = UIColor(hexString: "#F5F6FA")
        NSLayoutConstraint.activate([
            devicesCollection.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            devicesCollection.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            devicesCollection.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            devicesCollection.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
        
        guard let layout = devicesCollection.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        layout.sectionInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 20.0)
        layout.scrollDirection = .horizontal
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DashboardDevicesCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return HealthDevices.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.getCell(with: DashboardDeviceCollectionCell.self, at: indexPath) as? DashboardDeviceCollectionCell else { preconditionFailure("Invalid device cell")}
        cell.delegate = self
        cell.setupCell(device: HealthDevices(rawValue: indexPath.item)!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height
        return CGSize(width: 130.0, height: height - 20.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? DashboardDeviceCollectionCell else {
            return
        }
        cell.selectCell()
    }
}

extension DashboardDevicesCell: DashboardDeviceCollectionCellDelegate {
    func showNotificationError(forCell cell: DashboardDeviceCollectionCell) {
        delegate?.showError(forDeviceCollectionCell: cell)
    }
}
