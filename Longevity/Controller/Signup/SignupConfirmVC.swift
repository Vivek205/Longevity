//
//  SignupConfirmVC.swift
//  Longevity
//
//  Created by vivek on 09/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify

class SignupConfirmVC: UIViewController {
    var userEmail: String?

    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Please input the verification code that was sent as a text message"
        label.font = UIFont(name: AppFontName.medium, size: 18)
        label.textColor = .sectionHeaderColor
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    lazy var otpInput: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.placeholder = "Verification Code"
        textField.clearButtonMode = .whileEditing
        textField.textColor = .textInput
        return textField
    }()

    lazy var verifyButton: CustomButtonFill  = {
        let button = CustomButtonFill()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Verify", for: .normal)
        button.addTarget(self, action: #selector(handleConfirmSignup(_:)), for: .touchUpInside)
        return button
    }()

    lazy var resendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Resend Code", for: .normal)
        button.setTitleColor(.themeColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: AppFontName.regular, size: 18)
        button.addTarget(self, action: #selector(handleResendOTP), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        self.view.backgroundColor = .appBackgroundColor
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        verifyButton.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(infoLabel)
        self.view.addSubview(otpInput)
        self.view.addSubview(verifyButton)
        self.view.addSubview(resendButton)

        let width = self.view.bounds.width
        let infoHeight = infoLabel.text?.height(withConstrainedWidth: width - 30, font: infoLabel.font)

        NSLayoutConstraint.activate([
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            infoLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            infoLabel.heightAnchor.constraint(equalToConstant: infoHeight ?? 48),

            otpInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            otpInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            otpInput.heightAnchor.constraint(equalToConstant: 56),
            otpInput.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 33),

            verifyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            verifyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            verifyButton.topAnchor.constraint(equalTo: otpInput.bottomAnchor, constant: 32),
            verifyButton.heightAnchor.constraint(equalToConstant: 48),

            resendButton.topAnchor.constraint(equalTo: verifyButton.bottomAnchor, constant: 27),
            resendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            resendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
            resendButton.heightAnchor.constraint(equalToConstant: 22)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }

    // MARK: Actions
    @objc func handleConfirmSignup(_ sender: Any) {
        self.closeKeyboard()
        self.showSpinner()
        func onSuccess() {
            DispatchQueue.main.async {
                self.removeSpinner()
                self.performSegue(withIdentifier: "UnwindSignupConfirmToLogin", sender: self)
            }
        }
        guard let email = self.userEmail else {return}
        guard let confirmationCode = self.otpInput.text?.trimmingCharacters(in: .whitespacesAndNewlines), !confirmationCode.isEmpty else {
            self.showAlert(title: "Enter OTP", message: "The OTP field cannot be empty")
            self.removeSpinner()
            return
        }


        DispatchQueue.global().async {
            _ = Amplify.Auth.confirmSignUp(for: email, confirmationCode: confirmationCode) { result in
                switch result {
                case .success(_):
                    print("Confirm signUp succeeded")
                    onSuccess()
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.showAlert(title: "Verify Account Failed", message: error.errorDescription)
                        self.removeSpinner()
                    }
                }
            }
        }
    }

    @objc func handleResendOTP() {
        self.closeKeyboard()
        guard let email = self.userEmail?.trimmingCharacters(in: .whitespacesAndNewlines) else {return}
        self.showSpinner()
        _ = Amplify.Auth.resendSignUpCode(for: email) { (result) in
            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    self.removeSpinner()
                    //                    self.performSegue(withIdentifier: "UnwindSignupConfirmToLogin", sender: self)
                    self.showAlert(title: "Resent OTP", message: "OTP has been resent to your registered phone number")
                }
                print("success", success)
                return
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showAlert(title: "Resend OTP Failed", message: error.errorDescription)
                    self.removeSpinner()
                }
                return
            }
        }
    }

    @objc func closeKeyboard() {
        otpInput.resignFirstResponder()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UnwindSignupConfirmToLogin" {
            if let loginVC = segue.destination as? PersonalLoginVC {
                loginVC.hideBackButton = true
            }
        }
    }
}
