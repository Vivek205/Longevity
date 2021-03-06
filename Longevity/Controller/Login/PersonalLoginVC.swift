//
//  LoginVC.swift
//  Longevity
//
//  Created by vivek on 02/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify
import AWSPluginsCore
import SwiftyJSON

class PersonalLoginVC: UIViewController {
    var hideBackButton:Bool? {
        didSet {
            self.removeBackButtonNavigation()
        }
    }
    var username = ""
    
    // MARK: Outlets
    @IBOutlet weak var formEmail: UITextField!
    @IBOutlet weak var formPassword: UITextField!
    @IBOutlet weak var parentStackContainer: UIStackView!
    @IBOutlet weak var loginButton: CustomButtonFill!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var personalImageView: UIView!
    @IBOutlet weak var clinicalTrialImageView: UIView!
    @IBOutlet weak var orLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hexString: "#F5F6FA")
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "#F5F6FA")
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 24.0)!,
                                                                        NSAttributedString.Key.foregroundColor: UIColor(hexString: "#4E4E4E")]

        personalImageView.removeFromSuperview()
        clinicalTrialImageView.removeFromSuperview()
        parentStackContainer.removeArrangedSubview(parentStackContainer.arrangedSubviews[0])
        parentStackContainer.removeArrangedSubview(parentStackContainer.arrangedSubviews[0])
        
        self.orLabel.backgroundColor = UIColor(hexString: "#F5F6FA")

        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))

        self.view.addGestureRecognizer(backgroundTapGesture)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.customizeButtonWithImage(button: loginButton)
        self.customizeButtonWithImage(button: appleButton)
        self.customizeButtonWithImage(button: googleButton)
        self.customizeButtonWithImage(button: facebookButton)

        self.loginButton.cornerRadius = 10.0
    }

    @objc func handleBackgroundTap() {
        self.closeKeyboard()
    }

    func closeKeyboard() {
        self.formEmail.resignFirstResponder()
        self.formPassword.resignFirstResponder()
    }


    func customizeButtonWithImage(button: UIButton){
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        button.layer.cornerRadius = 10.0
        button.layer.shadowRadius = 1.0
        button.layer.shadowOpacity = 1.0
        button.layer.masksToBounds = false
        button.layer.shadowPath = UIBezierPath(roundedRect: button.bounds,
                                               cornerRadius: button.layer.cornerRadius).cgPath
    }

    // MARK: Actions
    @IBAction func handleLogin(_ sender: Any) {
        self.closeKeyboard()
        if let email = self.formEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           let password = self.formPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) {

            guard validate(email: email, password: password) else {
                return
            }

            self.showSpinner()

            _ = Amplify.Auth.signIn(username: email, password: password) {[weak self] result in
                print("result", result)
                switch result {
                case .success(let success):
                    print("success data", success.nextStep)
                    if case let .confirmSignUp(deliveryDetails) = success.nextStep {
                        print("Delivery details \(String(describing: deliveryDetails))")
                        self?.sendSignUpCode(email: email)
                    } else {
                        _ = Amplify.Auth.fetchAuthSession { result in
                            guard let session = try? result.get() as? AuthCognitoTokensProvider,
                                  let tokens = try? session.getCognitoTokens().get() else {
                                return
                            }
                            do{
                                try KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.idToken).saveItem(tokens.idToken)
                                self?.loginToHome()
                            } catch {
                                Alert(title: "Login Failed" , message: error.localizedDescription)
                            }
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.removeSpinner()
                        Alert(title: "Login Failed" , message: error.errorDescription)
                    }
                }
            }
        }
    }
    
    fileprivate func sendSignUpCode(email: String) {
        Amplify.Auth.resendSignUpCode(for: email) { (result) in
            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    self.removeSpinner()
                    let storyboard = UIStoryboard(name: "UserLogin", bundle: nil)
                    guard let signupConfirmVC = storyboard.instantiateViewController(withIdentifier: "SignupConfirmVC") as? SignupConfirmVC else {return}
                    signupConfirmVC.userEmail = email
                    self.navigationController?.pushViewController(signupConfirmVC, animated: true)
                }
                print("success", success)
                return
            case .failure(let error):
                print("Login failed, ", error.localizedDescription)
                DispatchQueue.main.async {
                    self.removeSpinner()
                }
                return
            }
        }
    }
    
    fileprivate func validate(email: String, password: String) -> Bool {
        if email.isEmpty || !(email.isValidEmail){
            Alert(title: "Error - Invalid Email", message: "Please provide a valid email address.")
            return false
        }
        if password.isEmpty{
            Alert(title: "Error - Invalid Password", message: "Password cannot be empty.")
            return false
        }
        return true
    }

    @IBAction func handleAccountTypeChange(_ sender: UITapGestureRecognizer) {
        self.closeKeyboard()
    }

    @IBAction func handleSigninWithFacebook(_ sender: Any) {
        self.closeKeyboard()
        self.showSpinner()
        _ = Amplify.Auth.signInWithWebUI(for: .facebook, presentationAnchor: self.view.window!, options: .preferPrivateSession(), listener: authHandler)
    }

    @IBAction func handleSigninWithGoogle(_ sender: Any) {
        self.closeKeyboard()
        self.showSpinner()
        _ = Amplify.Auth.signInWithWebUI(for: .google, presentationAnchor: self.view.window!, options: .preferPrivateSession(), listener: authHandler)
    }

    @IBAction func handleSigninWithApple(_ sender: Any) {
        self.closeKeyboard()
        self.showSpinner()
        _ = Amplify.Auth.signInWithWebUI(for: .apple, presentationAnchor: self.view.window!, options: .preferPrivateSession(), listener: authHandler)
    }

    @IBAction func unwindToLogin(_ sender: UIStoryboardSegue){
        print("un wound")
        
    }

    @IBAction func handleForgotPassword(_ sender: Any) {
        let destinationVC = ForgotPasswordCaptureEmailVC()
        destinationVC.username = formEmail.text
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }

    func authHandler(result :
                        AmplifyOperation<AuthWebUISignInRequest, AuthSignInResult, AuthError>.OperationResult) -> Void {
        switch result {
        case .success( _):
              DispatchQueue.main.async {
                self.removeSpinner()
              }
            UserAuthAPI.shared.fetchAuthentication { (success, error) in
                if success {
                    self.loginToHome()
                } else {
                    if let error = error {
                        Alert(title: "Login Failed" , message: error.localizedDescription)
                    } else {
                        Alert(title: "Login Failed" , message: "Please reach out the support team")
                    }
                }
            }
        case .failure(let error):
            DispatchQueue.main.async {
                self.removeSpinner()
                Alert(title: "Login Failed" , message: error.errorDescription)
            }
        }
    }
    
    fileprivate func loginToHome() {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            appDelegate.setRootViewController()
        }
    }
}
