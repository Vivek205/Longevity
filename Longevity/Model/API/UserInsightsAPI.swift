//
//  UserInsightsAPI.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 11/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import Amplify
import SwiftyJSON

class UserInsightsAPI: BaseAuthAPI {
    
    static var instance = UserInsightsAPI()
    
    func get() {
        self.getCredentials(completion: { (credentials) in
            let headers = ["token":credentials.idToken, "login_type":LoginType.PERSONAL]
            let request = RESTRequest(apiName: "insightAPI", path: "/user/insight/REJUVE_COVID_APP", headers: headers, queryParameters: nil, body: nil)
            Amplify.API.get(request: request) { (result) in
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let value = try decoder.decode(GetQuestionResponse.self, from: data)
//                        response = value
//                        completion(value)
                    }
                    catch {
                        print("JSON error", error)
                    }
                }
            }
        }) { (error) in
            
        }
    }
}
