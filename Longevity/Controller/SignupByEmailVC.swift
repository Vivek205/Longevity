//
//  SignupByEmailVC.swift
//  Longevity
//
//  Created by vivek on 09/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify

class SignupByEmailVC: UIViewController, UITextFieldDelegate {
    // MARK: Outlets
    @IBOutlet weak var formName: UITextField!
    @IBOutlet weak var formEmail: UITextField!
    @IBOutlet weak var formPhone: UITextField!
    @IBOutlet weak var formPassword: UITextField!
    @IBOutlet weak var formConfirmPassword: UITextField!
    @IBOutlet weak var submitButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        customizeButton(button: submitButton)
        formName.delegate = self
        formEmail.delegate = self
        formPhone.delegate = self
        formPassword.delegate = self
        formConfirmPassword.delegate = self
    }

    func customizeButton(button: UIButton){
        button.layer.cornerRadius = 10
    }

    // MARK: Actions
    @IBAction func handleSignup(_ sender: Any) {


        func onSuccess() {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "SignupEmailToConfirm", sender: self)
                self.removeSpinner()
            }
        }

        func onFailure() {
            DispatchQueue.main.async {
                self.removeSpinner()
                let alert = UIAlertController(title: "Error", message: "Unable to signup. Please check the values and try again", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.destructive, handler: nil))
                return self.present(alert, animated: true, completion: nil)
            }
        }

        if let name = formName.text, let email = formEmail.text, let phone = formPhone.text , let password = formPassword.text, let confirmPassword = formConfirmPassword.text{
            func validate() {
                if(password != confirmPassword) {
                    let alert = UIAlertController(title: "Error", message: "Confirm password doesnot match with password", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.destructive, handler: nil))
                    return self.present(alert, animated: true, completion: nil)
                }
            }

            validate()
            self.showSpinner()
            
            let userAttributes = [AuthUserAttribute(.email, value: email), AuthUserAttribute(.phoneNumber, value: phone),  AuthUserAttribute(.name, value: name)]
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
                    onFailure()
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

    // MARK: Delegate Textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! SignupConfirmVC
        destinationVC.userEmail = formEmail.text!
    }

}

