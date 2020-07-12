//
//  TempSignoutVC.swift
//  Longevity
//
//  Created by vivek on 29/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify

class TempSignoutVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func handleSignout(_ sender: Any) {
        func onSuccess(isSignedOut: Bool) {
            clearUserDefaults()
            DispatchQueue.main.async {
                if isSignedOut{
                    self.performSegue(withIdentifier: "unwindTempToOnboarding", sender: self)
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

}
