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

    // MARK: Outlets
    @IBOutlet weak var formOTP: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Actions
    @IBAction func handleConfirmSignup(_ sender: Any) {
        func onSuccess() {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "UnwindSignupConfirmToLogin", sender: self)
            }
        }

        if let confirmationCode = formOTP.text {
            DispatchQueue.global().async {
                _ = Amplify.Auth.confirmSignUp(for: self.userEmail!, confirmationCode: confirmationCode) { result in
                    switch result {
                    case .success(_):
                        print("Confirm signUp succeeded")
                        onSuccess()
                    case .failure(let error):
                        print("An error occured while registering a user \(error)")
                    }
                }
            }
        }
    }
}
