//
//  UserProfile.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 31/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation

struct UserProfile: Codable {
    var name: String // shall I make this var?
    let email: String
    var phone: String
}

struct UserHealthProfile: Codable {
    let weight: String
    let height: String
    let gender: String
    let birthday: String
    let unit: MeasurementUnits
    var devices: [String: [String: Int]]?
    let preconditions: [[String:String]]?
}
