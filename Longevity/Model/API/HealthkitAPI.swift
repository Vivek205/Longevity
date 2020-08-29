//
//  HealthkitAPI.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 25/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import Amplify

struct Healthdata: Codable {
    let dataType: String
    let data: String
    let recordDate: String
}

class HealthkitAPI: BaseAuthAPI {
    func synchronizeHealthkit (healthData: String,completion: @escaping (()-> Void), onFailure: @escaping (_ error: Error)-> Void) {
        self.getCredentials(completion: { (credentials) in
            let headers = ["token":credentials.idToken, "login_type":Logintype.personal.rawValue]
            
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd"
            let date: String = dateformatter.string(from: Date())
            let healthdata = Healthdata(dataType: "HEART_RATE", data: healthData, recordDate: date)
            
            var bodyData:Data = Data()
            do {
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                bodyData = try encoder.encode([healthdata])
                
            } catch let error {
                print("body data error",error.localizedDescription)
            }
            
            let request = RESTRequest(apiName: "rejuveDevelopmentAPI", path: "/health/application/HEALTHKIT/synchronize", headers: headers, queryParameters: nil, body: bodyData)
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
