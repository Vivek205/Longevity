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
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
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
            performSegue(withIdentifier: "TOSToLogin", sender: self)
        }

    }


    
    // MARK: Navigation Delegate
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool){
        print("TOC shown =====================================================================")
    }
    
    
}
