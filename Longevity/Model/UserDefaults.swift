//
//  UserDefaults.swift
//  Longevity
//
//  Created by vivek on 06/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation

enum MeasurementUnits: String, Codable {
    case metric = "metric"
    case imperial = "imperial"
}

extension MeasurementUnits {
    var weight:String {
        switch self {
        case .metric:
            return "kg"
        case .imperial:
            return "lbs"
        }
    }

    var height: String {
        switch self {
        case .metric:
            return "cm"
        case .imperial:
            return "ft"
        }
    }
}

struct UserDefaultsKeys {
    let name = "name"
    let weight = "weight"
    let height = "height"
    let gender = "gender"
    let birthday = "birthday"
    let phone = "phone"
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
    let logger = "logger"
}

func clearUserDefaults() {
    let domain = Bundle.main.bundleIdentifier!
    UserDefaults.standard.removePersistentDomain(forName: domain)
    UserDefaults.standard.synchronize()
    print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
}
