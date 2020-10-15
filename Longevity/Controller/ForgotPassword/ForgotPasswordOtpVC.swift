//
//  ForgotPasswordOtpVC.swift
//  Longevity
//
//  Created by vivek on 14/10/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify

class ForgotPasswordOtpVC: UIViewController {
    var username: String?
    
    lazy var descriptionLabel: UILabel =  {
        let label = UILabel(text: "Please input the verification code that was sent as a text message.",
                            font: UIFont(name: AppFontName.medium, size: 18),
                            textColor: .sectionHeaderColor, textAlignment: .center, numberOfLines: 2)
        return label
    }()

    lazy var otpTextField: UITextField = {
        let textField = UITextField(placeholder: "Confirmation Cxode", keyboardType: .emailAddress)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()

    lazy var passwordTextField: UITextField = {
        let textField = UITextField(placeholder: "New Password", keyboardType: .default)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = true
        return textField
    }()

    lazy var ctaButton: CustomButtonFill = {
        let button = CustomButtonFill(title: "Verify", target: self, action: #selector(handleVerify))
        return button
    }()

    lazy var resendButton: UIButton = {
        let button = UIButton(title: "Resend Code", target: self, action: #selector(handleResend))
        button.tintColor = .themeColor
        button.setTitleColor(.themeColor, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Verify Code"
        self.view.backgroundColor = .appBackgroundColor

        view.addSubview(descriptionLabel)
        view.addSubview(passwordTextField)
        view.addSubview(otpTextField)
        view.addSubview(ctaButton)
        view.addSubview(resendButton)


        let descriptionLabelHeight = descriptionLabel.text?.height(withConstrainedWidth: view.frame.width, font: descriptionLabel.font)

        descriptionLabel.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 28, left: 15, bottom: 0, right: 15), size: .init(width: 0, height: descriptionLabelHeight ?? 0))

        passwordTextField.anchor(top: descriptionLabel.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 24, left: 15, bottom: 0, right: 15), size: .init(width: 0, height: 56))

        otpTextField.anchor(top: passwordTextField.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 24, left: 15, bottom: 0, right: 15), size: .init(width: 0, height: 56))

        ctaButton.anchor(top: otpTextField.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 24, left: 15, bottom: 0, right: 15), size: .init(width: 0, height: 48))

        resendButton.anchor(top: ctaButton.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 24, left: 15, bottom: 0, right: 15), size: .init(width: 0, height: 48))

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }

    @objc func closeKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc func handleVerify() {
        self.closeKeyboard()
        guard let username = self.username,
              let newPassword = self.passwordTextField.text?.trimmingCharacters(in: .whitespaces),
              !newPassword.isEmpty,
              let confirmationCode = self.otpTextField.text?.trimmingCharacters(in: .whitespaces),
              !confirmationCode.isEmpty  else {
            self.showAlert(title: "Invalid Values", message: "Please fill all values before proceeding")
            return
        }

        self.showSpinner()

        _ = Amplify.Auth.confirmResetPassword(
               for: username,
               with: newPassword,
               confirmationCode: confirmationCode
           ) { [weak self] result in
               switch result {
               case .success:
                DispatchQueue.main.async {
                    let action = UIAlertAction(title: "Login", style: .default, handler: self?.navigateToLogin(_:))
                    self?.showAlert(title: "Success",
                                    message: "Password has been reset successfully. Please login with the new password to continue",action: action)
                    self?.removeSpinner()
                }
               case .failure(let error):
                   print("Reset password failed with error \(error)")
                DispatchQueue.main.async {
                    self?.showAlert(title: "Password reset failure", message: "failure!!")
                    self?.removeSpinner()
                }
               }
           }
    }

    @objc func handleResend() {
        self.closeKeyboard()
        guard let username = self.username else {
            self.showAlert(title: "Username not found", message: "Please enter the username again in the previous step")
            return}

        self.showSpinner()
        _ = Amplify.Auth.resetPassword(for: username) { [weak self] (result) in
            do {
                let resetResult = try result.get()
                switch resetResult.nextStep {
                case .confirmResetPasswordWithCode(let deliveryDetails, let info):
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Resent OTP", message: "OTP has been sent again to the registered phone number")
                        self?.removeSpinner()
                    }
                    print("Confirm reset password with code send to - \(deliveryDetails) \(info)")
                case .done:
                    print("Reset completed")
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Success", message: "password reset success")
                        self?.removeSpinner()
                    }
                }
            } catch {
                print("Reset password failed with error \(error)")
                DispatchQueue.main.async {
                    self?.showAlert(title: "error", message: "\(error)")
                    self?.removeSpinner()
                }
            }
        }
    }



    @objc func navigateToLogin(_ action: UIAlertAction) {
        if let viewControllers = self.navigationController?.viewControllers {
            self.navigationController?
                .popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        }
    }

}
