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
    
    func get(completion: @escaping([UserInsight]?) -> Void) {
//       self.getCredentials(completion: { (credentials) in
//            let headers = ["token":credentials.idToken, "login_type":Logintype.personal.rawValue]
//            let request = RESTRequest(apiName: "insightsAPI", path: "/user/insight/cards", headers: headers, queryParameters: nil, body: nil)
//            Amplify.API.get(request: request) { (result) in
//                switch result {
//                case .success(let data):
//                   print( String(data: data, encoding: .utf8))
//                    do {
//                        let decoder = JSONDecoder()
////                        decoder.keyDecodingStrategy = .convertFromSnakeCase
//                        let value = try decoder.decode([UserInsight].self, from: data)
//                        completion(value)
//                    }
//                    catch {
//                        print("JSON error", error)
//                        completion(nil)
//                    }
//                case .failure(let error):
//                    print(error.localizedDescription)
//                    completion(nil)
//                    break
//                }
//            }
//        }) { (error) in
//            print(error.localizedDescription)
//            completion(nil)
//        }
        
        let request = RESTRequest(apiName: "insightsAPI", path: "/user/insight/cards", headers: headers, queryParameters: nil, body: nil)
        self.makeAPICall(callType: .apiGET, request: request) { (data, error) in
            guard let data = data else  {
                completion(nil)
                return
            }
             do {
                 let decoder = JSONDecoder()
                 let value = try decoder.decode([UserInsight].self, from: data)
                 completion(value)
             }
             catch {
                 print("JSON error", error)
                 completion(nil)
             }
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
