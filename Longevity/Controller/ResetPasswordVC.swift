//
//  ResetPasswordVC.swift
//  Longevity
//
//  Created by vivek on 04/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify

class ResetPasswordVC: UIViewController {


    // MARK: Outlets
    @IBOutlet weak var formNewPassword: UITextField!
    @IBOutlet weak var formConfirmationCode: UITextField!
    @IBOutlet weak var formUsername: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Actions
    @IBAction func handleSendResetCode(_ sender: Any) {
        guard let username = formUsername.text else {
            return
        }
        _ = Amplify.Auth.resetPassword(for: username) {(result) in
                       do {
                           let resetResult = try result.get()
                           switch resetResult.nextStep {
                           case .confirmResetPasswordWithCode(let deliveryDetails, let info):
                               print("Confirm reset password with code send to - \(deliveryDetails) \(info)")
                           case .done:
                               print("Reset completed")
                           }
                       } catch {
                           print("Reset passowrd failed with error \(error)")
                       }
                   }
    }




    @IBAction func handleResetPassword(_ sender: Any) {
        var resetSuccess = false
        let newPassword = formNewPassword.text!
        let confirmationCode = formConfirmationCode.text!
        let username = formUsername.text!
        print("self username", username)

        func onSuccess() {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "UnwindResetPasswordToTOS", sender: self)
            }
        }

            _ = Amplify.Auth.confirmResetPassword(
                for: username,
                with: newPassword,
                confirmationCode: confirmationCode) {(result) in
                    switch result {
                    case .success:
                        onSuccess()
                    case .failure(let error):
                        print("confirm reset password", error)
                    }
            }
    }
}
