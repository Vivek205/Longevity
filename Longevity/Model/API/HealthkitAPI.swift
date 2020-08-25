//
//  HealthkitAPI.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 25/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import SwiftyJSON
import Amplify

class HealthkitAPI: BaseAuthAPI {
    func synchronizeHealthkit (completion: @escaping (_ userActivities:[UserActivity])-> Void,
    onFailure: @escaping (_ error: Error)-> Void) {
        self.getCredentials(completion: { (credentials) in
            let headers = ["token":credentials.idToken, "login_type":Logintype.personal.rawValue]
//            let queryParams = ["offset":"0", "limit":"10"]

            let body = JSON(["data": ["heartbeat": [], "sleep": []]])

            var bodyData:Data = Data()
            do {
                bodyData = try body.rawData()

            } catch  {
                print("body data error",error)
            }
            
            let request = RESTRequest(apiName: "healthkitAPI", path: "/health/application/HEALTHKIT/synchronize", headers: headers,
                                      queryParameters: nil, body: bodyData)
            Amplify.API.post(request: request) { (result) in
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

