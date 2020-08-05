//
//  TermsOfServiceVC.swift
//  Longevity
//
//  Created by vivek on 03/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify
import Sentry

let termsOfServiceContent = TermsOfServiceContent()

class TermsOfServiceVC: UIViewController, UINavigationControllerDelegate {
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footer: UIView!

    var tableViewDataSource: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
        self.navigationItem.setHidesBackButton(true, animated: true)
        getUserSession()
        getUserAttributes()
        initalizeTableView()
        self.removeBackButtonNavigation()
    }

//    override func viewDidAppear(_ animated: Bool){
//        super.viewDidAppear(animated)
//    }

//    func checkIfAlreadyAccepted() {
////        print("rootView COntroller", self.rootViewController)
//        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
//
//        print("rootViewController", rootViewController)
//
//        let defaults = UserDefaults.standard
//        let keys = UserDefaultsKeys()
//        let isAlreadyAccepted = defaults.value(forKey: keys.isTermsAccepted) as! Int
//        print("isAlreadyAccepted", isAlreadyAccepted)
//        if isAlreadyAccepted == 1 {
//            print("inside alredduy accepted if")
//            DispatchQueue.main.async() {
//                self.performSegue(withIdentifier: "TOSToProfileSetup", sender: self)
//            }
//        }
//    }



    func initalizeTableView(){
        tableViewDataSource.append(termsOfServiceContent.title)
        tableViewDataSource.append(termsOfServiceContent.detailedTerms)
        tableView.dataSource = self
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
        acceptTNC(value: true)
        performSegue(withIdentifier: "TOSToProfileSetup", sender: self)
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
                // TODO: handle Email already Verified
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

extension TermsOfServiceVC:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if  let tosTitleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TOSTitleTableViewCell") as? TOSTitleTableViewCell {
            tosTitleTableViewCell.titleLabel.text = tableViewDataSource[indexPath.row]
            return tosTitleTableViewCell
        }
        return UITableViewCell()
    }
}

extension UIViewController {
    func removeBackButtonNavigation() {
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backBarButtonItem
    }
}
