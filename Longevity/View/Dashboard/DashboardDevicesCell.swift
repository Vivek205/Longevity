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
    case newdevice = 2
}

extension HealthDevices {
    var icon : UIImage? {
        switch self {
        case .applehealth:
            return UIImage(named: "Icon-Apple-Health")
        case .fitbit:
            return UIImage(named: "icon:  fitbit logo")
        default:
            return nil
        }
    }
    
    var deviceName: String {
        switch self {
        case .applehealth:
            return "Healthkit"
        case .fitbit:
            return "Fitbit"
        default:
            return "Add health device"
        }
    }
    
    var descriptions: String {
        switch self {
        case .applehealth:
            return "Sync your health information"
        case .fitbit:
            return "Add your Fitbit device"
        default:
            return ""
        }
    }
}

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
        self.backgroundColor = UIColor(hexString: "#F5F6FA")
        NSLayoutConstraint.activate([
            devicesCollection.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            devicesCollection.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            devicesCollection.topAnchor.constraint(equalTo: self.topAnchor),
            devicesCollection.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        guard let layout = devicesCollection.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        layout.sectionInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 20.0)
        layout.scrollDirection = .horizontal
        
        self.selectionStyle = .none
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
        
        cell.setupCell(device: HealthDevices(rawValue: indexPath.item)!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height
        return CGSize(width: 130.0, height: height - 20.0)
    }
}
