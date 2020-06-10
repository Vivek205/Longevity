//
//  TermsOfServiceVC.swift
//  Longevity
//
//  Created by vivek on 03/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify


class TermsOfServiceVC: UIViewController, UINavigationControllerDelegate {
    // MARK: Outlets
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var footer: UIView!
    @IBOutlet weak var confirmEmailButton: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
        self.navigationItem.setHidesBackButton(true, animated: true)
        customizeButton(button: acceptButton)
        getUserSession()
        getUserAttributes()
    }

    func customizeButton(button: UIButton){
        button.layer.cornerRadius = 10
    }

    func customizeFooter(footer: UIView){
        footer.layer.shadowPath = UIBezierPath(rect: footer.bounds).cgPath
        footer.layer.shadowRadius = 5
        footer.layer.shadowOffset = .zero
        footer.layer.shadowOpacity = 1
        footer.layer.shadowColor = UIColor.black.cgColor
        footer.layer.masksToBounds = false
        footer.clipsToBounds = false
        footer.backgroundColor = UIColor.black
    }
    

    @IBAction func handleSignout(_ sender: Any) {
        var signoutSuccess = false
        let group = DispatchGroup()
        group.enter()
        print("entered group")
        DispatchQueue.global().async {
            _ = Amplify.Auth.signOut() { (result) in
                switch result {
                case .success:
                    print("Successfully signed out")
                    signoutSuccess = true
                    group.leave()
                case .failure(let error):
                    print("Sign out failed with error \(error)")
                    group.leave()
                }
            }
        }
        print("outside dispatch")
        group.wait()
        print("signoutSuccess", signoutSuccess)
        if signoutSuccess{
            performSegue(withIdentifier: "unwindTOCToOnboarding", sender: self)
        }

    }

    @IBAction func unwindToTermsOfService(_ sender: UIStoryboardSegue){
        print("unwound to terms of service")
    }

    
    // MARK: Navigation Delegate
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool){
        print("TOC shown =====================================================================")
    }
    
    func getUserSession(){
        let group = DispatchGroup()
        group.enter()
        _ = Amplify.Auth.fetchAuthSession { (result) in
            switch result {
            case .success(let session):
                print("Is user signed in - \(session)")
                group.leave()
            case .failure(let error):
                print("Fetch session failed with error \(error)")
            }
        }
        group.wait()
    }

    func getUserAttributes(){
        var emailVerified = false
        let group = DispatchGroup()
        group.enter()

        DispatchQueue.global().async {
            _ = Amplify.Auth.fetchUserAttributes() { result in
                switch result {
                case .success(let attributes):
                    print("User attribtues - \(attributes)")
                    for attribute in attributes {
                        if attribute.key == .unknown("email_verified"){
                            emailVerified = attribute.value == "true"
                        }
                    }
                    group.leave()
                case .failure(let error):
                    print("Fetching user attributes failed with error \(error)")
                    group.leave()
                }
            }
        }

        group.wait()
        print("got user attributes")
        print("email verified", emailVerified)
        confirmEmailButton.isEnabled = !emailVerified
        confirmEmailButton.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)

    }

    @IBAction func sendEmailVerification(){
        var sendingEmailCodeSuccess = false
        let group = DispatchGroup()
        group.enter()

        DispatchQueue.global().async {
            _ = Amplify.Auth.resendConfirmationCode(for: .email) { result in
                switch result {
                case .success(let deliveryDetails):
                    print("Resend code send to - \(deliveryDetails)")
                    sendingEmailCodeSuccess = true
                    group.leave()
                case .failure(let error):
                    print("Resend code failed with error \(error)")
                    group.leave()
                }
            }
        }

        group.wait()
        if sendingEmailCodeSuccess {
            performSegue(withIdentifier: "TOSToConfirmEmail", sender: self)
        }
    }
}
