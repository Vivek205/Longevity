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

struct UserActivity: Decodable {
    let title: String
    let username: String
    let activityType: UserActivityType
    let description: String
    let loggedAt: String
    var isLast: Bool?
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
    
    func getUserAvatar(completion: @escaping (_ userActivities:String?)-> Void,
                        onFailure: @escaping (_ error: Error)-> Void) {
        self.getCredentials(completion: { (credentials) in
            let headers = ["token":credentials.idToken, "login_type":Logintype.personal.rawValue]
            let request = RESTRequest(apiName: "rejuveDevelopmentAPI", path: "/user/profile/picture", headers: headers,
                                      queryParameters: nil, body: nil)
            Amplify.API.get(request: request) { (result) in
                switch result {
                case .success(let data):
                    do {
                        let profileURL = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? String
                        print(profileURL)
                        completion(profileURL)
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
    
    func saveUserAvatar (profilePic: String,completion: @escaping (()-> Void), onFailure: @escaping (_ error: Error)-> Void) {
        self.getCredentials(completion: { (credentials) in
            let headers = ["token":credentials.idToken, "login_type":Logintype.personal.rawValue]
            
            let bodyData = Data(base64Encoded: profilePic)
            
            let request = RESTRequest(apiName: "rejuveDevelopmentAPI", path: "/user/profile/picture", headers: headers, queryParameters: nil, body: bodyData)
            Amplify.API.post(request: request) { (result) in
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let value = try decoder.decode(String.self, from: data)
                        print(value)
                    }
                    catch let error {
                        print("JSON error: ", error.localizedDescription)
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
