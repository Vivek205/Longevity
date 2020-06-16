//
//  LoginVC.swift
//  Longevity
//
//  Created by vivek on 02/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify

class LoginVC: UIViewController {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        getuserAttributes()
        customizeButtons()
        highlightImageButton(imgButton: personalImageView)
        normalizeImageButton(imgButton: clinicalTrialImageView)
    }

    func customizeButtons(){
        customizeButtonWithImage(button: loginButton)
        customizeButtonWithImage(button: appleButton)
        customizeButtonWithImage(button: googleButton)
        customizeButtonWithImage(button: facebookButton)
        customizeImageButton(imgButton: personalImageView)
        customizeImageButton(imgButton: clinicalTrialImageView)
        addButtonShadow(button: googleButton)

    }

    func customizeButtonWithImage(button: UIButton){
        button.layer.cornerRadius = 10
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
    }

    func addButtonShadow(button:UIButton){
        googleButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        googleButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        googleButton.layer.shadowOpacity = 1.0
        googleButton.layer.shadowRadius = 0.0
        googleButton.layer.cornerRadius = 4.0
    }

    func customizeImageButton(imgButton: UIView){
        imgButton.layer.masksToBounds = true
        imgButton.layer.borderWidth = 2
        imgButton.layer.cornerRadius = 10
    }

    func highlightImageButton(imgButton: UIView){
        imgButton.layer.borderColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
        imgButton.tintColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
        for subview in imgButton.subviews{
            if let item = subview as? UIImageView{
                item.image = item.image?.withRenderingMode(.alwaysTemplate)
                item.tintColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
            }
        }
    }

    func normalizeImageButton(imgButton: UIView){
        imgButton.layer.borderColor = #colorLiteral(red: 0.9176470588, green: 0.9294117647, blue: 0.9450980392, alpha: 1)
        imgButton.tintColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
        for subview in imgButton.subviews{
            if let item = subview as? UIImageView{
                item.image = item.image?.withRenderingMode(.alwaysTemplate)
                item.tintColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
            }
        }
    }



    

    // MARK: Actions
    @IBAction func handleLogin(_ sender: Any) {
        if let email = self.formEmail.text, let password = self.formPassword.text {
            self.showSpinner()
            func onSuccess() {
                DispatchQueue.main.async {
                    self.removeSpinner()
                    self.performSegue(withIdentifier: "LoginToProfileSetup", sender: self)
                }
            }

            func onFailure(error: AuthError) {
                print("Sign in failed \(error)")
                DispatchQueue.main.async {
                    self.removeSpinner()
                }
            }

            _ = Amplify.Auth.signIn(username: email, password: password) { result in
                print("result", result)
                switch result {
                case .success(_):
                    onSuccess()
                case .failure(let error):
                    onFailure(error: error)
                }
            }
        }

    }

    @IBAction func handleAccountTypeChange(_ sender: UITapGestureRecognizer) {
        let containerView = sender.view! as UIView
        for subview in containerView.subviews{
            if let item = subview as? UILabel{
                print(UserAccountType.personal.rawValue)
                if item.text == UserAccountType.personal.rawValue{
                    highlightImageButton(imgButton: personalImageView)
                    normalizeImageButton(imgButton: clinicalTrialImageView)
                } else {
                    highlightImageButton(imgButton: clinicalTrialImageView)
                    normalizeImageButton(imgButton: personalImageView)
                }

            }
        }
    }

    @IBAction func handleSigninWithFacebook(_ sender: Any) {
        self.showSpinner()
        func onSuccess() {
            DispatchQueue.main.async {
                self.removeSpinner()
                self.performSegue(withIdentifier: "LoginToProfileSetup", sender: self)
            }
        }

        func onFailure(error: AuthError) {
            print("Sign in failed \(error)")
            DispatchQueue.main.async {
                self.removeSpinner()
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
        self.showSpinner()
        func onSuccess() {
            DispatchQueue.main.async {
                self.removeSpinner()
                self.performSegue(withIdentifier: "LoginToProfileSetup", sender: self)
            }
        }

        func onFailure(error: AuthError) {
            DispatchQueue.main.async {
                self.removeSpinner()
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



    @IBAction func unwindToLogin(_ sender: UIStoryboardSegue){
        print("un wound")
    }


    func getuserAttributes() {
        _ = Amplify.Auth.fetchUserAttributes() { (result) in
            switch result {
            case .success(let userAttributes):
                for attribute in userAttributes {
                    if attribute.key == .email {
                        self.username = attribute.value
                    }
                }
            case .failure(let error):
                print("error getting attributes")
            }
        }
    }

}

