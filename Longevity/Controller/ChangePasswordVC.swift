//
//  ChangePasswordVC.swift
//  Longevity
//
//  Created by vivek on 04/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify

class ChangePasswordVC: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var formOldPassword: UITextField!
    @IBOutlet weak var formNewPassword: UITextField!
    @IBOutlet weak var formResult: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: Actions
    @IBAction func handleChangePassword(_ sender: Any) {
        var changeSuccess = false

        if let oldPassword = formOldPassword.text, let newPassword = formNewPassword.text {

            func onSuccess() {
                DispatchQueue.main.async {
                    self.updateUIOnPasswordChange(success: changeSuccess)
                    self.performSegue(withIdentifier: "UnwindChangePasswordToTOS", sender: self)
                }
            }

                _ = Amplify.Auth.update(oldPassword: oldPassword, to: newPassword) { result in
                    switch result {
                    case .success:
                        changeSuccess = true
                       onSuccess()
                    case .failure(let error):
                        print("handleChangePassword",error)
                    }
                }
        }
    }

    func updateUIOnPasswordChange(success:Bool) {
        if success{
            self.formResult.text = "Password changed successfully"
            self.formResult.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        } else{
            self.formResult.text = "Failed to change password"
            self.formResult.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        }
    }
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

}
