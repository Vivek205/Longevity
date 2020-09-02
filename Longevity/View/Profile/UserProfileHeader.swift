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
        camera.addTarget(self, action: #selector(openCameraActionSheet), for: .touchUpInside)
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
    
    lazy var pickerController: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.mediaTypes = ["public.image"]
        return picker
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
        
        AppSyncManager.instance.userProfile.addAndNotify(observer: self) { [weak self] in
            DispatchQueue.main.async {
                self?.userName.text = AppSyncManager.instance.userProfile.value?.name
                self?.userEmail.text = AppSyncManager.instance.userProfile.value?.email
            }
        }
        
        let userProfileAPI = UserProfileAPI()
        userProfileAPI.getUserAvatar(completion: { [weak self] (profileURL) in
            DispatchQueue.main.async {
                if let profileurl = profileURL {
                    self?.profileAvatar.cacheImage(urlString: profileurl)
                }
            }
        }) { (error) in
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.profileAvatar.layer.cornerRadius = self.profileAvatar.bounds.height / 2
        self.profileAvatar.clipsToBounds = true
    }
    
    @objc func profileViewSelected() {
        self.currentView = ProfileView(rawValue: self.segmentedControl.selectedSegmentIndex)
        self.delegate?.selected(profileView: self.currentView)
    }
    
    @objc func openCameraActionSheet() {
        let cameraActionSheet: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            
        }
        cameraActionSheet.addAction(cancelActionButton)

        let cameraActionButton = UIAlertAction(title: "Take a selfie", style: .default)
            { _ in
                self.pickerController.sourceType = .camera
                NavigationUtility.presentOverCurrentContext(destination: self.pickerController, style: .fullScreen)
        }
        cameraActionSheet.addAction(cameraActionButton)

        let albumActionButton = UIAlertAction(title: "Camera roll", style: .default)
            { _ in
                self.pickerController.sourceType = .savedPhotosAlbum
                NavigationUtility.presentOverCurrentContext(destination: self.pickerController)
        }
        cameraActionSheet.addAction(albumActionButton)
        
        let photoActionButton = UIAlertAction(title: "Photo library", style: .default)
            { _ in
                self.pickerController.sourceType = .photoLibrary
                NavigationUtility.presentOverCurrentContext(destination: self.pickerController)
        }
        cameraActionSheet.addAction(photoActionButton)
        NavigationUtility.presentOverCurrentContext(destination: cameraActionSheet, style: .custom, completion: nil)
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        
        self.profileAvatar.image = image
        
        guard let imageData = image?.jpegData(compressionQuality: 0.05) else { return }
       
        //TODO: Integrate the API to save and also retrieve the profile pic
        let userProfileAPI = UserProfileAPI()
        userProfileAPI.saveUserAvatar(profilePic: imageData.base64EncodedString(), completion: {
            print("Avatar is saved")
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}

extension UserProfileHeader: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}
