//
//  EditAccountViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 27/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

fileprivate let appSyncManager:AppSyncManager = AppSyncManager.instance

class EditAccountViewController: UIViewController {
    var modalPresentation = false
    var changesSaved = true
    
    lazy var nameLabel: UILabel = {
        let name = UILabel()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.text = "Name"
        name.textColor = UIColor(hexString: "#212121")
        name.font = UIFont(name: "Montserrat-Regular", size: 12.0)
        name.backgroundColor = UIColor(hexString: "#F5F6FA")
        name.sizeToFit()
        return name
    }()
    
    lazy var fullName: UITextField = {
        let name = UITextField()
        name.font = UIFont(name: "Montserrat-Regular", size: 16.0)
        name.clearButtonMode = .whileEditing
        name.textContentType = .name
        name.tag = 1
        name.placeholder = "Full Name"
        name.textColor = UIColor(hexString: "#212121")
        name.autocorrectionType = .no
        name.returnKeyType = .done
        name.borderStyle = .roundedRect
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }()
    
    lazy var emailLabel: UILabel = {
        let email = UILabel()
        email.translatesAutoresizingMaskIntoConstraints = false
        email.text = "Email"
        email.textColor = UIColor(hexString: "#212121")
        email.font = UIFont(name: "Montserrat-Regular", size: 12.0)
        email.backgroundColor = UIColor(hexString: "#F5F6FA")
        email.sizeToFit()
        return email
    }()
    
    lazy var emailText: UITextField = {
        let email = UITextField()
        email.font = UIFont(name: "Montserrat-Regular", size: 16.0)
        email.clearButtonMode = .whileEditing
        email.textContentType = .emailAddress
        email.placeholder = "Email address"
        email.borderStyle = .roundedRect
        email.textColor = UIColor(hexString: "#999999")
        email.backgroundColor = UIColor(hexString: "#F1F1F1")
        email.isEnabled = false
        email.translatesAutoresizingMaskIntoConstraints = false
        return email
    }()
    
    lazy var emailInfoLabel: UILabel = {
        let emailInfo = UILabel()
        emailInfo.translatesAutoresizingMaskIntoConstraints = false
        emailInfo.text = "Please Note:  Your email can not be edited or changed. "
        emailInfo.textColor = UIColor(hexString: "#9B9B9B")
        emailInfo.font = UIFont(name: "Montserrat-Italic", size: 12.0)
        emailInfo.backgroundColor = .clear
        emailInfo.sizeToFit()
        return emailInfo
    }()
    
    lazy var mobileLabel: UILabel = {
        let mobile = UILabel()
        mobile.translatesAutoresizingMaskIntoConstraints = false
        mobile.text = "Mobile Phone"
        mobile.textColor = UIColor(hexString: "#212121")
        mobile.font = UIFont(name: "Montserrat-Regular", size: 12.0)
        mobile.backgroundColor = UIColor(hexString: "#F5F6FA")
        mobile.sizeToFit()
        return mobile
    }()
    
