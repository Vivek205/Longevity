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
    
    func get() -> [UserInsight] {
        var userInsights: [UserInsight] = [
        UserInsight(cardName: "COVID-19 Infection", cardType: "", description: "COVID-19 Infection",
                    details: UserInsightDetails(name: "COVID-19 Infection", riskLevel: .medium, trend: .uptrend, confidence: "", exposureHistory: [])),
        UserInsight(cardName: "COVID-19 Infection", cardType: "", description: "COVID-19 Infection",
                    details: UserInsightDetails(name: "Social Distancing", riskLevel: .lowLevel, trend: .same, confidence: "", exposureHistory: [])),
        UserInsight(cardName: "COVID-19 Infection", cardType: "", description: "COVID-19 Infection",
                    details: UserInsightDetails(name: "COVID-19 Exposure", riskLevel: .high, trend: .down, confidence: "", exposureHistory: []))]
        return userInsights
//        self.getCredentials(completion: { (credentials) in
//            let headers = ["token":credentials.idToken, "login_type":Logintype.personal.rawValue]
//            let request = RESTRequest(apiName: "insightsAPI", path: "/user/insight/REJUVE_COVID_APP", headers: headers, queryParameters: nil, body: nil)
//            Amplify.API.get(request: request) { (result) in
//                switch result {
//                case .success(let data):
//                    do {
//                        let decoder = JSONDecoder()
//                        decoder.keyDecodingStrategy = .convertFromSnakeCase
//                        let value = try decoder.decode(GetQuestionResponse.self, from: data)
////                        response = value
//                        //completion(value)
//                    }
//                    catch {
//                        print("JSON error", error)
//                    }
//                case .failure(let error):
//                    print(error.localizedDescription)
//                    break
//
//                }
//            }
//        }) { (error) in
//            print(error.localizedDescription)
//        }
        
        
    }
}