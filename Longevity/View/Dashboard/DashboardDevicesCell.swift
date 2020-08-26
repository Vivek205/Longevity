//
//  DashboardDevicesCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 08/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class DashboardDevicesCell: UITableViewCell {
    
    var deviceIcons = ["Icon-Apple-Health", "icon:  fitbit logo", ""]
    var devices = ["Healthkit", "Fitbit", "Add health device"]
    var descriptions = ["Sync your health information", "Add your Fitbit device", ""]
    
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
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.getCell(with: DashboardDeviceCollectionCell.self, at: indexPath) as? DashboardDeviceCollectionCell else { preconditionFailure("Invalid device cell")}
        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()

        var connectionStatus: DeviceConnectionStatus = .notConnected

        if self.devices[indexPath.item] == "Fitbit" {
            if let devices = defaults.object(forKey: keys.devices) as? [String:[String:Int]]  {
                if let fitbitStatus = devices[ExternalDevices.FITBIT] {
                    if fitbitStatus["connected"] == 1 {
                        connectionStatus = .connected
                    }
                }
            }
        } else if self.devices[indexPath.item] == "Healthkit" {
            if let devices = defaults.object(forKey: keys.devices) as? [String:[String:Int]]  {
                if let healthkitStatus = devices[ExternalDevices.HEALTHKIT] {
                    if healthkitStatus["connected"] == 1 {
                        connectionStatus = .connected
                    }
                }
            }
        }
        
        cell.setupCell(title: self.devices[indexPath.item], description: self.descriptions[indexPath.item], icon: deviceIcons[indexPath.item], isEmpty: indexPath.item == 2, status: connectionStatus)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height
        return CGSize(width: 130.0, height: height - 20.0)
    }
}
