//
//  SignupVC.swift
//  Longevity
//
//  Created by vivek on 02/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify
import AmplifyPlugins

class SignupVC: UIViewController {

    // MARK: outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var personalUseImageButton: UIImageView!
    @IBOutlet weak var clinicalTrialImageButton: UIImageView!

    @IBOutlet weak var personalImageView: UIView!
    @IBOutlet weak var clinicalTrialImageView: UIView!
    @IBOutlet weak var parentStackContainer: UIStackView!

    lazy var signupButton: CustomButtonFill = {
        let button = CustomButtonFill(title: "Signup with Email", target: self, action: #selector(handleSignupWithEmail))
        button.setImage(UIImage(named: "icon: email"), for: .normal)
        button.titleLabel?.font = UIFont(name: AppFontName.medium, size: 18)
        button.layer.cornerRadius = 10.0
        button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 10)
        button.titleEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 0)
        return button
    }()

    lazy var divider: DividerView = {
        let divider = DividerView(text: "OR")
        return divider
    }()

    lazy var appleButton: CustomButtonFill = {
        let button = CustomButtonFill(title: "Continue with Apple", target: self, action: #selector(handleSigninWithApple(_:)))
        button.setImage(UIImage(named: "Apple logo"), for: .normal)
        button.titleLabel?.font = UIFont(name: AppFontName.medium, size: 18)
        button.setBackgroundColor(.black, for: .normal)
        button.layer.cornerRadius = 10.0
        button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 10)
        button.titleEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 0)
        return button
    }()

    lazy var googleButton: CustomButtonFill = {
        let button = CustomButtonFill(title: "Continue with Google", target: self, action: #selector(handleSigninWithGoogle(_:)))
        button.setImage(UIImage(named: "Google logo"), for: .normal)
        button.titleLabel?.font = UIFont(name: AppFontName.medium, size: 18)
        button.setBackgroundColor(.white, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 10.0
        button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 10)
        button.titleEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 0)
        return button
    }()

    lazy var facebookButton: CustomButtonFill = {
        let button = CustomButtonFill(title: "Continue with Facebook", target: self, action: #selector(handleSigninWithFacebook(_:)))
        button.setImage(UIImage(named: "Facebook logo"), for: .normal)
        button.titleLabel?.font = UIFont(name: AppFontName.medium, size: 18)
        button.setBackgroundColor(.facebook, for: .normal)
        button.layer.cornerRadius = 10.0
        button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 10)
        button.titleEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 0)
        return button
    }()

    lazy var loginButton: UIButton = {
        let button = UIButton(title: "Got account?  Login here.", target: self, action: #selector(redirectToLoginPage))
        button.setTitleColor(.themeColor, for: .normal)
        button.titleLabel?.font = UIFont(name: AppFontName.medium, size: 18)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Signup"
        self.view.backgroundColor = UIColor(hexString: "#F5F6FA")
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "#F5F6FA")
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 24.0)!,
                                                                        NSAttributedString.Key.foregroundColor: UIColor(hexString: "#4E4E4E")]

        self.view.addSubview(signupButton)
        self.view.addSubview(divider)
        self.view.addSubview(appleButton)
        self.view.addSubview(googleButton)
        self.view.addSubview(facebookButton)
        self.view.addSubview(loginButton)

        let leftPadding = CGFloat(15)
        let rightPadding = CGFloat(15)

        signupButton.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 36, left: leftPadding, bottom: 0, right: rightPadding), size: .init(width: 0, height: 48))

        divider.anchor(top: signupButton.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 24, left: leftPadding, bottom: 0, right: rightPadding), size: .init(width: 0, height: 48))

        appleButton.anchor(top: divider.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 24, left: leftPadding, bottom: 0, right: rightPadding), size: .init(width: 0, height: 48))
        googleButton.anchor(top: appleButton.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 12, left: leftPadding, bottom: 0, right: rightPadding), size: .init(width: 0, height: 48))
        facebookButton.anchor(top: googleButton.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 12, left: leftPadding, bottom: 0, right: rightPadding), size: .init(width: 0, height: 48))
        loginButton.anchor(top: facebookButton.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 45, left: leftPadding, bottom: 0, right: rightPadding), size: .init(width: 0, height: 22))
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    @objc func handleSignupWithEmail() {
        self.performSegue(withIdentifier: "SignupToEmailSignup", sender: self)
    }
    

    @objc func handleSigninWithGoogle(_ sender: Any) {
        self.showSpinner()
        func onSuccess() {
            DispatchQueue.main.async {
                self.removeSpinner()
                self.enterTheApp()
            }
        }

        func onFailure(error: AuthError) {
            DispatchQueue.main.async {
                self.removeSpinner()
                Alert(title: "Signup Failed" , message: error.errorDescription)
            }
        }
        _ = Amplify.Auth.signInWithWebUI(for: .google, presentationAnchor: self.view.window!) { result in
            switch result {
            case .success(let session):
                onSuccess()
            case .failure(let error):
                onFailure(error: error)
            }
        }
    }

    @objc func handleSigninWithFacebook(_ sender: Any) {
        self.showSpinner()
        func onSuccess() {
            DispatchQueue.main.async {
                self.removeSpinner()
                self.enterTheApp()
            }
        }

        func onFailure(error: AuthError) {
            print("Sign in failed \(error)")
            DispatchQueue.main.async {
                self.removeSpinner()
                Alert(title: "Signup Failed" , message: error.errorDescription)
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

    @objc func handleSigninWithApple(_ sender: Any) {
        self.showSpinner()
        func onSuccess() {
            DispatchQueue.main.async {
                self.removeSpinner()
                self.enterTheApp()
            }
        }

        func onFailure(error: AuthError) {
            print("Sign in failed \(error)")
            DispatchQueue.main.async {
                self.removeSpinner()
                Alert(title: "Signup Failed" , message: error.errorDescription)
            }
        }

        _ = Amplify.Auth.signInWithWebUI(for: .apple, presentationAnchor: self.view.window!) { result in
            switch result {
            case .success(let session):
                onSuccess()
            case .failure(let error):
                onFailure(error: error)
            }
        }
    }

    @objc func redirectToLoginPage() {
        self.performSegue(withIdentifier: "SignupToLogin", sender: self)
    }

    func enterTheApp() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setRootViewController()
    }
}