    lazy var mobilePhone: UITextField = {
        let mobile = UITextField()
        mobile.font = UIFont(name: "Montserrat-Regular", size: 16.0)
        mobile.textColor = UIColor(hexString: "#212121")
        mobile.clearButtonMode = .whileEditing
        mobile.textContentType = .telephoneNumber
        mobile.placeholder = "Mobile Phone"
        mobile.tag = 2
        mobile.autocorrectionType = .no
        mobile.returnKeyType = .done
        mobile.borderStyle = .roundedRect
        mobile.translatesAutoresizingMaskIntoConstraints = false
        return mobile
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(hexString: "#F5F6FA")

        self.view.addSubview(fullName)
        self.view.addSubview(nameLabel)
        self.view.addSubview(emailText)
        self.view.addSubview(emailLabel)
        self.view.addSubview(emailInfoLabel)
        self.view.addSubview(mobilePhone)
        self.view.addSubview(mobileLabel)
        
        let vTop: CGFloat = UIDevice.hasNotch ? 100.0 : 60.0
        
        NSLayoutConstraint.activate([
            fullName.topAnchor.constraint(equalTo: self.view.topAnchor, constant: vTop),
            fullName.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15.0),
            fullName.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15.0),
            fullName.heightAnchor.constraint(equalToConstant: 56.0),
            nameLabel.leadingAnchor.constraint(equalTo: fullName.leadingAnchor, constant: 20.0),
            nameLabel.centerYAnchor.constraint(equalTo: fullName.topAnchor),
            emailText.topAnchor.constraint(equalTo: fullName.bottomAnchor, constant: 30.0),
            emailText.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15.0),
            emailText.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15.0),
            emailText.heightAnchor.constraint(equalToConstant: 56.0),
            emailLabel.leadingAnchor.constraint(equalTo: emailText.leadingAnchor, constant: 20.0),
            emailLabel.centerYAnchor.constraint(equalTo: emailText.topAnchor),
            emailInfoLabel.leadingAnchor.constraint(equalTo: emailText.leadingAnchor),
            emailInfoLabel.topAnchor.constraint(equalTo: emailText.bottomAnchor, constant: 10.0),
            emailInfoLabel.trailingAnchor.constraint(equalTo: emailText.trailingAnchor),
            mobilePhone.topAnchor.constraint(equalTo: emailInfoLabel.bottomAnchor, constant: 30.0),
            mobilePhone.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15.0),
            mobilePhone.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15.0),
            mobilePhone.heightAnchor.constraint(equalToConstant: 56.0),
            mobileLabel.leadingAnchor.constraint(equalTo: mobilePhone.leadingAnchor, constant: 20.0),
            mobileLabel.centerYAnchor.constraint(equalTo: mobilePhone.topAnchor)
        ])
        
        let titleLabel = UILabel()
        titleLabel.text = "Edit Account"
        titleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 17.0)
        titleLabel.textColor = UIColor(hexString: "#4E4E4E")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.navigationItem.titleView = titleLabel
        let leftbutton = UIBarButtonItem(title:"Cancel", style: .plain, target: self, action: #selector(closeView))
        leftbutton.tintColor = .themeColor
        let rightButton = UIBarButtonItem(title:"Save", style: .plain, target: self, action: #selector(doneUpdate))
        rightButton.tintColor = .themeColor
        self.navigationItem.leftBarButtonItem = leftbutton
        self.navigationItem.rightBarButtonItem = rightButton
        
        self.fullName.delegate = self
        self.mobilePhone.delegate = self

        appSyncManager.userProfile.addAndNotify(observer: self) {
            guard let userProfile = appSyncManager.userProfile.value else {return}
            DispatchQueue.main.async {
                [weak self] in
                self?.fullName.text = userProfile.name
                self?.emailText.text = userProfile.email
                self?.mobilePhone.text = userProfile.phone
            }

        }

        if self.modalPresentation {
            if #available(iOS 13.0, *) {
                self.isModalInPresentation = true
                print("delegate", self.navigationController?.presentationController?.delegate)
                self.navigationController?.presentationController?.delegate = self
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    @objc func closeView() {
        if changesSaved {
            self.dismiss(animated: true, completion: nil)
            return
        }
        let alertVC = UIAlertController(title: "Discard changes", message: "Are you sure to discard all your unsaved changes?", preferredStyle: .actionSheet)
        let dismiss = UIAlertAction(title: "dismiss", style: .destructive) {[weak self] (action) in
            self?.dismiss(animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "cancel", style: .default) {[weak self] (action) in
//            self?.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(dismiss)
        alertVC.addAction(cancel)
        self.present(alertVC, animated: true, completion: nil)
    }

    @objc func doneUpdate() {
        if let name = fullName.text {
            appSyncManager.userProfile.value?.name = name
        }
        if let phone = mobilePhone.text {
            appSyncManager.userProfile.value?.phone = phone
        }
        updateProfile()
        self.dismiss(animated: true, completion: nil)
    }
}

extension EditAccountViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.changesSaved = false
    }
}

extension EditAccountViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        self.closeView()
    }

    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return true
    }
}
