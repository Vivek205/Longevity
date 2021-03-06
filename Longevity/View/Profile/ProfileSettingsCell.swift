//
//  ProfileSettingsCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 20/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

protocol ProfileSettingsCellDelegate: class {
    func switchToggled(onCell cell:ProfileSettingsCell,newState isOn: Bool)
}

class ProfileSettingsCell: UITableViewCell {
    
    weak var delegate:ProfileSettingsCellDelegate?
    
    var profileSetting: ProfileSetting! {
        didSet {
            self.settingName.text = profileSetting.rawValue
            self.settingsSwitch.isHidden = true
            self.settingsActionImage.isHidden = true
            
            if profileSetting.settingAccessory == .addcontrol {
                self.settingsActionImage.isHidden = false
                self.settingsActionImage.tintColor = .themeColor
                if let device = AppSyncManager.instance.healthProfile.value?.devices?[ExternalDevices.watch], device["connected"] == 1, self.profileSetting == .applewatch {
                    self.settingsActionImage.image = UIImage(named: "icon: arrow")
                } else {
                    self.settingsActionImage.image = UIImage(named: "addButton")
                }
            } else if profileSetting.settingAccessory == .navigate {
                self.settingsActionImage.isHidden = false
                self.settingsActionImage.image = UIImage(named: "icon: arrow")
            } else if profileSetting.settingAccessory == .switchcontrol {
                if profileSetting == .notifications {
                    notificationSettingSwitchPreselect()
                } else if profileSetting == .fitbit {
                    fitbitSwitchPreselect()
                } else if profileSetting == .usemetricsystem {
                    metricSystemPreselect()
                }
                self.settingsSwitch.isHidden = false
            }
            
            if profileSetting.settingPosition == .topmost {
                self.settingBGView.layer.cornerRadius = 5.0
                self.settingBGView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                self.settingBGView.layer.masksToBounds = true
            } else if profileSetting.settingPosition == .bottom {
                self.settingBGView.layer.cornerRadius = 5.0
                self.settingBGView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                self.settingBGView.layer.masksToBounds = true
            } else {
                self.settingBGView.layer.cornerRadius = 0.0
                self.settingBGView.layer.masksToBounds = false
            }
            
            settingStatus.isHidden = profileSetting != .applehealth && profileSetting != .applewatch
            if !settingStatus.isHidden {
                AppSyncManager.instance.healthProfile.addAndNotify(observer: self) { [weak self] in
                    DispatchQueue.main.async {
                        let profile = AppSyncManager.instance.healthProfile.value
                        var settingStatusText = ""
                        if self?.profileSetting == .applehealth {
                            if let device = profile?.devices?[ExternalDevices.healthkit], device["connected"] == 1 {
                                settingStatusText = "Connected"
                            } else {
                                settingStatusText = "Not Connected"
                            }
                        } else if self?.profileSetting == .applewatch {
                            if let device = profile?.devices?[ExternalDevices.watch], device["connected"] == 1 {
                                settingStatusText = "Connected"
                                self?.settingsActionImage.image = UIImage(named: "icon: arrow")
                            } else {
                                settingStatusText = ""
                                self?.settingsActionImage.image = UIImage(named: "addButton")
                            }
                        }
                        self?.settingStatus.text = settingStatusText
                    }
                }
            }
        }
    }
    
