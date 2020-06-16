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
    
    // MARK: Actions
    @IBAction func handleAcceptTerms(_ sender: Any) {
        print("Terms Accepted")
        performSegue(withIdentifier: "TOSToProfileSetup", sender: self)
    }


    @IBAction func handleSignout(_ sender: Any) {
        func onSuccess(isSignedOut: Bool) {
            DispatchQueue.main.async {
                if isSignedOut{
                    self.performSegue(withIdentifier: "unwindTOCToOnboarding", sender: self)
                }
            }
        }

        _ = Amplify.Auth.signOut() { (result) in
            switch result {
            case .success:
                print("Successfully signed out")
                onSuccess(isSignedOut: true)
            case .failure(let error):
                print("Sign out failed with error \(error)")
            }
        }
    }

    @IBAction func unwindToTermsOfService(_ sender: UIStoryboardSegue){
        print("unwound to terms of service")
    }


    @IBAction func sendEmailVerification(){
        func onSuccess(isEmailSent: Bool) {
            DispatchQueue.main.async {
                if isEmailSent {
                    self.performSegue(withIdentifier: "TOSToConfirmEmail", sender: self)
                }
            }
        }

        _ = Amplify.Auth.resendConfirmationCode(for: .email) { result in
            switch result {
            case .success(let deliveryDetails):
                print("Resend code send to - \(deliveryDetails)")
                onSuccess(isEmailSent: true)
            case .failure(let error):
                print("Resend code failed with error \(error)")
            }
        }

    }

    // MARK: User Session
    func getUserSession(){
        _ = Amplify.Auth.fetchAuthSession { (result) in
            switch result {
            case .success(let session):
                print("user signed in")
            case .failure(let error):
                print("Fetch session failed with error \(error)")
            }
        }
    }

    func getUserAttributes(){
        func onSuccess(isEmailVerified: Bool) {
            DispatchQueue.main.async {
                self.confirmEmailButton.isEnabled = !isEmailVerified
                self.confirmEmailButton.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            }
        }

        _ = Amplify.Auth.fetchUserAttributes() { result in
            switch result {
            case .success(let attributes):
                for attribute in attributes {
                    if attribute.key == .unknown("email_verified"){
                        onSuccess(isEmailVerified: attribute.value == "true")
                    }
                }
            case .failure(let error):
                print("Fetching user attributes failed with error \(error)")
            }
        }
    }


}
