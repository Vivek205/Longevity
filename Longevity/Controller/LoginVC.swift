//
//  LoginVC.swift
//  Longevity
//
//  Created by vivek on 02/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify

class LoginVC: UIViewController {
    var username = ""
    
    // MARK: Outlets
    @IBOutlet weak var formEmail: UITextField!
    @IBOutlet weak var formPassword: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        getuserAttributes()
    }
    

    // MARK: Actions
    @IBAction func handleLogin(_ sender: Any) {
        var signinSuccess = false
        let group = DispatchGroup()
        group.enter()


        if let username = self.formEmail.text, let password = self.formPassword.text{
            DispatchQueue.global().async {
                print("email", username)
                print("password", password)
                _ = Amplify.Auth.signIn(username: username, password: password) { result in
                    print("result", result)
                    switch result {
                    case .success(_):
                        print("Sign in succeeded")
                        signinSuccess = true
                        group.leave()
                    case .failure(let error):
                        print("Sign in failed \(error)")
                        group.leave()
                    }
                }
            }
        } else {
            group.leave()
        }


        group.wait()
        if signinSuccess{
            performSegue(withIdentifier: "LoginToTermsOfService", sender: self)
        }
    }
//
//    @IBAction func handleResetPassword(_ sender: Any) {
//        var resetSuccess = false
//        let group = DispatchGroup()
//        group.enter()
//
//        DispatchQueue.global().async {
//            _ = Amplify.Auth.resetPassword(for: self.username) {(result) in
//                do {
//                    let resetResult = try result.get()
//                    switch resetResult.nextStep {
//                    case .confirmResetPasswordWithCode(let deliveryDetails, let info):
//                        print("Confirm reset password with code send to - \(deliveryDetails) \(info)")
//                        resetSuccess = true
//                        group.leave()
//                    case .done:
//                        print("Reset completed")
//                        resetSuccess = true
//                        group.leave()
//                    }
//                } catch {
//                    print("Reset passowrd failed with error \(error)")
//                    group.leave()
//                }
//            }
//        }
//
//        group.wait()
//
//        if resetSuccess {
//            performSegue(withIdentifier: "LoginToResetPassword", sender: self)
//        }
//
//    }


    func getCurrentUser(){
        _ = Amplify.Auth.fetchAuthSession { (result) in
            switch result {
            case .success(let session):
                print()
                print("Is user signed in - \(session)")
            case .failure(let error):
                print("Fetch session failed with error \(error)")
            }
        }
    }


    func getuserAttributes(){
        _ = Amplify.Auth.fetchUserAttributes() { (result) in
            switch result {
            case .success(let userAttributes):
                for attribute in userAttributes {
                    if attribute.key == .email {
                        self.username = attribute.value
                        print("User email", attribute.value)
                    }
                }
                print("User attribtues - \("dfd")")
            case .failure(let error):
                print("Fetching user attributes failed with error \(error)")
            }
        }
    }

}
