//
//  UserDefaults.swift
//  Longevity
//
//  Created by vivek on 06/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation

enum MeasurementUnits: String, Codable {
    case metric
    case imperial
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

struct UserDefaultsKeys: PropertyLoopable {
    static let instance: UserDefaultsKeys = UserDefaultsKeys()
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
    let snsARN = "endpointArnForSNS"
    let email = "email"
    let logger = "logger"
    let healthkitBioConnected = "healthkitBioConnected"
}

func clearUserDefaults() {
    AppSyncManager.instance.userNotification.value?.endpointArn = nil
    AppSyncManager.instance.userNotification.value?.isEnabled = false
    AppSyncManager.instance.cleardata()
    
    do {
        let allProperties = try UserDefaultsKeys.instance.allProperties()
        allProperties.forEach { (property) in
            print("property", property.key, property.value)
        }
        print(try UserDefaultsKeys.instance.allProperties())
    } catch _ {}
}


protocol PropertyLoopable
{
    func allProperties() throws -> [String: Any]
}

extension PropertyLoopable
{
    func allProperties() throws -> [String: Any] {

        var result: [String: Any] = [:]

        let mirror = Mirror(reflecting: self)

        guard let style = mirror.displayStyle, style == .struct || style == .class else {
            //throw some error
            throw NSError(domain: "hris.to", code: 777, userInfo: nil)
        }

        for (labelMaybe, valueMaybe) in mirror.children {
            guard let label = labelMaybe else {
                continue
            }

            result[label] = valueMaybe
        }

        return result
    }
}
