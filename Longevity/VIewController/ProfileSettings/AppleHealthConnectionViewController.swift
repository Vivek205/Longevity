//
//  AppleHealthConnectionViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 27/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class AppleHealthConnectionViewController: UIViewController {
    
    var isDeviceConnected: Bool {
        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()
        let devices = (defaults.dictionary(forKey: keys.devices) ?? [:]) as [String:[String:Int]]
        let healthkitStatus = (devices[ExternalDevices.HEALTHKIT] ?? [:]) as [String:Int]
        return healthkitStatus["connected"] == 1
    }
    
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
        
        self.view.backgroundColor = UIColor(hexString: "#FFFFFF") //UIColor(hexString: "#F5F6FA")
        self.view.addSubview(connectionTableView)
        
        self.connectionTableView.backgroundColor = .clear
        self.connectionTableView.tableFooterView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = "Apple Health"
        titleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 17.0)
        titleLabel.textColor = UIColor(hexString: "#4E4E4E")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.navigationItem.titleView = titleLabel
        let leftbutton = UIBarButtonItem(image: UIImage(named: "icon: arrow")?.withHorizontallyFlippedOrientation(), style: .plain, target: self, action: #selector(closeView))
        leftbutton.tintColor = .themeColor
        self.navigationItem.leftBarButtonItem = leftbutton
        
        NSLayoutConstraint.activate([
            self.connectionTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.connectionTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.connectionTableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.connectionTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension AppleHealthConnectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.getCell(with: AppleHealthTopCell.self, at: indexPath) as? AppleHealthTopCell else { preconditionFailure("Invalid cell type") }
            cell.isDeviceConnected = self.isDeviceConnected
            return cell
        } else if indexPath.row == 1 {
            guard let cell = tableView.getCell(with: AppleHealthStatusCell.self, at: indexPath) as? AppleHealthStatusCell else { preconditionFailure("Invalid cell type") }
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.getCell(with: UITableViewCell.self, at: indexPath)
            
            let connectButton = UIButton()
            if self.isDeviceConnected {
                connectButton.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 24.0)
                connectButton.setTitle("Disconnect", for: .normal)
                connectButton.setTitleColor(UIColor(hexString: "#E67381"), for: .normal)
                connectButton.backgroundColor = .clear
            } else {
                connectButton.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 24.0)
                connectButton.setTitle("Connect", for: .normal)
                connectButton.setTitleColor(.white, for: .normal)
                connectButton.backgroundColor = .themeColor
            }
            
            connectButton.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(connectButton)
            
            NSLayoutConstraint.activate([
                connectButton.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 15.0),
                connectButton.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -15.0),
                connectButton.topAnchor.constraint(equalTo: cell.topAnchor, constant: 2.0),
                connectButton.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -2.0)
            ])
            
            connectButton.layer.cornerRadius = 10.0
            connectButton.layer.masksToBounds = true
            if !self.isDeviceConnected {
                connectButton.layer.shadowColor = UIColor.black.cgColor
                connectButton.layer.shadowOffset = CGSize(width: 0, height: 1.0)
                connectButton.layer.cornerRadius = 10.0
                connectButton.layer.shadowRadius = 0
                connectButton.layer.shadowOpacity = 0.25
                connectButton.layer.masksToBounds = false
                connectButton.layer.shadowPath = UIBezierPath(roundedRect: connectButton.bounds, cornerRadius: connectButton.layer.cornerRadius).cgPath
            } else {
                connectButton.layer.borderWidth = 2.0
                connectButton.layer.borderColor = UIColor(hexString: "#E67381").cgColor
            }
            
            connectButton.addTarget(self, action: #selector(connectDevice), for: .touchUpInside)
            
            cell.backgroundColor = .clear
            return cell
        } else {
            guard let cell = tableView.getCell(with: HowItWorksCell.self, at: indexPath) as? HowItWorksCell else { preconditionFailure("Invalid cell type") }
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
        if self.isDeviceConnected {
            
        } else {
            
        }
    }
}
