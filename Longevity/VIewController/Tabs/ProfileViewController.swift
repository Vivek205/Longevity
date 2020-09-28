//
//  ProfileViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 06/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

enum ProfileView: Int {
    case activity =  0
    case settings
}

enum SettingAccessory: Int {
    case navigate = 0
    case addcontrol
    case switchcontrol
    case none
}

enum SettingPosition {
    case topmost
    case center
    case bottom
}

enum ProfileSetting: String {
    case exportcheckin = "Export Check-in Data"
    case updatebiometrics = "Update Biometrics"
    case updatepreconditions = "Update Pre-conditions"
    case resetcheckin = "Reset Check-in Data"
    case applehealth = "Apple Health"
    case fitbit = "Fitbit"
    case applewatch = "Apple Watch"
    case notifications = "Notifications"
    case editaccount = "Edit Account Details"
    case usemetricsystem = "Use Metric System"
    case faqs = "FAQ"
    case termsofservice = "Terms of Service"
    case contactsupport = "Contact Support"
    case signout = "signout"
    case appversion = "appversion"
}

extension ProfileSetting {
    var settingAccessory: SettingAccessory {
        switch self {
        case .exportcheckin: return .navigate
        case .updatebiometrics: return .navigate
        case .updatepreconditions: return .navigate
        case .resetcheckin: return .navigate
        case .applehealth: return .navigate
        case .fitbit: return .switchcontrol
        case .applewatch: return .addcontrol
        case .notifications: return .switchcontrol
        case .editaccount: return .navigate
        case .usemetricsystem: return .switchcontrol
        case .faqs: return .navigate
        case .termsofservice: return .navigate
        case .contactsupport: return .navigate
        default: return .none
        }
    }
    
    var settingPosition: SettingPosition {
        switch self {
        case .exportcheckin: return .topmost
        case .updatebiometrics: return .center
        case .updatepreconditions: return .center
        case .resetcheckin: return .bottom
        case .applehealth: return .topmost
        case .fitbit: return .center
        case .applewatch: return .bottom
        case .notifications: return .topmost
        case .editaccount: return .center
        case .usemetricsystem: return .bottom
        case .faqs: return .topmost
        case .termsofservice: return .center
        case .contactsupport: return .bottom
        default: return .center
        }
    }
}

class ProfileViewController: BaseViewController {
    
    var userActivities: [UserActivity]! {
        didSet {
            DispatchQueue.main.async {
                self.profileTableView.reloadData()
            }
        }
    }
    
    var settings: [[ProfileSetting]] = [[.exportcheckin,.updatebiometrics,.updatepreconditions, .resetcheckin],
                                        [.applehealth, .fitbit, .applewatch],
                                        [.notifications, .editaccount, .usemetricsystem],
                                        [.faqs, .termsofservice, .contactsupport],
                                        [.signout], [.appversion]]
    var settingsSections: [String] = ["COVID DATA", "DEVICE CONNECTIONS", "ACCOUNT", "INFORMATION", "",""]
    
    lazy var profileTableView: UITableView = {
        let profileTable = UITableView(frame: CGRect.zero, style: .grouped)
        profileTable.backgroundColor = .clear
        profileTable.separatorStyle = .none
        profileTable.delegate = self
        profileTable.dataSource = self
        profileTable.translatesAutoresizingMaskIntoConstraints = false
        return profileTable
    }()
    
    var currentProfileView: ProfileView! {
        didSet {
            self.titleView.titleLabel.text = currentProfileView == ProfileView.activity ? "Profile Activity" : "Settings"
            
            if currentProfileView == ProfileView.activity {
                self.getProfileData()
            }
            else {
                self.profileTableView.reloadData()
            }
        }
    }
    
