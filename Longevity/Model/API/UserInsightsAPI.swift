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
//        var userInsights: [UserInsight] = [
//        UserInsight(cardName: "COVID-19 Infection", cardType: "", description: "COVID-19 Infection",
//                    details: UserInsightDetails(name: "COVID-19 Infection", riskLevel: .medium, trend: .uptrend, confidence: "", exposureHistory: [])),
//        UserInsight(cardName: "COVID-19 Infection", cardType: "", description: "COVID-19 Infection",
//                    details: UserInsightDetails(name: "Social Distancing", riskLevel: .lowLevel, trend: .same, confidence: "", exposureHistory: [])),
//        UserInsight(cardName: "COVID-19 Infection", cardType: "", description: "COVID-19 Infection",
//                    details: UserInsightDetails(name: "COVID-19 Exposure", riskLevel: .high, trend: .down, confidence: "", exposureHistory: []))]
//        return userInsights
        self.getCredentials(completion: { (credentials) in
            let headers = ["token":credentials.idToken, "login_type":Logintype.personal.rawValue]
            let request = RESTRequest(apiName: "insightsAPI", path: "/user/insight/cards", headers: headers, queryParameters: nil, body: nil)
            Amplify.API.get(request: request) { (result) in
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let value = try decoder.decode([UserInsight].self, from: data)
                        completion(value)
                    }
                    catch {
                        print("JSON erro    r", error)
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

    func exportUserApplicationData(completion: @escaping() -> Void, onFailure: @escaping(_ error:Error) -> Void) {
        self.getCredentials(completion: { (credentials) in
            let headers = ["token":credentials.idToken, "login_type":Logintype.personal.rawValue]
            let request = RESTRequest(apiName: "rejuveDevelopmentAPI", path: "/user/application/data/export",
                                      headers: headers, queryParameters: nil, body: nil)
            Amplify.API.get(request: request) { (result) in
                switch result {
                case .success(_):
                    completion()
                case .failure(let error):
                    onFailure(error)
                }
            }

        }) { (error) in
            print("exportUserApplicationData error", error)
        }
    }
}
