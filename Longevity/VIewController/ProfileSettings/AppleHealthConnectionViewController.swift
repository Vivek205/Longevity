//
//  AppleHealthConnectionViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 27/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

protocol AppleHealthConnectionDelegate: class {
    func device(connected: Bool)
}

class AppleHealthConnectionViewController: UIViewController {
    
    weak var delegate: AppleHealthConnectionDelegate?
    
    var isDeviceConnected: Bool = false
    
    lazy var connectionTableView: UITableView = {
        let connectionTable = UITableView()
        connectionTable.dataSource = self
        connectionTable.delegate = self
        connectionTable.separatorStyle = .none
        connectionTable.allowsSelection = false
        connectionTable.showsVerticalScrollIndicator = false
        connectionTable.translatesAutoresizingMaskIntoConstraints = false
        return connectionTable
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(hexString: "#F5F6FA")
        self.view.addSubview(connectionTableView)
        
        self.connectionTableView.backgroundColor = .clear
        self.connectionTableView.tableFooterView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = "Apple Health"
        titleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 17.0)
        titleLabel.textColor = UIColor(hexString: "#4E4E4E")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.navigationItem.titleView = titleLabel
        self.navigationController?.navigationBar.tintColor = UIColor(hexString: "#FFFFFF")
        let rightbutton = UIBarButtonItem(image: UIImage(named: "closex"),
                                          style: .plain, target: self, action: #selector(closeView))
        rightbutton.tintColor = .themeColor
        self.navigationItem.rightBarButtonItem = rightbutton
        
        NSLayoutConstraint.activate([
            self.connectionTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.connectionTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.connectionTableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.connectionTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        AppSyncManager.instance.healthProfile.addAndNotify(observer: self) { [weak self] in
            let profile = AppSyncManager.instance.healthProfile.value
            if let device = profile?.devices?[ExternalDevices.healthkit], device["connected"] == 1 {
                self?.isDeviceConnected = true
            } else {
                self?.isDeviceConnected = false
            }
            DispatchQueue.main.async {
                self?.connectionTableView.reloadData()
            }
        }
    }
    
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        AppSyncManager.instance.healthProfile.remove(observer: self)
    }
}

extension AppleHealthConnectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.getCell(with: AppleHealthTopCell.self, at: indexPath) as? AppleHealthTopCell else { preconditionFailure("Invalid cell type") }
            cell.setup(deviceImage: UIImage(named: "healthkitIcon"), deviceName: "Apple Health", isConnected: self.isDeviceConnected)
            return cell
        } else if indexPath.row == 1 {
            guard let cell = tableView.getCell(with: AppleHealthStatusCell.self, at: indexPath) as? AppleHealthStatusCell else { preconditionFailure("Invalid cell type") }
            return cell
        } else if indexPath.row == 2 {
            guard let cell = tableView.getCell(with: AppleHealthConnectCell.self, at: indexPath) as? AppleHealthConnectCell else { preconditionFailure("Invalid cell type") }
            cell.setConnection(isConnected: self.isDeviceConnected)
            cell.connectButton.addTarget(self, action: #selector(connectDevice), for: .touchUpInside)
            return cell
        } else {
            guard let cell = tableView.getCell(with: HowItWorksCell.self, at: indexPath) as? HowItWorksCell else { preconditionFailure("Invalid cell type") }
            cell.setupCell(howitworksDescription: "\n\nUse Apple Health to import data from your mobile phone to COVID Signals.  This will help improve AI accuracy for your health analysis and insights.\n\n", importedDescription: "\n\nGender (Sex), Weight, Height, Date of Birth, and Blood Type.\n\n")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 150.0
        } else if indexPath.row == 1 {
            return self.isDeviceConnected ? 160.0 : 0.0
        } else if indexPath.row == 2 {
            return 52.0
        }
        
        return 300.0
    }
    
    @objc func connectDevice() {
        var connected = self.isDeviceConnected ? 0 : 1

        if connected == 0 { // To be disconnected
            AppSyncManager.instance.updateHealthProfile(deviceName: ExternalDevices.healthkit, connected: connected)
            self.delegate?.device(connected: false)
        } else {
            HealthStore.shared.getHealthKitAuthorization(device: .applehealth) { (authorized) in
                connected = authorized ? 1 : 0
                AppSyncManager.instance.updateHealthProfile(deviceName: ExternalDevices.healthkit, connected: connected)
                self.delegate?.device(connected: authorized)
            }
        }
    }
}
