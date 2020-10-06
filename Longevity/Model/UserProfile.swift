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
    var weight: String
    var height: String
    var gender: String
    var birthday: String
    var unit: MeasurementUnits
    var devices: [String: [String: Int]]?
    var preconditions: [[String:String]]?
    var location: LocationDetails?
}

struct LocationDetails: Codable {
    var latitude: String?
    var longitude: String?
    var zipcode: String?
    var state: String?
    var city: String?
    var country: String?
}
