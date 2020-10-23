//
//  ForgotPasswordCaptureEmailVC.swift
//  Longevity
//
//  Created by vivek on 14/10/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify

class ForgotPasswordCaptureEmailVC: UIViewController {
    var username: String?
    lazy var descriptionLabel: UILabel =  {
        let label = UILabel(text: "A verification code will be sent to your registered mobile phone.",
                            font: UIFont(name: AppFontName.medium, size: 18),
                            textColor: .sectionHeaderColor, textAlignment: .center, numberOfLines: 2)
        return label
    }()

    lazy var emailTextField: UITextField = {
        let textField = UITextField(placeholder: "Email", keyboardType: .emailAddress)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.textContentType = .emailAddress
        return textField
    }()

    lazy var ctaButton: CustomButtonFill = {
        let button = CustomButtonFill(title: "Continue", target: self, action: #selector(handleContinue))
        button.isEnabled = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Forgot Password?"
        self.view.backgroundColor = .appBackgroundColor

        self.view.addSubview(descriptionLabel)
        self.view.addSubview(emailTextField)
        self.view.addSubview(ctaButton)


        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.sectionHeaderColor,
                                    NSAttributedString.Key.font: UIFont(name: AppFontName.semibold, size: 24)]

        let descriptionLabelHeight = descriptionLabel.text?.height(withConstrainedWidth: view.frame.width, font: descriptionLabel.font)

        descriptionLabel.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 28, left: 15, bottom: 0, right: 15), size: .init(width: 0, height: descriptionLabelHeight ?? 0))

        emailTextField.anchor(top: descriptionLabel.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 24, left: 15, bottom: 0, right: 15), size: .init(width: 0, height: 56))

        ctaButton.anchor(top: emailTextField.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 24, left: 15, bottom: 0, right: 15), size: .init(width: 0, height: 48))

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        self.view.addGestureRecognizer(tapGesture)

        if let username = self.username, !username.isEmpty {
            self.emailTextField.text = username
            if username.isValidEmail {
                self.ctaButton.isEnabled = true
            }
        }

        emailTextField.addTarget(self, action: #selector(shouldContinueBeEnabled), for: .editingChanged)
    }

    @objc func closeKeyboard(){
        self.view.endEditing(true)
    }

    @objc func handleContinue() {
        self.closeKeyboard()
        guard let username = emailTextField.text?.trimmingCharacters(in: .whitespaces), !username.isEmpty else {
            Alert(title: "Invalid Email!", message: "Please enter a valid email")
            return
        }
        self.showSpinner()

        _ = Amplify.Auth.resetPassword(for: username) { [weak self] (result) in
            do {
                let resetResult = try result.get()
                switch resetResult.nextStep {
                case .confirmResetPasswordWithCode(let deliveryDetails, let info):
                    DispatchQueue.main.async {
                        self?.removeSpinner()
                        self?.navigateToConfirmPassword(username: username)
                    }
                    print("Confirm reset password with code send to - \(deliveryDetails) \(info)")
                case .done:
                    print("Reset completed")
                    DispatchQueue.main.async {
                        self?.removeSpinner()
                        self?.navigateToConfirmPassword(username: username)
                    }
                }
            } catch {
                print("Reset password failed with error \(error)")
                DispatchQueue.main.async {
                    Alert(title: "Error", message: "\(error)")
                    self?.removeSpinner()
                }
            }
        }
    }

    func navigateToConfirmPassword(username: String) {
        let destinationVC = ForgotPasswordOtpVC()
        destinationVC.username = username
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }

    @objc func shouldContinueBeEnabled() {
        if let text = emailTextField.text,
           !text.isEmpty, text.isValidEmail {
            ctaButton.isEnabled = true
        }else {
            ctaButton.isEnabled = false
        }
    }
}
