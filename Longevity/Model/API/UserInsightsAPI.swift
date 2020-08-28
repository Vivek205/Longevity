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
    
    func get(completion: @escaping([UserInsight]) -> Void) {
       self.getCredentials(completion: { (credentials) in
            let headers = ["token":credentials.idToken, "login_type":Logintype.personal.rawValue]
            let request = RESTRequest(apiName: "insightsAPI", path: "/user/insight/cards", headers: headers, queryParameters: nil, body: nil)
            Amplify.API.get(request: request) { (result) in
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let value = try decoder.decode([UserInsight].self, from: data)
                        completion(value)
                    }
                    catch {
                        print("JSON error", error.localizedDescription)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    break
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
