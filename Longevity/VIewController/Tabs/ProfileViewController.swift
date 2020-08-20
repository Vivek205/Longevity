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

class ProfileViewController: BaseViewController {
    var userActivities: [UserActivity]?
    
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
            self.profileTableView.reloadData()
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userActivities?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let activityCell = tableView.getCell(with: ProfileActivityCell.self, at: indexPath) as? ProfileActivityCell else {
            preconditionFailure("Invalid activity cell")
        }
        var activity:UserActivity?
        if let userActivities = self.userActivities {
            if userActivities.count > indexPath.row {
                activity = userActivities[indexPath.row]
            }
        }
        activityCell.activity = activity
        return activityCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            guard let headerView = tableView.getHeader(with: UITableViewHeaderFooterView.self, index: section) else {
                preconditionFailure("Invalid header view")
            }
            
            let header = UserProfileHeader()
            header.currentView = self.currentProfileView
            header.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(header)
            
            NSLayoutConstraint.activate([
                header.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10.0),
                header.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10.0),
                header.topAnchor.constraint(equalTo: headerView.topAnchor),
                header.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -10.0)
            ])
            
            return headerView
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            let heightFactor: CGFloat = UIDevice.hasNotch ? 0.25 : 0.35
            let height = tableView.bounds.height * heightFactor
            return height
        } else {
            return 40.0
        }
    }
}
