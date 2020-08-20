//
//  UserProfileAPI.swift
//  Longevity
//
//  Created by vivek on 20/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import Amplify


struct UserActivity: Decodable {
    let title: String
    let username: String
    let activityType: String
    let description: String
    let loggedAt: String
}

class UserProfileAPI: BaseAuthAPI {
    func getUserActivities(completion: @escaping (_ userActivities:[UserActivity])-> Void,
    onFailure: @escaping (_ error: Error)-> Void) {
        self.getCredentials(completion: { (credentials) in
            let headers = ["token":credentials.idToken, "login_type":Logintype.personal.rawValue]
            let queryParams = ["offset":"0", "limit":"10"]
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
