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
}

public var setupProfileOptionList:[Int: SetupProfileOption] = [
2: SetupProfileOption(image: #imageLiteral(resourceName: "Icon-Apple-Health"), label: "Sync Apple Health Profile", buttonText: "SYNC"),
3: SetupProfileOption(image: #imageLiteral(resourceName: "icon: Gender"), label: "Gender"),
4: SetupProfileOption(image: #imageLiteral(resourceName: "icon: face"), label: "Age"),
5: SetupProfileOption(image: #imageLiteral(resourceName: "weight-icon"), label: "Height"),
6: SetupProfileOption(image: #imageLiteral(resourceName: "weight-icon"), label: "Weight"),
7: SetupProfileOption(image: #imageLiteral(resourceName: "location-icon"), label: "Location"),
8: SetupProfileOption(image: #imageLiteral(resourceName: "location-icon"), label: "Ethnicity (Optional)")
]


struct SetupProfileConnectDeviceOption {
    let image: UIImage
    let title: String
    let description: String
}

var setupProfileConnectDeviceOptionList:[Int: SetupProfileConnectDeviceOption] = [
    2: SetupProfileConnectDeviceOption(image: #imageLiteral(resourceName: "icon:  fitbit logo"), title: "Fitbit", description: "Wearable device that tracks general health metrics"),
    3: SetupProfileConnectDeviceOption(image: #imageLiteral(resourceName: "icon:apple dark"), title: "Apple Watch 2-3", description: "Wearable device that tracks general health metrics"),
//    4: SetupProfileConnectDeviceOption(image: #imageLiteral(resourceName: "icon:Kinsa_Heart_Logo"), title: "Kinsa", description: "smart thermometer that you use orally? for tempeature tracking"),
//    5: SetupProfileConnectDeviceOption(image: #imageLiteral(resourceName: "icon:iOximeter"), title: "iOximeter", description: "Smart heart monitor that you use on your finger")
]
