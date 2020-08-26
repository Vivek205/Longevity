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
    let email = "email"
}

func clearUserDefaults() {
    let domain = Bundle.main.bundleIdentifier!
    UserDefaults.standard.removePersistentDomain(forName: domain)
    UserDefaults.standard.synchronize()
    print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
}