    init() {
        super.init(viewTab: .profile)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(profileTableView)
        
        NSLayoutConstraint.activate([
            profileTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            profileTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            profileTableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            profileTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        self.currentProfileView = .activity
        getProfileData()
    }
    
    func getProfileData() {
        let userProfileAPI = UserProfileAPI()
        userProfileAPI.getUserActivities(completion: { (userActivites) in
            self.userActivities = userActivites
        }, onFailure:  { (error) in
            print(error)
        })
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.currentProfileView == .activity {
            return 1
        } else {
            return self.settingsSections.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.currentProfileView == .activity {
            return self.userActivities?.count ?? 0
        } else {
            return self.settings[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.currentProfileView == .activity {
            guard let activityCell = tableView.getCell(with: ProfileActivityCell.self, at: indexPath) as? ProfileActivityCell else {
                preconditionFailure("Invalid activity cell")
            }
            var activity:UserActivity?
            if let userActivities = self.userActivities {
                if userActivities.count > indexPath.row {
                    activity = userActivities[indexPath.row]
                }
                
                if indexPath.row == userActivities.count - 1 {
                    activity?.isLast = true
                }
            }
            activityCell.activity = activity
            return activityCell
        } else {
            if indexPath.section < (self.settingsSections.count - 2) {
                guard let settingsCell = tableView.getCell(with: ProfileSettingsCell.self, at: indexPath) as? ProfileSettingsCell else {
                    preconditionFailure("Invalid activity cell")
                }
                settingsCell.delegate = self
                settingsCell.profileSetting = self.settings[indexPath.section][indexPath.row]
                return settingsCell
            } else if indexPath.section == (self.settingsSections.count - 2) {
                guard let signoutCell = tableView.getCell(with: SignOutCell.self, at: indexPath) as? SignOutCell else {
                    preconditionFailure("Invalid activity cell")
                }
                signoutCell.selectionStyle = .none
                return signoutCell
            } else {
                guard let appversioncell = tableView.getCell(with: AppVersionCell.self, at: indexPath) as? AppVersionCell else {
                    preconditionFailure("Invalid activity cell")
                }
                appversioncell.selectionStyle = .none
                return appversioncell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.currentProfileView == .activity {
            return 80.0
        } else {
            if indexPath.section < (self.settingsSections.count - 1) {
                return 50.0
            } else {
                return 60.0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            guard let headerView = tableView.getHeader(with: UserProfileHeader.self, index: section) as? UserProfileHeader else {
                preconditionFailure("Invalid header view")
            }
            headerView.currentView = self.currentProfileView
            headerView.delegate = self
            
            return headerView
        } else {
            guard let header = tableView.getHeader(with: UITableViewHeaderFooterView.self, index: section) else {
                preconditionFailure("Invalid header view")
            }
            
            header.backgroundColor = .clear
            
            let title = UILabel()
            title.text = self.settingsSections[section]
            title.font = UIFont(name: "Montserrat-Medium", size: 14.0)
            title.textColor = UIColor(hexString: "#4E4E4E")
            title.sizeToFit()
            title.translatesAutoresizingMaskIntoConstraints = false
            
            header.addSubview(title)
            
            NSLayoutConstraint.activate([
                title.centerYAnchor.constraint(equalTo: header.centerYAnchor),
                title.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 10.0)
            ])
            
            return header
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            let heightFactor: CGFloat = UIDevice.hasNotch ? 0.30 : 0.40
            let height = tableView.bounds.height * heightFactor
            return height
        } else {
            return 40.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if self.currentProfileView != .activity {
            if tableView.cellForRow(at: indexPath) is ProfileSettingsCell {
                guard let cell = tableView.cellForRow(at: indexPath) as? ProfileSettingsCell else {
                    preconditionFailure("Invalid settings cell")
                }
                
                switch cell.profileSetting {
                case .exportcheckin:
                    let exportCheckinViewController = ExportCheckinDataViewController()
                    NavigationUtility.presentOverCurrentContext(destination: exportCheckinViewController, style: .overCurrentContext, transitionStyle: .crossDissolve, completion: nil)
                case .updatebiometrics:
                    let storyboard = UIStoryboard(name: "ProfileSetup", bundle: nil)
                    guard let biometricsViewController = storyboard.instantiateViewController(withIdentifier: "SetupProfileBioDataVC") as? SetupProfileBioDataVC else { return }
                    biometricsViewController.isFromSettings = true
                    biometricsViewController.modalPresentation = true
                    let navigationController = UINavigationController(rootViewController: biometricsViewController)
                    NavigationUtility.presentOverCurrentContext(destination: navigationController)
                case .updatepreconditions:
                    let storyboard = UIStoryboard(name: "ProfileSetup", bundle: nil)
                    guard let preconditionsViewController = storyboard.instantiateViewController(withIdentifier: "SetupProfilePreExistingConditionVC") as? SetupProfilePreConditionVC else { return }
                    preconditionsViewController.isFromSettings = true
                    preconditionsViewController.modalPresentation = true
                    let navigationController = UINavigationController(rootViewController: preconditionsViewController)
                    navigationController
                    NavigationUtility.presentOverCurrentContext(destination: navigationController )
                case .resetcheckin:
                    let resetCheckinViewController = ResetCheckInDataViewController()
                    NavigationUtility.presentOverCurrentContext(destination: resetCheckinViewController, style: .overCurrentContext, transitionStyle: .crossDissolve, completion: nil)
                case .applehealth:
                    let appleHealthViewController = AppleHealthConnectionViewController()
                    let navigationController = UINavigationController(rootViewController: appleHealthViewController)
                    NavigationUtility.presentOverCurrentContext(destination: navigationController)
                    
                case .fitbit: return
                case .applewatch:
                    let applewatchViewController = AppleWatchConnectViewController()
                    let navigationController = UINavigationController(rootViewController: applewatchViewController)
                    NavigationUtility.presentOverCurrentContext(destination: navigationController)
                case .notifications:
                    //                    openSettings()
                    return
                case .editaccount:
                    let editAccountViewController = EditAccountViewController()
                    editAccountViewController.modalPresentation = true
                    let navigationController = UINavigationController(rootViewController: editAccountViewController)
                    NavigationUtility.presentOverCurrentContext(destination: navigationController )
                case .usemetricsystem:
                    return
                case .faqs:
                    let faqViewController = FAQViewController()
                    NavigationUtility.presentOverCurrentContext(destination: faqViewController,
                                                                style: .overCurrentContext,
                                                                transitionStyle: .crossDissolve,
                                                                completion: nil)
                    return
                case .termsofservice:
                    let storyboard = UIStoryboard(name: "ProfileSetup", bundle: nil)
                    guard let tosViewController = storyboard.instantiateViewController(withIdentifier: "TermsOfServiceVC") as? TermsOfServiceVC else { return }
                    tosViewController.isFromSettings = true
                    let navigationController = UINavigationController(rootViewController: tosViewController)
                    NavigationUtility.presentOverCurrentContext(destination: navigationController )
                    
                case .contactsupport:
                    let contactSupportViewController = ContactSupportViewController()
                    let navigationController = UINavigationController(rootViewController: contactSupportViewController)
                    NavigationUtility.presentOverCurrentContext(destination: navigationController)
                    return
                default: return
                }
            }
        }
    }
}

extension ProfileViewController: UserProfileHeaderDelegate {
    func selected(profileView: ProfileView) {
        self.currentProfileView = profileView
    }
    
    func openSettings() {
        if let appSettings = NSURL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings as URL, options: [:], completionHandler: nil)
        }
    }
}


extension ProfileViewController: ProfileSettingsCellDelegate {
    func switchToggled(onCell cell: ProfileSettingsCell,newState isOn: Bool) {
        print("switch toggled on cell", cell)
        switch cell.profileSetting {
        case .notifications:
            handleNotificationSwitch(newState: isOn)
            return
        case .fitbit:
            handleFitbitSwitch(newState: isOn)
            return
        case .usemetricsystem:
            handleMetricSystemSwitch()
        default:
            return
        }
    }
    
    func handleMetricSystemSwitch() {
        HealthKitUtil.shared.toggleSelectedUnit()
        updateHealthProfile()
    }
    
    func handleFitbitSwitch(newState isOn: Bool) {
        let connected = isOn ? 1 : 0
        let fitbitModel = FitbitModel()
        
        if isOn  {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                if settings.authorizationStatus == .authorized {
                    DispatchQueue.main.async {
                        if let context = UIApplication.shared.keyWindow {
                            fitbitModel.contextProvider = AuthContextProvider(context)
                        }
                        fitbitModel.auth { authCode, error in
                            if error != nil {
                                print("Auth flow finished with error \(String(describing: error))")
                                AppSyncManager.instance.updateHealthProfile(deviceName: ExternalDevices.fitbit, connected: 0)
                            } else {
                                
                                fitbitModel.token(authCode: authCode!)
                                AppSyncManager.instance.updateHealthProfile(deviceName: ExternalDevices.fitbit, connected: 1)
                            }
                        }
                    }
                    
                    return
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Enable Notification",
                                       message: "Please enable notification to connect the fitbit device")
                        AppSyncManager.instance.updateHealthProfile(deviceName: ExternalDevices.fitbit, connected: 0)
                    }
                }
            }
            
        } else {
            AppSyncManager.instance.updateHealthProfile(deviceName: ExternalDevices.fitbit, connected: 0)
        }
    }
    
    func handleNotificationSwitch(newState isOn: Bool) {
        func registerForPushNotifications() {
            UNUserNotificationCenter.current() // 1
                .requestAuthorization(options: [.alert, .sound, .badge]) { // 2
                    [weak self] granted, error in
                    print("Permission granted: \(granted), error: \(error)")
                    guard granted else {
                        DispatchQueue.main.async {
                            self?.openSettings()
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
        }
        
        if isOn {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                if settings.authorizationStatus == .authorized {
                    AppSyncManager.instance.updateUserNotification(enabled: true)
                    return
                }
                registerForPushNotifications()
            }
        }else {
            AppSyncManager.instance.updateUserNotification(enabled: false)
        }
    }
}

extension ProfileViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        print("should dismiss")
        return true
    }
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        print("did attempt to dismiss")
    }
}
