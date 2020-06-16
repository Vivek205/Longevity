//
//  ConfirmEmailVC.swift
//  Longevity
//
//  Created by vivek on 10/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify

class ConfirmEmailVC: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var formConfirmationCode: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: Actions
    @IBAction func handleConfirmation(_ sender: Any) {

        if let confirmationCode = formConfirmationCode.text {
            func onSuccess() {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "UnwindConfirmEmailToTOS", sender: self)
                }
            }

            func onFailure() {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Unable to confirm email", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
                    return self.present(alert, animated: true, completion: nil)
                }
            }

            DispatchQueue.global().async {
                _ = Amplify.Auth.confirm(userAttribute: .email, confirmationCode: confirmationCode) { result in
                    switch result {
                    case .success:
                        print("Attribute verified")
                        onSuccess()
                    case .failure(let error):
                        print("Update attribute failed with error \(error)")
                        onFailure()
                    }
                }
            }
        }
    }

}
