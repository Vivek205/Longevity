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
        var confirmationSuccess = false
        if let confirmationCode = formConfirmationCode.text {
            let group = DispatchGroup()
            group.enter()

            DispatchQueue.global().async {
                _ = Amplify.Auth.confirm(userAttribute: .email, confirmationCode: confirmationCode) { result in
                    switch result {
                    case .success:
                        print("Attribute verified")
                        confirmationSuccess = true
                        group.leave()
                    case .failure(let error):
                        print("Update attribute failed with error \(error)")
                        group.leave()
                    }
                }
            }

            group.wait()
            if confirmationSuccess {
                performSegue(withIdentifier: "UnwindConfirmEmailToTOS", sender: self)
            } else {
                let alert = UIAlertController(title: "Error", message: "Unable to confirm email", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
                return self.present(alert, animated: true, completion: nil)
            }
        }
    }

}
