//
//  SignupByEmailVC.swift
//  Longevity
//
//  Created by vivek on 09/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify

class SignupByEmailVC: UIViewController {
    var activeTextField: UITextField?
    var rollbackYOrigin: CGFloat?

    lazy var keyboardToolbar:UIToolbar = {
        let toolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        let doneBarButton = UIBarButtonItem(title: "done", style: .plain, target: self,
                                            action: #selector(handleKeyboardDoneBarButtonTapped(_:)))
        toolbar.items = [doneBarButton]
        toolbar.sizeToFit()
        return toolbar
    }()
    
    // MARK: Outlets
    @IBOutlet weak var formName: UITextField! {
        didSet {
            formName.tag = 0
            formName.inputAccessoryView = keyboardToolbar
        }
    }
    @IBOutlet weak var formEmail: UITextField! {
        didSet {
            formEmail.tag = 1
            formEmail.inputAccessoryView = keyboardToolbar
        }
    }
    @IBOutlet weak var formPhone: UITextField! {
        didSet {
            formPhone.tag = 2
            formPhone.inputAccessoryView = keyboardToolbar
        }
    }
    @IBOutlet weak var formPassword: UITextField! {
        didSet {
            formPassword.tag = 3
            formPassword.inputAccessoryView = keyboardToolbar
        }
    }
    @IBOutlet weak var submitButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
//        customizeButton(button: submitButton)
        formName.delegate = self
        formEmail.delegate = self
        formPhone.delegate = self
        formPassword.delegate = self
        self.addKeyboardObservers()
        print("self.view.frame.origin.y", self.view.frame.origin.y)
        self.rollbackYOrigin = self.view.frame.origin.y

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//        self.navigationItem.backBarButtonItem?.title = ""

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("self.view.frame.origin.y", self.view.frame.origin.y)
        self.rollbackYOrigin = self.view.frame.origin.y
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeKeyboardObservers()
    }

    func customizeButton(button: UIButton){
        button.layer.cornerRadius = 10
    }

    @objc func handleKeyboardDoneBarButtonTapped(_ sender: UITextView) {
        print(sender.tag)
        guard let activeTextField = self.activeTextField,
            let nextResponder = activeTextField.superview?.viewWithTag(activeTextField.tag + 1) as? UIResponder else {
                 self.view.endEditing(true)
                    return
        }
        nextResponder.becomeFirstResponder()
    }

    @objc func closeKeyboard() {
        guard let activeTextField = self.activeTextField else {
            self.view.endEditing(true)
            return
        }
        activeTextField.resignFirstResponder()
    }

    // MARK: Actions
    @IBAction func handleSignup(_ sender: Any) {
        self.closeKeyboard()
        func onSuccess() {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "SignupEmailToConfirm", sender: self)
                self.removeSpinner()
            }
        }

        func onFailure(errorDescription: String) {
            DispatchQueue.main.async {
                self.removeSpinner()
                self.showAlert(title: "Login Failed" , message: errorDescription)
            }
        }

        if let name = formName.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let email = formEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let phone = formPhone.text?.trimmingCharacters(in: .whitespacesAndNewlines) ,
            let password = formPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines){
            func validate() -> Bool {
                if email.isEmpty || !(email.isValidEmail) {
                    showAlert(title: "Error - Invalid Email", message: "Please provide a valid email address.")
                    return false
                }
                if phone.isEmpty || !(phone.isValidPhone) {
                    showAlert(title: "Error - Invalid Phone", message: "Please provide a valid phone number in the format \n +{CountryCode}{PhoneNumber}")
                    return false
                }
                if password.isEmpty {
                    showAlert(title: "Error - Invalid Password", message: "Password cannot be empty.")
                    return false
                }
                return true
            }

            guard validate() else { return }
            self.showSpinner()

            let userAttributes = [AuthUserAttribute(.email, value: email), AuthUserAttribute(.phoneNumber, value: phone),  AuthUserAttribute(.name, value: name), AuthUserAttribute(.unknown(CustomCognitoAttributes.longevityTNC), value: CustomCognitoAttributesDefaults.longevityTNC)]
            let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
            
            _ = Amplify.Auth.signUp(username: email, password: password, options: options) { result in
                switch result {
                case .success(let signUpResult):
                    print("======================signup result \n \n", signUpResult, "\n \n")
                    if case let .confirmUser(deliveryDetails, _) = signUpResult.nextStep {
                        print("Delivery details \(String(describing: deliveryDetails))")
                    } else {
                        print("SignUp Complete")
                    }
                    onSuccess()
                case .failure(let error):
                    print("An error occured while registering a user \(error)")
                    onFailure(errorDescription: error.errorDescription)
                }
            }
        }

    }

    func verifyPhone() {
        _ = Amplify.Auth.resendConfirmationCode(for: .email) { result in
            switch result {
            case .success(let deliveryDetails):
                print("Resend code send to - \(deliveryDetails)")
            case .failure(let error):
                print("Resend code failed with error \(error)")
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! SignupConfirmVC
        destinationVC.userEmail = formEmail.text!
    }

}

extension SignupByEmailVC:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        guard let nextResponder = textField.superview?.viewWithTag(nextTag) as? UIResponder
            else {
                textField.resignFirstResponder()
                return true}

        nextResponder.becomeFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
        if let rollbackYOrigin = self.rollbackYOrigin, self.view.frame.origin.y != rollbackYOrigin {
            self.view.frame.origin.y = rollbackYOrigin
        }
    }
}

extension SignupByEmailVC {
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self,  name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWasShown(notification: NSNotification){
        guard let info = notification.userInfo else {return}
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)
        guard let keyboardHeight = keyboardSize?.height ,
            let navbarHeight = self.navigationController?.navigationBar.frame.size.height,
            let inputAccessoryHeight = activeTextField?.inputAccessoryView?.frame.height
        else {return}
        let topPadding:CGFloat = 20.0
        let viewYPadding = navbarHeight + topPadding
        var visibleScreen : CGRect = self.view.frame
        visibleScreen.size.height -= (keyboardHeight + viewYPadding)


        guard let activeFieldOrigin = activeTextField?.frame.origin,
            let activeFieldHeight = activeTextField?.frame.size.height else {return}

        var activeFieldBottom = activeFieldOrigin
        activeFieldBottom.y += activeFieldHeight

        if (!visibleScreen.contains(activeFieldBottom)){
            self.view.frame.origin.y = -(keyboardHeight - inputAccessoryHeight - viewYPadding)
        } else {
            print("self.view.frame.origin.y", self.view.frame.origin.y)
            if let rollbackYOrigin = self.rollbackYOrigin, self.view.frame.origin.y != rollbackYOrigin {
                self.view.frame.origin.y = rollbackYOrigin
            }
        }
    }

    @objc func keyboardWillBeHidden(notification: NSNotification){
        guard let rollbackYOrigin = self.rollbackYOrigin else {return}
        self.view.frame.origin.y = rollbackYOrigin
    }
}

