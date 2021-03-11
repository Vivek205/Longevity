//
//  UserActivityDetails.swift
//  COVID Signals
//
//  Created by Jagan Kumar Mudila on 10/03/2021.
//  Copyright © 2021 vivek. All rights reserved.
//

import Foundation

enum UserActivityType: String, Codable {
    case ACCOUNTCREATED = "ACCOUNT_CREATED"
    case FITBITSYNCED = "FITBIT_SYNCED"
    case PROFILEUPDATED = "USER_PROFILE_UPDATED"
    case HEALTHPROFILECREATED = "HEALTH_PROFILE_CREATED"
    case HEALTHPROFILEUPDATED = "HEALTH_PROFILE_UPDATED"
    case COVIDSYMPTOMSUPDATED = "COVID_SYMPTOMS_UPDATED"
    case SURVEYSAVED = "SURVEY_SAVED"
    case SURVEYSUBMITTED = "SURVEY_SUBMITTED"
}
extension UserActivityType {
    var activityIcon: UIImage? {
        switch self {
        case .ACCOUNTCREATED: return UIImage(named: "activity : Account born")
        case .FITBITSYNCED: return UIImage(named: "activity : Fitbit Sync")
        case .PROFILEUPDATED: return UIImage(named: "activity : Health profile")
        case .HEALTHPROFILECREATED: return UIImage(named: "activity : Health profile")
        case .HEALTHPROFILEUPDATED: return UIImage(named: "activity : Health profile")
        case .COVIDSYMPTOMSUPDATED: return UIImage(named: "activity : covid checkin")
        case .SURVEYSAVED: return UIImage(named: "activity : mvp covid survey")
        case .SURVEYSUBMITTED: return UIImage(named: "activity : mvp covid survey")
        }
    }
}

struct UserActivityDetails: Decodable {
    let title: String
    let username: String
    let activityType: UserActivityType
    let description: String
    let loggedAt: String
    var isLast: Bool?
    var isLoading: Bool?
}

struct UserActivity: Decodable {
    let offset: Int
    let limit: Int
    let totalActivitiesCount: Int
    var activities: [UserActivityDetails]
}
