//
//  SignupVC.swift
//  Longevity
//
//  Created by vivek on 02/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify
import AmplifyPlugins

class SignupVC: UIViewController {

    // MARK: outlets
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        // Do any additional setup after loading the view.
    }

    @IBAction func handleSignup(_ sender: Any) {
        if let email = userEmail.text, let name = userName.text, let password = userPassword.text {
            print("email", email)
            print("name", name)
            print("password", password)
            let userAttributes = [AuthUserAttribute(.email, value: email ), AuthUserAttribute(.name, value: name)]
            let options = AuthSignUpRequest.Options(userAttributes: userAttributes)

            let group = DispatchGroup()
            group.enter()

            DispatchQueue.global().async {
            _ = Amplify.Auth.signUp(username: email, password: password, options: options, listener: { (result) in
                switch result{
                case .success(let signupResult):
                    if case let .confirmUser(deliveryDetails, _) = signupResult.nextStep {
                        print("delivery details =========== \(String(describing: deliveryDetails))")
                        group.leave()
                    } else {
                        print("Singup Complete")
                    }
                case .failure(let error):
                    print("============= \n An error occured while registering a user \(error)")
                    group.leave()
                }
            })
            }

            group.wait()
            print("queue completed ==================")
            redirectToLoginPage()

        }
    }

    func redirectToLoginPage() {
       self.performSegue(withIdentifier: "SignupToLogin", sender: self)
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
