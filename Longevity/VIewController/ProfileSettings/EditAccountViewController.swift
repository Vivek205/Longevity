//
//  EditAccountViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 27/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import PhoneNumberKit
import CountryPickerView

fileprivate let appSyncManager:AppSyncManager = AppSyncManager.instance
fileprivate let phoneNumberKit = PhoneNumberKit()

class EditAccountViewController: UIViewController {
    var modalPresentation = false
    var changesSaved = true
    var savedCountryCode:String?

    lazy var countryPickerView: CountryPickerView = {
        let cpv = CountryPickerView(frame: .init(x: 8, y: 0, width: 120, height: 120))
        cpv.dataSource = self
        cpv.font = UIFont(name: AppFontName.semibold, size: 16) ?? UIFont()
        cpv.textColor = .themeColor
        cpv.accessibilityViewIsModal = true
        return cpv
    }()
    
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

        let padding = 8
        let size = 120
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: size+padding, height: size) )
        leftView.addSubview(countryPickerView)
        countryPickerView.fillSuperview(padding: .init(top: 0, left: 10, bottom: 0, right: 0))
        mobile.leftView = leftView
        mobile.leftViewMode = .always
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

                let phoneNumber = userProfile.phone

                let parsedPhoneNumber = try? phoneNumberKit.parse(phoneNumber)

                if let countryCode = parsedPhoneNumber?.regionID,
                   let number = parsedPhoneNumber?.nationalNumber{
                    self?.countryPickerView.setCountryByCode(countryCode)
                    self?.mobilePhone.text = "\(number)"
                    self?.savedCountryCode = self?.countryPickerView.selectedCountry.phoneCode
                }
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
        print(self.savedCountryCode)
        print(self.countryPickerView.selectedCountry.phoneCode)
        print(self.savedCountryCode == self.countryPickerView.selectedCountry.phoneCode)
        if changesSaved && self.savedCountryCode == self.countryPickerView.selectedCountry.phoneCode {
            self.dismiss(animated: true, completion: nil)
            return
        }

//        do {
//            guard let phone = mobilePhone.text else { }
//            try phoneNumberKit.parse("\(countryPickerView.selectedCountry.phoneCode)\(phone)")
//        } catch  {
//            <#statements#>
//        }

        let alertVC = UIAlertController(title: nil, message: "You have unsaved changes", preferredStyle: .actionSheet)
        let saveChanges = UIAlertAction(title: "Save Changes", style: .default) { [weak self] (action) in
            self?.doneUpdate()
        }
        saveChanges.setValue(UIColor.themeColor, forKey: "titleTextColor")
        let dismiss = UIAlertAction(title: "Discard", style: .destructive) {[weak self] (action) in
            self?.dismiss(animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        cancel.setValue(UIColor.themeColor, forKey: "titleTextColor")
        alertVC.addAction(saveChanges)
        alertVC.addAction(dismiss)
        alertVC.addAction(cancel)
        self.present(alertVC, animated: true, completion: nil)
    }

    @objc func doneUpdate() {
        if let name = fullName.text {
            appSyncManager.userProfile.value?.name = name
        }
        if let phone = mobilePhone.text {
            do {
                try phoneNumberKit.parse("\(countryPickerView.selectedCountry.phoneCode)\(phone)")
                appSyncManager.userProfile.value?.phone = "\(countryPickerView.selectedCountry.phoneCode)\(phone)"
            } catch  {
                print("phone number error", error)
                Alert(title: "Invalid Phone Number", message: "The phone number you have entered is not valid. Please enter a valid phone number")
                return
            }

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

extension EditAccountViewController: CountryPickerViewDataSource {
    func showPhoneCodeInList(in countryPickerView: CountryPickerView) -> Bool {
        return true
    }

    func navigationTitle(in countryPickerView: CountryPickerView) -> String? {
        return "Select Country"
    }

    func searchBarPosition(in countryPickerView: CountryPickerView) -> SearchBarPosition {
        return .hidden
    }
}

