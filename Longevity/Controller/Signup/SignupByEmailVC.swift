//
//  SignupByEmailVC.swift
//  Longevity
//
//  Created by vivek on 09/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify
import CountryPickerView

class SignupByEmailVC: UIViewController {
    var activeTextField: UITextField?
    var rollbackYOrigin: CGFloat?
    var countryCode: String?


    lazy var countryPickerView: CountryPickerView = {
        let cpv = CountryPickerView(frame: .init(x: 8, y: 0, width: 120, height: 120))
        return cpv
    }()

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
            formName.backgroundColor = .white
        }
    }
    @IBOutlet weak var formEmail: UITextField! {
        didSet {
            formEmail.tag = 1
            formEmail.inputAccessoryView = keyboardToolbar
            formEmail.backgroundColor = .white
        }
    }
    @IBOutlet weak var formPhone: UITextField! {
        didSet {
            formPhone.tag = 2
            formPhone.inputAccessoryView = keyboardToolbar


            let padding = 8
            let size = 120
            let leftView = UIView(frame: CGRect(x: 0, y: 0, width: size+padding, height: size) )
            leftView.addSubview(countryPickerView)
            countryPickerView.fillSuperview(padding: .init(top: 0, left: 10, bottom: 0, right: 0))
            formPhone.leftView = leftView


            formPhone.leftViewMode = .always
            formPhone.backgroundColor = .white

//            formPhone.lef
        }
    }
    @IBOutlet weak var formPassword: UITextField! {
        didSet {
            formPassword.tag = 3
            formPassword.inputAccessoryView = keyboardToolbar
            formPassword.backgroundColor = .white
        }
    }
    @IBOutlet weak var submitButton: UIButton!



//    MARK: - Form Labels
    lazy var namelabelView: UIView = {
        let labelView = UIView()
        return labelView
    }()
    lazy var nameLabel: UILabel = {
        let label = UILabel(text: "Name (optional)", font: UIFont(name: AppFontName.regular, size: 12), textColor: .textInput, textAlignment: .center, numberOfLines: 1)
        return label
    }()

    lazy var emaillabelView: UIView = {
        let labelView = UIView()
        return labelView
    }()
    lazy var emailLabel: UILabel = {
        let label = UILabel(text: "Email", font: UIFont(name: AppFontName.regular, size: 12), textColor: .textInput, textAlignment: .center, numberOfLines: 1)
        return label
    }()

    lazy var phonelabelView: UIView = {
        let labelView = UIView()
        return labelView
    }()
    lazy var phoneLabel: UILabel = {
        let label = UILabel(text: "Mobile Phone", font: UIFont(name: AppFontName.regular, size: 12), textColor: .textInput, textAlignment: .center, numberOfLines: 1)
        return label
    }()

    lazy var passwordlabelView: UIView = {
        let labelView = UIView()
        return labelView
    }()
    lazy var passwordLabel: UILabel = {
        let label = UILabel(text: "Create Password", font: UIFont(name: AppFontName.regular, size: 12), textColor: .textInput, textAlignment: .center, numberOfLines: 1)
        return label
    }()

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        namelabelView.addColors(colors: [.appBackgroundColor, .white])
        namelabelView.addSubview(nameLabel)
        nameLabel.fillSuperview(padding: .init(top: 0, left: 4, bottom: 0, right: 4))

        emaillabelView.addColors(colors: [.appBackgroundColor, .white])
        emaillabelView.addSubview(emailLabel)
        emailLabel.fillSuperview(padding: .init(top: 0, left: 4, bottom: 0, right: 4))

        phonelabelView.addColors(colors: [.appBackgroundColor, .white])
        phonelabelView.addSubview(phoneLabel)
        phoneLabel.fillSuperview(padding: .init(top: 0, left: 4, bottom: 0, right: 4))

        passwordlabelView.addColors(colors: [.appBackgroundColor, .white])
        passwordlabelView.addSubview(passwordLabel)
        passwordLabel.fillSuperview(padding: .init(top: 0, left: 4, bottom: 0, right: 4))

    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        customizeButton(button: submitButton)
        formName.delegate = self
        formEmail.delegate = self
        formPhone.delegate = self
        formPassword.delegate = self
        self.addKeyboardObservers()
        self.rollbackYOrigin = self.view.frame.origin.y

        self.view.addSubview(namelabelView)
        self.view.addSubview(emaillabelView)
        self.view.addSubview(phonelabelView)
        self.view.addSubview(passwordlabelView)

        namelabelView.centerYTo(formName.topAnchor)
        namelabelView.anchor(.leading(formName.leadingAnchor, constant: 10.0), .width(nameLabel.frame.size.width))

        emaillabelView.centerYTo(formEmail.topAnchor)
        emaillabelView.anchor(.leading(formEmail.leadingAnchor, constant: 10.0), .width(emailLabel.frame.size.width))

        phonelabelView.centerYTo(formPhone.topAnchor)
        phonelabelView.anchor(.leading(formPhone.leadingAnchor, constant: 10.0), .width(phoneLabel.frame.size.width))

        passwordlabelView.centerYTo(formPassword.topAnchor)
        passwordlabelView.anchor(.leading(formPassword.leadingAnchor, constant: 10.0), .width(phoneLabel.frame.size.width))

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

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

        if   let email = formEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            var phone = formPhone.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let password = formPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines){
            print("countryPickerView", countryPickerView.selectedCountry)
            phone = "\(countryPickerView.selectedCountry.phoneCode)\(phone)"
            print("phone", phone, phone.isValidPhone)

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

            var userAttributes = [AuthUserAttribute(.email, value: email),                                                 AuthUserAttribute(.phoneNumber, value: phone), AuthUserAttribute(.unknown(CustomCognitoAttributes.longevityTNC), value: CustomCognitoAttributesDefaults.longevityTNC)]

            if let name = formName.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                userAttributes.append(AuthUserAttribute(.name, value: name))
            }

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

