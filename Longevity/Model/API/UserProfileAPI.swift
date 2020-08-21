//
//  UserProfileAPI.swift
//  Longevity
//
//  Created by vivek on 20/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import Amplify

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
      case .ACCOUNTCREATED: return UIImage(named: "checkinnotdone")
      case .FITBITSYNCED: return UIImage(named: "checkinnotdone")
      case .PROFILEUPDATED: return UIImage(named: "checkinnotdone")
      case .HEALTHPROFILECREATED: return UIImage(named: "checkinnotdone")
      case .HEALTHPROFILEUPDATED: return UIImage(named: "checkinnotdone")
      case .COVIDSYMPTOMSUPDATED: return UIImage(named: "checkinnotdone")
      case .SURVEYSAVED: return UIImage(named: "checkinnotdone")
      case .SURVEYSUBMITTED: return UIImage(named: "checkinnotdone")
    }
  }
}

struct UserActivity: Decodable {
    let title: String
    let username: String
    let activityType: UserActivityType
    let description: String
    let loggedAt: String
}

class UserProfileAPI: BaseAuthAPI {
    func getUserActivities(completion: @escaping (_ userActivities:[UserActivity])-> Void,
    onFailure: @escaping (_ error: Error)-> Void) {
        self.getCredentials(completion: { (credentials) in
            let headers = ["token":credentials.idToken, "login_type":Logintype.personal.rawValue]
            let queryParams = ["offset":"0", "limit":"100"]
            let request = RESTRequest(apiName: "rejuveDevelopmentAPI", path: "/user/activities", headers: headers,
                                      queryParameters: queryParams, body: nil)
            Amplify.API.get(request: request) { (result) in
                            switch result {
                            case .success(let data):
                                do {
                                    let decoder = JSONDecoder()
                                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                                    let value = try decoder.decode([UserActivity].self, from: data)
                                    completion(value)
                                }
                                catch {
                                    print("JSON error", error)
                                    onFailure(error)
                                }
                            case .failure(let error):
                                print(error.localizedDescription)
                                onFailure(error)
                                break
                            }
                        }
            
        }) { (error) in
            onFailure(error)
        }
    }
}
