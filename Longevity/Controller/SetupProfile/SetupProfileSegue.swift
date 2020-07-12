////
////  SetupProfileSegue.swift
////  Longevity
////
////  Created by vivek on 10/07/20.
////  Copyright © 2020 vivek. All rights reserved.
////
//
//import UIKit
//
//class SetupProfileSegue: UIStoryboardSegue {
//
//    override func perform() {
//        let defaults = UserDefaults.standard
//        let keys = UserDefaultsKeys()
//
//        let isTermsAccepted = defaults.bool(forKey: keys.isTermsAccepted)
//        print("isTermsAccepted", isTermsAccepted)
//
//        if isTermsAccepted == true {
//            destination = SetupProfileNotificationVC
//        }
//    }
//
//}
