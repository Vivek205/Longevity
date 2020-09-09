//
//  DashboardDeviceCollectionCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 10/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

enum DeviceConnectionStatus: Int {
    case connected
    case notConnected
    case notrequired
}

extension DeviceConnectionStatus {
    var statusButtonImage:String {
        switch self {
        case .connected:
            return "icon: check mark"
        case .notConnected:
            return "icon: add"
        default:
            return "addButton"
        }
    }
}

class DashboardDeviceCollectionCell: UICollectionViewCell {
    
    var device: HealthDevices = .newdevice
    
    var connectionStatus: DeviceConnectionStatus! {
        didSet {
            DispatchQueue.main.async {
                if self.connectionStatus == .connected {
                    self.addDeviceButton.isHidden = true
                    
                    let title1 = "Connected"
                    let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Regular", size: 14.0),.foregroundColor: UIColor(hexString: "#4A4A4A")]
                    let attributedText = NSMutableAttributedString(string: title1, attributes: attributes)
                    
                    let title2 = "\nView Settings"
                    let attributes2: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Regular", size: 14.0),.foregroundColor: UIColor.themeColor]
                    let attributedText2 = NSMutableAttributedString(string: title2, attributes: attributes2)
                    attributedText.append(attributedText2)
                    self.deviceTitle2.attributedText = attributedText
                } else {
                    self.addDeviceButton.isHidden = false
                    self.addDeviceButton.setImage(UIImage(named: self.connectionStatus.statusButtonImage), for: .normal)
                    self.deviceTitle2.text = self.device.descriptions
                    self.deviceTitle2.textColor = .themeColor
                }
            }
        }
    }
    
