//
//  UserDefaults.swift
//  Longevity
//
//  Created by vivek on 06/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation

struct MeasurementUnits {
    static let metric = "metric"
    static let imperial = "imperial"
}

struct UserDefaultsKeys {
    let name = "name"
    let weight = "weight"
    let height = "height"
    let gender = "gender"
    let birthday = "birthday"
    let unit = "unit"
    let isTermsAccepted = "isTermsAccepted"
    let devices = "devices"
    let providedPreExistingMedicalConditions = "providedPreExistingMedicalConditions"
    let notificationCount = "notificationCount"
    let failureNotificationCount = "failureNotificationCount"
    let setupProfileCompletionStatus = "setupProfileCompletionStatus"
    let deviceTokenForSNS = "deviceTokenForSNS"
    let endpointArnForSNS = "endpointArnForSNS"
}

func clearUserDefaults() {
    let domain = Bundle.main.bundleIdentifier!
    UserDefaults.standard.removePersistentDomain(forName: domain)
    UserDefaults.standard.synchronize()
    print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
}


//func incrementNotificationCount() {
//    let userDefaults = UserDefaults.standard
//    let keys = UserDefaultsKeys()
//
//    if let currentNotificationCount = userDefaults.value(forKey: keys.notificationCount) as? Int {
//        let updatedCount = currentNotificationCount + 1
//        userDefaults.set(updatedCount, forKey: keys.notificationCount)
//    } else {
//        userDefaults.set(1, forKey: keys.notificationCount)
//    }
//}

//func incrementFailureNotificationCount() {
//    let userDefaults = UserDefaults.standard
//    let keys = UserDefaultsKeys()
//
//    if let currentNotificationCount = userDefaults.value(forKey: keys.failureNotificationCount) as? Int {
//        let updatedCount = currentNotificationCount + 1
//        userDefaults.set(updatedCount, forKey: keys.failureNotificationCount)
//    } else {
//        userDefaults.set(1, forKey: keys.failureNotificationCount)
//    }
//}
