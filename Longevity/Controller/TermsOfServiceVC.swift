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


    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
        self.navigationItem.setHidesBackButton(true, animated: true)
        customizeButton(button: acceptButton)
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


    
    // MARK: Navigation Delegate
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool){
        print("TOC shown =====================================================================")
    }
    
    
}
