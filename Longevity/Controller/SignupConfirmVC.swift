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
        print("username", userEmail)
        var confirmationSuccess = false

        if let confirmationCode = formOTP.text {
            let group = DispatchGroup()
            group.enter()

            DispatchQueue.global().async {
                _ = Amplify.Auth.confirmSignUp(for: self.userEmail!, confirmationCode: confirmationCode) { result in
                    switch result {
                    case .success(_):
                        print("Confirm signUp succeeded")
                        group.leave()
                    case .failure(let error):
                        print("An error occured while registering a user \(error)")
                        group.leave()
                    }
                }
            }

            group.wait()
            self.performSegue(withIdentifier: "UnwindSignupConfirmToLogin", sender: self)
        }

self.performSegue(withIdentifier: "UnwindSignupConfirmToLogin", sender: self)

    }


}
