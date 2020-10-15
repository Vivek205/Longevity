//
//  DeviceConnectionsPopupViewController.swift
//  Longevity
//
//  Created by vivek on 07/09/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

fileprivate struct DeviceConnectionInfo {
    let title:String
    let info:String
}

fileprivate let deviceConnectionInfoList:[DeviceConnectionInfo] = [
    DeviceConnectionInfo(title: "Health Kit", info: "HealthKit provides a central repository for health and fitness data recorded by your iPhone and Apple Watch. With your permission, Rejuve app communicates with Apple Health to access your health data to generate more accurate personalized AI insight reports."),
    DeviceConnectionInfo(title: "Fitbit Devices", info: "Fitbit helps you track your daily activity, exercise, sleep, nutrition and weight. With your permission, Rejuve app uses this data to compute more accurate personalized AI insight reports."),
    DeviceConnectionInfo(title: "Apple Watch Devices", info: "Apple Watch is an advanced wearable that can communicate with your iPhone’s Apple Health and the Rejuve app. With your permission, Rejuve uses Apple Watch data to compute more accurate personalized AI insight reports.")
]

class DeviceConnectionsPopupViewController: BasePopUpModalViewController {
    
    lazy var deviceInfoCollection: UICollectionView = {
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .clear
        return collection
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.containerView.addSubview(deviceInfoCollection)
        self.containerView.addSubview(self.actionButton)
        self.actionButton.setTitle("Ok", for: .normal)
        
        let screenHeight = UIScreen.main.bounds.height
        
        NSLayoutConstraint.activate([
            deviceInfoCollection.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            deviceInfoCollection.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            deviceInfoCollection.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            deviceInfoCollection.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -30),
            
            containerView.heightAnchor.constraint(equalToConstant: screenHeight - 150.0),
            
            actionButton.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 30.0),
            actionButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -30.0),
            actionButton.heightAnchor.constraint(equalToConstant: 48),
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -27)
        ])
        
        titleLabel.text = "Device \n Connections"
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byWordWrapping
        
        guard let layout = deviceInfoCollection.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        layout.minimumInteritemSpacing = 18
        layout.scrollDirection = .vertical
        layout.invalidateLayout()
    }
}

extension DeviceConnectionsPopupViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deviceConnectionInfoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.getCell(with: DeviceConnectionPopupCell.self, at: indexPath) as? DeviceConnectionPopupCell else { preconditionFailure("Invalid cell")}
        let details = deviceConnectionInfoList[indexPath.item]
        cell.setText(title: details.title, info: details.info)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 40
        //        let height = CGFloat(100)
        let details = deviceConnectionInfoList[indexPath.item]
        let titleHeight = details.title.height(withConstrainedWidth: width - 40, font:UIFont(name: "Montserrat-SemiBold", size: 18) ?? UIFont())
        let infoHeight = details.info.height(withConstrainedWidth: width - 40, font: UIFont(name: "Montserrat-Regular", size: 16) ?? UIFont())
        let height = titleHeight + infoHeight + CGFloat(20)
        return CGSize(width: width, height: height)
    }
}
