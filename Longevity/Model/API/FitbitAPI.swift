//
//  FitbitAPI.swift
//  COVID Signals
//
//  Created by Jagan Kumar Mudila on 10/12/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import Amplify
import SwiftyJSON

class FitbitAPI: BaseAuthAPI {
    
    static var instance = FitbitAPI()
    
    func publishData(accessToken: String, userId: String) {
                   let body = JSON(["access_token":accessToken, "user_id":userId])
                   var bodyData:Data = Data()
                   do {
                       bodyData = try body.rawData()
                   } catch  {
                       print(error)
                   }
                   let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/health/application/FITBIT/synchronize" , headers: headers, body: bodyData)
        self.makeAPICall(callType: .apiPOST, request: request) { (data, error) in
            if let error = error {
                print(" publish data error \(error)")
                Logger.log("Fitbit publish failure \(error)")
            }
            guard let data = data else { return }
            let responseString = String(data: data, encoding: .utf8)
            Logger.log("Fitbit data published")
        }
    }
}
