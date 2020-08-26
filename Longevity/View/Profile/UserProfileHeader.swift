//
//  UserProfileHeader.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 18/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

protocol UserProfileHeaderDelegate {
    func selected(profileView: ProfileView)
}

class UserProfileHeader: UITableViewHeaderFooterView {
    
    var delegate: UserProfileHeaderDelegate?
    
    var currentView: ProfileView! {
        didSet {
            self.segmentedControl.removeTarget(self, action: #selector(profileViewSelected), for: .allEvents)
            self.segmentedControl.selectedSegmentIndex = currentView.rawValue
            self.segmentedControl.addTarget(self, action: #selector(profileViewSelected), for: .valueChanged)
            self.headerTitle.isHidden = currentView == .activity
        }
    }
    
    lazy var profileAvatar: UIImageView = {
        let avatar = UIImageView()
        avatar.image = UIImage(named: "userAvatar")
        avatar.contentMode = .scaleAspectFit
        avatar.translatesAutoresizingMaskIntoConstraints = false
        return avatar
    }()
    
    lazy var cameraButton: UIButton = {
        let camera = UIButton()
        camera.setImage(UIImage(named: "avatarCamera"), for: .normal)
        camera.translatesAutoresizingMaskIntoConstraints = false
        return camera
    }()
    
    lazy var userName: UILabel = {
        let username = UILabel()
        username.text = "Greg Kuebler"
        username.font = UIFont(name: "Montserrat-Medium", size: 20.0)
        username.textColor = UIColor.black.withAlphaComponent(0.87)
        username.translatesAutoresizingMaskIntoConstraints = false
        return username
    }()
    
    lazy var userEmail: UILabel = {
        let useremail = UILabel()
        useremail.text = "greg.kuebler@singularitynet.io"
        useremail.font = UIFont(name: "Montserrat-Regular", size: 14.0)
        useremail.textColor = UIColor(hexString: "#9B9B9B")
        useremail.translatesAutoresizingMaskIntoConstraints = false
        return useremail
    }()
    
    lazy var userAccountType: UILabel = {
        let accountType = UILabel()
        accountType.text = "personal account"
        accountType.font = UIFont(name: "Montserrat-Regular", size: 14.0)
        accountType.textColor = UIColor(hexString: "#9B9B9B")
        accountType.translatesAutoresizingMaskIntoConstraints = false
        return accountType
    }()
    
    lazy var profileDetailsStackview: UIStackView = {
        let stackview = UIStackView()
        stackview.addArrangedSubview(self.userName)
        stackview.addArrangedSubview(self.userEmail)
        stackview.addArrangedSubview(self.userAccountType)
        stackview.alignment = .fill
        stackview.distribution = .equalSpacing
        stackview.spacing = 4.0
        stackview.axis = .vertical
        stackview.translatesAutoresizingMaskIntoConstraints = false
        return stackview
    }()
    
    lazy var segmentedControl: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Activity", "Settings"])
        if #available(iOS 13.0, *) {
            segment.selectedSegmentTintColor = .themeColor
        } else {
            segment.tintColor = .themeColor
        }
        
        let titleAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: "Montserrat-Regular", size: 14.0)]
        segment.setTitleTextAttributes(titleAttributes, for: .normal)
        let selectedTitleAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "Montserrat-Regular", size: 14.0)]
        segment.setTitleTextAttributes(selectedTitleAttributes, for: .selected)
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()
    
    lazy var headerTitle: UILabel = {
        let title = UILabel()
        title.text = "COVID DATA"
        title.font = UIFont(name: "Montserrat-Medium", size: 14.0)
        title.textColor = UIColor(hexString: "#4E4E4E")
        title.sizeToFit()
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        addSubview(profileAvatar)
        addSubview(cameraButton)
        addSubview(profileDetailsStackview)
        addSubview(segmentedControl)
        addSubview(headerTitle)
        
        NSLayoutConstraint.activate([
            profileAvatar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15.0),
            profileAvatar.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.35),
            profileAvatar.widthAnchor.constraint(equalTo: profileAvatar.heightAnchor),
            
            cameraButton.heightAnchor.constraint(equalToConstant: 30.0),
            cameraButton.widthAnchor.constraint(equalTo: cameraButton.heightAnchor),
            cameraButton.trailingAnchor.constraint(equalTo: profileAvatar.trailingAnchor),
            cameraButton.bottomAnchor.constraint(equalTo: profileAvatar.bottomAnchor),
            
            profileDetailsStackview.topAnchor.constraint(equalTo: profileAvatar.topAnchor, constant: 10.0),
            profileDetailsStackview.leadingAnchor.constraint(equalTo: profileAvatar.trailingAnchor, constant: 10.0),
            profileDetailsStackview.bottomAnchor.constraint(equalTo: profileAvatar.bottomAnchor),
            profileDetailsStackview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 15.0),
            
            segmentedControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 30.0),
            segmentedControl.widthAnchor.constraint(equalToConstant: 230.0),
            segmentedControl.topAnchor.constraint(equalTo: profileAvatar.bottomAnchor, constant: 20.0),
            
            headerTitle.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20.0),
            headerTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
            headerTitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0)
        ])
        
        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()
        self.userName.text = defaults.string(forKey: keys.name)
        self.userEmail.text = defaults.string(forKey: keys.email)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func profileViewSelected() {
        self.currentView = ProfileView(rawValue: self.segmentedControl.selectedSegmentIndex)
        self.delegate?.selected(profileView: self.currentView)
    }
}
