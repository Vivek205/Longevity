//
//  SetupProfile.swift
//  Longevity
//
//  Created by vivek on 26/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import UIKit

public struct SetupProfileOption {
    let image: UIImage
    let label: String
    var buttonText: String = "ENTER"
    var isSynced: Bool = false
}

enum SetupProfileCompletionStatus: String {
    case onboarding
    case acceptTerms
    case disclaimer
    case biodata
    case notifications
    case connectDevices
    case preExistingConditions
    case complete
}


public var setupProfileOptionList:[Int: SetupProfileOption] = [
    2: SetupProfileOption(image: #imageLiteral(resourceName: "Icon-Apple-Health"), label: "Apple Health", buttonText: "SYNC"),
    3: SetupProfileOption(image: #imageLiteral(resourceName: "icon: Gender"), label: "Gender"),
    4: SetupProfileOption(image: UIImage(named: "icon : Age") ?? UIImage(), label: "Age"),
    5: SetupProfileOption(image: UIImage(named: "icon : height") ?? UIImage(), label: "Height"),
    6: SetupProfileOption(image: UIImage(named: "icon : weight") ?? UIImage(), label: "Weight")
    //7: SetupProfileOption(image: #imageLiteral(resourceName: "location-icon"), label: "Location"),
    //8: SetupProfileOption(image: #imageLiteral(resourceName: "location-icon"), label: "Ethnicity (Optional)")
]


struct SetupProfileConnectDeviceOption {
    let image: UIImage
    let title: String
    let description: String
    var isConnected: Bool = false
}

var setupProfileConnectDeviceOptionList:[Int: SetupProfileConnectDeviceOption] = [
    2: SetupProfileConnectDeviceOption(image: #imageLiteral(resourceName: "icon:  fitbit logo"), title: "Fitbit", description: "Wearable device that tracks general health metrics"),
    3: SetupProfileConnectDeviceOption(image: #imageLiteral(resourceName: "icon: apple watch"), title: "Apple Watch", description: "Wearable device that tracks general health metrics"),
    //    4: SetupProfileConnectDeviceOption(image: #imageLiteral(resourceName: "icon:Kinsa_Heart_Logo"), title: "Kinsa", description: "smart thermometer that you use orally? for tempeature tracking"),
    //    5: SetupProfileConnectDeviceOption(image: #imageLiteral(resourceName: "icon:iOximeter"), title: "iOximeter", description: "Smart heart monitor that you use on your finger")
]

//
//func updateSetupProfileCompletionStatus(currentState:SetupProfileCompletionStatus) {
//    let defaults = UserDefaults.standard
//    let keys = UserDefaultsKeys()
//    defaults.set(currentState.rawValue, forKey: keys.setupProfileCompletionStatus)
//}

//func getCurrentProfileCompletionStatus() -> SetupProfileCompletionStatus {
//    let defaults = UserDefaults.standard
//    let keys = UserDefaultsKeys()
//    if let rawValue = defaults.value(forKey: keys.setupProfileCompletionStatus) as? String{
//        let currentStatus = SetupProfileCompletionStatus(rawValue: rawValue) ?? .onboarding
//        return currentStatus
//    }
//    // Default Value
//    return .onboarding
//}