    lazy var settingBGView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.translatesAutoresizingMaskIntoConstraints = false
        return bgView
    }()
    
    lazy var settingName: UILabel = {
        let settingname = UILabel()
        settingname.font = UIFont(name: "Montserrat-Medium", size: 18.0)
        settingname.textColor = UIColor(named: "#4A4A4A")
        settingname.translatesAutoresizingMaskIntoConstraints = false
        return settingname
    }()
    
    lazy var settingStatus: UILabel = {
        let settingstatus = UILabel()
        settingstatus.font = UIFont(name: "Montserrat-Medium", size: 14.0)
        settingstatus.textColor = .themeColor
        settingstatus.text = "Not Connected"
        settingstatus.translatesAutoresizingMaskIntoConstraints = false
        return settingstatus
    }()
    
    lazy var settingsActionImage: UIImageView = {
        let actionImage = UIImageView()
        actionImage.contentMode = .scaleAspectFit
        actionImage.isUserInteractionEnabled = false
        actionImage.translatesAutoresizingMaskIntoConstraints = false
        return actionImage
    }()
    
    lazy var settingsSwitch: UISwitch = {
        let settingsswitch = UISwitch()
        settingsswitch.onTintColor = .themeColor
        settingsswitch.translatesAutoresizingMaskIntoConstraints = false
        return settingsswitch
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        self.contentView.addSubview(settingBGView)
        self.contentView.addSubview(settingName)
        self.contentView.addSubview(settingsActionImage)
        self.contentView.addSubview(settingsSwitch)
        self.contentView.addSubview(settingStatus)
        
        NSLayoutConstraint.activate([
            settingBGView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
            settingBGView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
            settingBGView.topAnchor.constraint(equalTo: topAnchor),
            settingBGView.bottomAnchor.constraint(equalTo: bottomAnchor),
            settingName.centerYAnchor.constraint(equalTo: settingBGView.centerYAnchor),
            settingName.leadingAnchor.constraint(equalTo: settingBGView.leadingAnchor, constant: 10.0),
            settingsActionImage.trailingAnchor.constraint(equalTo: settingBGView.trailingAnchor, constant: -10.0),
            settingsActionImage.widthAnchor.constraint(equalToConstant: 25.0),
            settingsActionImage.heightAnchor.constraint(equalTo: settingsActionImage.widthAnchor),
            settingsActionImage.centerYAnchor.constraint(equalTo: settingBGView.centerYAnchor),
            settingsActionImage.leadingAnchor.constraint(greaterThanOrEqualTo: settingName.trailingAnchor, constant: 10.0),
            settingsSwitch.trailingAnchor.constraint(equalTo: settingBGView.trailingAnchor, constant: -10.0),
            settingsSwitch.centerYAnchor.constraint(equalTo: settingBGView.centerYAnchor),
            settingsSwitch.leadingAnchor.constraint(greaterThanOrEqualTo: settingName.trailingAnchor, constant: 10.0),
            settingStatus.trailingAnchor.constraint(equalTo: settingsActionImage.leadingAnchor, constant: -10.0),
            settingStatus.centerYAnchor.constraint(equalTo: settingBGView.centerYAnchor)
        ])
        
        self.settingsSwitch.addTarget(self, action: #selector(handleSwitchToggle(_:)), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        AppSyncManager.instance.healthProfile.remove(observer: self)
        AppSyncManager.instance.userNotification.remove(observer: self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.settingBGView.layer.shadowColor = UIColor.black.cgColor
        self.settingBGView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.settingBGView.layer.shadowRadius = 1.0
        self.settingBGView.layer.shadowOpacity = 0.25
        self.settingBGView.layer.masksToBounds = false
        self.settingBGView.layer.shadowPath = UIBezierPath(roundedRect: self.settingBGView.bounds, cornerRadius: self.settingBGView.layer.cornerRadius).cgPath
    }
    
    @objc func handleSwitchToggle(_ sender: UISwitch){
        delegate?.switchToggled(onCell: self, newState: sender.isOn)
    }
    
    func notificationSettingSwitchPreselect() {
        AppSyncManager.instance.userNotification.addAndNotify(observer: self) {
            [weak self] in
            guard let notification = AppSyncManager.instance.userNotification.value else {return}
            if notification.isEnabled == true {
                DispatchQueue.main.async {
                    self?.settingsSwitch.isOn = true
                }
            }else {
                DispatchQueue.main.async {
                   self?.settingsSwitch.isOn = false
                }
            }
        }
//        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
//            if settings.authorizationStatus == .authorized {
//                DispatchQueue.main.async {
//                    self.settingsSwitch.isOn = true
//                }
//            }
//        }
    }
    
    func fitbitSwitchPreselect() {
        AppSyncManager.instance.healthProfile.addAndNotify(observer: self) { [weak self] in
            DispatchQueue.main.async {
                let profile = AppSyncManager.instance.healthProfile.value
                if let device = profile?.devices?[ExternalDevices.fitbit]  {
                    let connected = device["connected"] == 1
                    self?.settingsSwitch.isOn = connected
                } else {
                    self?.settingsSwitch.isOn = false
                }
            }
            return
        }
    }
    
    func metricSystemPreselect() {
        AppSyncManager.instance.healthProfile.addAndNotify(observer: self) {
            [weak self] in
            if let unit = AppSyncManager.instance.healthProfile.value?.unit {
                switch unit {
                case .metric:
                    DispatchQueue.main.async {
                        self?.settingsSwitch.isOn = true
                    }
                    break
                case .imperial:
                    DispatchQueue.main.async {
                        self?.settingsSwitch.isOn = false
                    }
                    break
                }
            }
        }
    }
}
