//
//  HealthkitAPI.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 25/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import Amplify

class HealthkitAPI: BaseAuthAPI {
    
    static var instance = HealthkitAPI()
    
    func synchronizeHealthkit (deviceName: String, healthData: Healthdata,completion: @escaping (()-> Void), onFailure: @escaping (_ error: Error)-> Void) {
//        self.getCredentials(completion: { (credentials) in
//            let headers = ["token":credentials.idToken, "login_type":Logintype.personal.rawValue]
            
            var bodyData:Data = Data()
            do {
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                bodyData = try encoder.encode([healthData])
                
            } catch let error {
                print("body data error",error.localizedDescription)
            }
            
            let request = RESTRequest(apiName: "rejuveDevelopmentAPI", path: "/health/application/\(deviceName)/synchronize", headers: headers, queryParameters: nil, body: bodyData)
            
        self.makeAPICall(callType: .apiPOST, request: request) { (data, error) in
            if error != nil {
                onFailure(error as! Error)
                return
            }
            
            guard let data = data else { return }
            let response = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? String
            print(response)
        }
        
//            Amplify.API.post(request: request) { (result) in
//                switch result {
//                case .success(let data):
//                    do {
//                        let reponse = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? String
//                        print(reponse)
//                    }
//                    catch let error {
//                        print("HEALTHKIT/synchronize JSON error: ", error.localizedDescription)
//                        onFailure(error)
//                    }
//                case .failure(let error):
//                    print(error.localizedDescription)
//                    onFailure(error)
//                    break
//                }
//            }
//        }) { (error) in
//            onFailure(error)
//        }
    }
}
