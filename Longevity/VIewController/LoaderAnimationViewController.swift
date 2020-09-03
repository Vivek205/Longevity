//
//  LoaderAnimationViewController.swift
//  Longevity
//
//  Created by vivek on 03/09/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class LoaderAnimationViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        self.showSpinner()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if UserAuthAPI.shared.checkUserSignedIn() {
            self.removeSpinner()
            let tabbarViewController = LNTabBarViewController()
            tabbarViewController.modalPresentationStyle = .fullScreen
            appDelegate.window?.rootViewController = tabbarViewController
        } else {
            self.removeSpinner()
           let storyboard = UIStoryboard(name: "UserLogin", bundle: nil)
            let onBoardingViewController = storyboard.instantiateInitialViewController()
            appDelegate.window?.rootViewController = onBoardingViewController
            //            gotoLogin()
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
