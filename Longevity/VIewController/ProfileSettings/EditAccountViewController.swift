//
//  EditAccountViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 27/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class EditAccountViewController: UIViewController {
    
    lazy var fullName: UITextField = {
        let name = UITextField()
        name.font = UIFont(name: "Montserrat-Regular", size: 16.0)
        name.clearButtonMode = .whileEditing
        name.textContentType = .name
        name.placeholder = "Full Name"
        name.autocorrectionType = .no
        name.returnKeyType = .done
        name.borderStyle = .roundedRect
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }()
    
    lazy var emailText: UITextField = {
        let email = UITextField()
        email.font = UIFont(name: "Montserrat-Regular", size: 16.0)
        email.clearButtonMode = .whileEditing
        email.textContentType = .emailAddress
        email.placeholder = "Email address"
        email.borderStyle = .roundedRect
        email.isEnabled = false
        email.translatesAutoresizingMaskIntoConstraints = false
        return email
    }()
    
    lazy var mobilePhone: UITextField = {
        let mobile = UITextField()
        mobile.font = UIFont(name: "Montserrat-Regular", size: 16.0)
        mobile.clearButtonMode = .whileEditing
        mobile.textContentType = .name
        mobile.placeholder = "Full Name"
        mobile.autocorrectionType = .no
        mobile.returnKeyType = .done
        mobile.borderStyle = .roundedRect
        mobile.translatesAutoresizingMaskIntoConstraints = false
        return mobile
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
