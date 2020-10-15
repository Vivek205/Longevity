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
//    @IBOutlet weak var signupButton: CustomButtonFill!
//    @IBOutlet weak var appleButton: UIButton!
//    @IBOutlet weak var googleButton: UIButton!
//    @IBOutlet weak var facebookButton: UIButton!
//    @IBOutlet weak var loginButton: UIButton!
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
//        customizeButtons()
//
//        titleLabel.removeFromSuperview()
//        personalImageView.removeFromSuperview()
//        clinicalTrialImageView.removeFromSuperview()
//        parentStackContainer.removeArrangedSubview(parentStackContainer.arrangedSubviews[0])
//        parentStackContainer.removeArrangedSubview(parentStackContainer.arrangedSubviews[0])
//
//        parentStackContainer.removeFromSuperview()

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

//    func customizeButtons(){
////        customizeButtonWithImage(button: signupButton)
////        customizeButtonWithImage(button: appleButton)
////        customizeButtonWithImage(button: googleButton)
////        customizeButtonWithImage(button: facebookButton)
////        customizeImageButton(imgButton: personalImageView)
////        customizeImageButton(imgButton: clinicalTrialImageView)
////        addButtonShadow(button: googleButton)
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        self.customizeButtonWithImage(button: signupButton)
//        self.customizeButtonWithImage(button: appleButton)
//        self.customizeButtonWithImage(button: googleButton)
//        self.customizeButtonWithImage(button: facebookButton)
    }

//    func customizeButtonWithImage(button: UIButton){
//        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
//        button.layer.shadowOffset = CGSize(width: 0, height: 1.0)
//        button.layer.cornerRadius = 10.0
//        button.layer.shadowRadius = 1.0
//        button.layer.shadowOpacity = 1.0
//        button.layer.masksToBounds = false
//        button.layer.shadowPath = UIBezierPath(roundedRect: button.bounds, cornerRadius: button.layer.cornerRadius).cgPath
//    }

//    func addButtonShadow(button:UIButton){
//        googleButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
//        googleButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
//        googleButton.layer.shadowOpacity = 1.0
//        googleButton.layer.shadowRadius = 0.0
//        googleButton.layer.cornerRadius = 4.0
//    }


//    func customizeImageButton(imgButton: UIView){
//        button.layer.masksToBounds = true
//        button.layer.borderWidth = 2
//        imgButton.layer.cornerRadius = 10
//    }

//    func highlightImageButton(imgButton: UIView){
//        imgButton.layer.borderColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
//        imgButton.tintColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
//        for subview in imgButton.subviews{
//            if let item = subview as? UIImageView{
//                item.image = item.image?.withRenderingMode(.alwaysTemplate)
//                item.tintColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
//            }
//
//            if let item = subview as? UILabel {
//                item.textColor = .themeColor
//            }
//        }
//    }
//
//    func normalizeImageButton(imgButton: UIView){
//        imgButton.layer.borderColor = #colorLiteral(red: 0.9176470588, green: 0.9294117647, blue: 0.9450980392, alpha: 1)
//        imgButton.tintColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
//        imgButton.backgroundColor = .clear
//        for subview in imgButton.subviews{
//            if let item = subview as? UIImageView{
//                item.image = item.image?.withRenderingMode(.alwaysTemplate)
//                item.tintColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
//            }
//            if let item = subview as? UILabel {
//                item.textColor = UIColor(hexString: "#212121")
//            }
//        }
//    }

    @objc func handleSignupWithEmail() {
        self.performSegue(withIdentifier: "SignupToEmailSignup", sender: self)
    }
    

//    @IBAction func handleAccountTypeChange(_ sender: UITapGestureRecognizer) {
//        let containerView = sender.view! as UIView
//        for subview in containerView.subviews{
//            if let item = subview as? UILabel{
//                print(UserAccountType.personal.rawValue)
//                if item.text == UserAccountType.personal.rawValue{
//                    highlightImageButton(imgButton: personalImageView)
//                    normalizeImageButton(imgButton: clinicalTrialImageView)
//                } else {
////                    highlightImageButton(imgButton: clinicalTrialImageView)
////                    normalizeImageButton(imgButton: personalImageView)
//                }
//
//            }
//        }
//    }

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
                self.showAlert(title: "Signup Failed" , message: error.errorDescription)
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
                self.showAlert(title: "Signup Failed" , message: error.errorDescription)
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
                self.showAlert(title: "Signup Failed" , message: error.errorDescription)
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
        AppSyncManager.instance.fetchUserNotification()
    }
}
