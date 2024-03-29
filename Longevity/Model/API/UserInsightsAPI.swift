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
        self.isSyncInprogress = true
        let request = RESTRequest(apiName: "insightsAPI",
                                  path: "/user/insight/cards",
                                  headers: headers,
                                  queryParameters: nil,
                                  body: nil)
        self.makeAPICall(callType: .apiGET, request: request) { [weak self] (data, error) in
            self?.isSyncInprogress = false
            guard let data = data else  {
                completion(nil)
                return
            }
            do {
                let decoder = JSONDecoder()
                let value = try decoder.decode([UserInsight].self, from: data)
                completion(value)
            } catch {
                print("JSON error", error)
                completion(nil)
            }
        }
    }
    
    func get(submissionID: String, completion: @escaping([UserInsight]?) -> Void) {
        let params = submissionID.isEmpty ? nil : ["submission_id": submissionID ]
        let request = RESTRequest(apiName: "insightsAPI",
                                  path: "/user/insight/cards",
                                  headers: headers,
                                  queryParameters: params,
                                  body: nil)
        self.makeAPICall(callType: .apiGET, request: request) { (data, error) in
            guard let data = data else  {
                completion(nil)
                return
            }
             do {
                 let decoder = JSONDecoder()
                 let value = try decoder.decode([UserInsight].self, from: data)
                 completion(value)
             } catch {
                 print("JSON error", error)
                 completion(nil)
             }
        }
    }

    func exportUserApplicationData(submissionID: String? = nil,
                                   completion: @escaping() -> Void,
                                   onFailure: @escaping(_ error:Error) -> Void) {
        let params = (submissionID?.isEmpty ?? true) ? nil : ["submission_id": submissionID ?? ""]
        let request = RESTRequest(apiName: "rejuveDevelopmentAPI",
                                  path: "/user/application/data/export",
                                  headers: headers,
                                  queryParameters: params,
                                  body: nil)
        self.makeAPICall(callType: .apiGET, request: request) { (data, error) in
            if error != nil {
                print(error)
                onFailure(error!)
                return
            }
            
            guard data != nil else { return }
            completion()
        }
    }
    
    func getLog(completion: @escaping(CheckInLog?) -> Void) {
        let request = RESTRequest(apiName: "insightsAPI",
                                  path: "/user/insight/logs",
                                  headers: headers,
                                  queryParameters: nil,
                                  body: nil)
        self.makeAPICall(callType: .apiGET, request: request) { (data, error) in
            guard let data = data else  {
                completion(nil)
                return
            }
            do {
                let decoder = JSONDecoder()
                let value = try decoder.decode(CheckInLog.self, from: data)
                completion(value)
            } catch {
                print("JSON error", error)
                completion(nil)
            }
        }
    }
    
    func getLog(submissionID: String, completion: @escaping(CheckInLog?) -> Void) {
        let request = RESTRequest(apiName: "insightsAPI",
                                  path: "/user/insight/logs",
                                  headers: headers,
                                  queryParameters: ["submission_id": submissionID],
                                  body: nil)
        self.makeAPICall(callType: .apiGET, request: request) { (data, error) in
            guard let data = data else  {
                completion(nil)
                return
            }
            do {
                let decoder = JSONDecoder()
                let value = try decoder.decode(CheckInLog.self, from: data)
                completion(value)
            } catch {
                print("JSON error", error)
                completion(nil)
            }
        }
    }
}
