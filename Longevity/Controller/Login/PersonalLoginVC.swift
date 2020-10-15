//
//  LoginVC.swift
//  Longevity
//
//  Created by vivek on 02/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify

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
    @IBOutlet weak var loginButton: UIButton!
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
        customizeButtons()
        highlightImageButton(imgButton: personalImageView)
        normalizeImageButton(imgButton: clinicalTrialImageView)
        //        self.removeBackButtonNavigation()
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
    }

    @objc func handleBackgroundTap() {
        self.closeKeyboard()
    }

    func closeKeyboard() {
        self.formEmail.resignFirstResponder()
        self.formPassword.resignFirstResponder()
    }

    func customizeButtons(){
        customizeImageButton(imgButton: personalImageView)
        customizeImageButton(imgButton: clinicalTrialImageView)
    }

    func customizeButtonWithImage(button: UIButton){
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        button.layer.cornerRadius = 10.0
        button.layer.shadowRadius = 1.0
        button.layer.shadowOpacity = 1.0
        button.layer.masksToBounds = false
        button.layer.shadowPath = UIBezierPath(roundedRect: button.bounds, cornerRadius: button.layer.cornerRadius).cgPath
    }

    func customizeImageButton(imgButton: UIView){
        imgButton.layer.masksToBounds = true
        imgButton.layer.borderWidth = 2
        imgButton.layer.cornerRadius = 10
    }

    func highlightImageButton(imgButton: UIView){
        imgButton.layer.borderColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
        imgButton.tintColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
        imgButton.backgroundColor = .white
        for subview in imgButton.subviews{
            if let item = subview as? UIImageView{
                item.image = item.image?.withRenderingMode(.alwaysTemplate)
                item.tintColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
            }
            if let item = subview as? UILabel {
                item.textColor = .themeColor
            }
        }
    }

    func normalizeImageButton(imgButton: UIView){
        imgButton.layer.borderColor = #colorLiteral(red: 0.9176470588, green: 0.9294117647, blue: 0.9450980392, alpha: 1)
        imgButton.tintColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
        imgButton.backgroundColor = .clear
        for subview in imgButton.subviews{
            if let item = subview as? UIImageView{
                item.image = item.image?.withRenderingMode(.alwaysTemplate)
                item.tintColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
            }
            if let item = subview as? UILabel {
                item.textColor = UIColor(hexString: "#212121")
            }
        }
    }

    // MARK: Actions
    @IBAction func handleLogin(_ sender: Any) {

        self.closeKeyboard()
        if let email = self.formEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           let password = self.formPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) {

            func validate() -> Bool {
                if email.isEmpty || !(email.isValidEmail){
                    showAlert(title: "Error - Invalid Email", message: "Please provide a valid email address.")
                    return false
                }
                if password.isEmpty{
                    showAlert(title: "Error - Invalid Password", message: "Password cannot be empty.")
                    return false
                }
                return true
            }

            guard validate() else {
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
                        Amplify.Auth.resendSignUpCode(for: email) { (result) in
                            switch result {
                            case .success(let success):
                                DispatchQueue.main.async {
                                    
                                    self?.removeSpinner()
                                    let storyboard = UIStoryboard(name: "UserLogin", bundle: nil)
                                    guard let signupConfirmVC = storyboard.instantiateViewController(withIdentifier: "SignupConfirmVC") as? SignupConfirmVC else {return}
                                    signupConfirmVC.userEmail = email
                                    self?.navigationController?.pushViewController(signupConfirmVC, animated: true)
                                }
                                print("success", success)
                                return
                            case .failure(let error):
                                DispatchQueue.main.async {
                                    self?.removeSpinner()
                                }
                                return
                            }
                        }
                    } else {
                        self?.doLogin()
                        return
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.removeSpinner()
                        self?.showAlert(title: "Login Failed" , message: error.errorDescription)
                    }
                }
            }
        }
    }

    @IBAction func handleAccountTypeChange(_ sender: UITapGestureRecognizer) {
        self.closeKeyboard()
        let containerView = sender.view! as UIView
        for subview in containerView.subviews{
            if let item = subview as? UILabel{
                print(UserAccountType.personal.rawValue)
                if item.text == UserAccountType.personal.rawValue{
                    highlightImageButton(imgButton: personalImageView)
                    normalizeImageButton(imgButton: clinicalTrialImageView)
                }
            }
        }
    }

    @IBAction func handleSigninWithFacebook(_ sender: Any) {
        self.closeKeyboard()
        self.showSpinner()
        func onSuccess() {
            self.doLogin()
        }

        func onFailure(error: AuthError) {
            print("Sign in failed \(error)")
            DispatchQueue.main.async {
                self.removeSpinner()
                self.showAlert(title: "Login Failed" , message: error.errorDescription)
            }
        }

        _ = Amplify.Auth.signInWithWebUI(for: .facebook, presentationAnchor: self.view.window!) { result in
            switch result {
            case .success(let session):
                onSuccess()
            case .failure(let error):
                onFailure(error: error)
            }
        }
    }

    @IBAction func handleSigninWithGoogle(_ sender: Any) {
        self.closeKeyboard()
        self.showSpinner()
        func onSuccess() {
            self.doLogin()
        }

        func onFailure(error: AuthError) {
            DispatchQueue.main.async {
                self.removeSpinner()
                self.showAlert(title: "Login Failed" , message: error.errorDescription)
            }
        }
        _ = Amplify.Auth.signInWithWebUI(for: .google, presentationAnchor: self.view.window!) { result in
            switch result {
            case .success(_):
                onSuccess()
            case .failure(let error):
                onFailure(error: error)
            }
        }

    }

    @IBAction func handleSigninWithApple(_ sender: Any) {
        self.closeKeyboard()
        self.showSpinner()
        func onSuccess() {
            self.doLogin()
        }
        func onFailure(error: AuthError) {
            DispatchQueue.main.async {
                self.removeSpinner()
                self.showAlert(title: "Login Failed" , message: error.errorDescription)
            }
        }
        _ = Amplify.Auth.signInWithWebUI(for: .apple, presentationAnchor: self.view.window!) { result in
            switch result {
            case .success(_):
                onSuccess()
            case .failure(let error):
                onFailure(error: error)
            }
        }
    }


    @IBAction func unwindToLogin(_ sender: UIStoryboardSegue){
        print("un wound")
        
    }

    @IBAction func handleForgotPassword(_ sender: Any) {
        let destinationVC = ForgotPasswordCaptureEmailVC()
        destinationVC.username = formEmail.text
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }

    
    fileprivate func doLogin() {
        DispatchQueue.main.async {
            self.removeSpinner()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.setRootViewController()
            AppSyncManager.instance.fetchUserNotification()
        }
    }
}