    lazy var deviceIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(named: "Icon-Apple-Health")
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    
    lazy var addDeviceButton: UIButton = {
        let statusbutton = UIButton()
        statusbutton.setImage(UIImage(named: "icon: add"), for: .normal)
        statusbutton.imageView?.contentMode = .scaleAspectFit
        statusbutton.addTarget(self, action: #selector(addDevice), for: .touchUpInside)
        statusbutton.translatesAutoresizingMaskIntoConstraints = false
        return statusbutton
    }()
    
    lazy var deviceStatus: UILabel = {
        let dStatus = UILabel()
        dStatus.text = ""
        dStatus.font = UIFont(name: "Montserrat-SemiBold", size: 10.0)
        dStatus.textColor = .themeColor
        dStatus.textAlignment = .center
        dStatus.translatesAutoresizingMaskIntoConstraints = false
        return dStatus
    }()
    
    lazy var deviceTitle: UILabel = {
        let title = UILabel()
        title.textAlignment = .center
        title.numberOfLines = 0
        title.lineBreakMode = .byWordWrapping
        title.font = UIFont(name: "Montserrat-Medium", size: 20.0)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    lazy var deviceTitle2: UILabel = {
        let title = UILabel()
        title.textAlignment = .center
        title.font = UIFont(name: "Montserrat-Regular", size: 14.0)
        title.numberOfLines = 0
        title.lineBreakMode = .byWordWrapping
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    var borderColor: UIColor = .borderColor
    var isEmptyCell: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(device: HealthDevices) {
        self.device = device

        if device == .newdevice {
            self.addSubview(addDeviceButton)
            self.addSubview(deviceTitle)
            
            NSLayoutConstraint.activate([
                addDeviceButton.topAnchor.constraint(equalTo: topAnchor, constant: 20.0),
                addDeviceButton.heightAnchor.constraint(equalToConstant: 38.0),
                addDeviceButton.widthAnchor.constraint(equalTo: addDeviceButton.heightAnchor),
                addDeviceButton.centerXAnchor.constraint(equalTo: centerXAnchor),
                deviceTitle.topAnchor.constraint(equalTo: addDeviceButton.bottomAnchor, constant: 10.0),
                deviceTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5.0),
                deviceTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5.0),
                deviceTitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0)
            ])
            deviceTitle.text = device.deviceName
            addDeviceButton.setImage(UIImage(named: DeviceConnectionStatus.notrequired.statusButtonImage), for: .normal)
            addDeviceButton.tintColor = UIColor.lightGray
            
            deviceTitle.textColor = UIColor.lightGray//.themeColor
            self.backgroundColor = UIColor(hexString: "#F5F6FA")
            contentView.layer.borderColor = UIColor.lightGray.cgColor //.themeColor.cgColor
            connectionStatus = .notrequired
        } else {
            
            let horizontalStack = UIStackView(arrangedSubviews: [self.deviceIcon, self.addDeviceButton])
            horizontalStack.axis = .horizontal
            horizontalStack.alignment = .center
            horizontalStack.distribution = .equalSpacing
            horizontalStack.translatesAutoresizingMaskIntoConstraints = false
            
            self.addSubview(horizontalStack)
            self.addSubview(deviceStatus)
            self.addSubview(deviceTitle)
            self.addSubview(deviceTitle2)
            
            NSLayoutConstraint.activate([
                horizontalStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.0),
                horizontalStack.topAnchor.constraint(equalTo: topAnchor, constant: 10.0),
                horizontalStack.heightAnchor.constraint(equalToConstant: 40.0),
                horizontalStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.0),
                
                deviceTitle.topAnchor.constraint(equalTo: horizontalStack.bottomAnchor),
                deviceTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
                deviceTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
                deviceTitle2.leadingAnchor.constraint(equalTo: leadingAnchor),
                deviceTitle2.trailingAnchor.constraint(equalTo: trailingAnchor),
                deviceTitle2.topAnchor.constraint(equalTo: deviceTitle.bottomAnchor, constant: 5.0),
                deviceTitle2.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.0)
            ])
            
            self.deviceTitle.text = device.deviceName
            self.deviceIcon.image = device.icon
            self.addDeviceButton.setImage(UIImage(named: DeviceConnectionStatus.notConnected.statusButtonImage), for: .normal)
            contentView.layer.borderColor = UIColor.clear.cgColor
        }
        
        AppSyncManager.instance.healthProfile.addAndNotify(observer: self) { [weak self] in
            let profile = AppSyncManager.instance.healthProfile.value
            if self?.device == .fitbit {
                if let device = profile?.devices?[ExternalDevices.fitbit], device["connected"] == 1 {
                    self?.connectionStatus = .connected
                } else {
                    self?.connectionStatus = .notConnected
                }
            } else if self?.device == .applehealth {
                if let device = profile?.devices?[ExternalDevices.healthkit], device["connected"] == 1 {
                    self?.connectionStatus = .connected
                } else {
                    self?.connectionStatus = .notConnected
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.cornerRadius = 5.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.cornerRadius = 5.0
        layer.shadowRadius = 1.0
        layer.shadowOpacity = 0.25
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
    
    @objc func addDevice() {
        if connectionStatus == .notConnected {
            if self.device == .applehealth {
                HealthStore.shared.getHealthKitAuthorization { (authorized) in
                    if authorized {
                        AppSyncManager.instance.updateHealthProfile(deviceName: ExternalDevices.healthkit, connected: 1)
                    } else {
                        AppSyncManager.instance.updateHealthProfile(deviceName: ExternalDevices.healthkit, connected: 0)
                    }
                }
            } else if self.device == .fitbit {
                let fitbitModel = FitbitModel()
                if let context = UIApplication.shared.keyWindow {
                    fitbitModel.contextProvider = AuthContextProvider(context)
                }
                fitbitModel.auth { authCode, error in
                    if error != nil {
                        print("Auth flow finished with error \(String(describing: error))")
                        AppSyncManager.instance.updateHealthProfile(deviceName: ExternalDevices.fitbit, connected: 0)
                    } else {
                        print("Your auth code is \(String(describing: authCode))")
                        fitbitModel.token(authCode: authCode!)
                        AppSyncManager.instance.updateHealthProfile(deviceName: ExternalDevices.fitbit, connected: 1)
                    }
                }
            }
            
            let healthDevice = self.device == .applehealth ? ExternalDevices.healthkit : ExternalDevices.fitbit
            
            let profile = AppSyncManager.instance.healthProfile.value
            if let device = profile?.devices?[healthDevice] {
                AppSyncManager.instance.healthProfile.value?.devices?[healthDevice]?["connected"] = 1
            } else {
                AppSyncManager.instance.healthProfile.value?.devices?.merge([healthDevice: ["connected" : 1]]) { (current, _) in current }
            }
            
            let userProfile = UserProfileAPI()
            userProfile.saveUserHealthProfile(healthProfile: AppSyncManager.instance.healthProfile.value!, completion: {
                print("Completed")
            }) { (error) in
                print("Failed to save health profile:" + error.localizedDescription)
            }
        }
    }
}
