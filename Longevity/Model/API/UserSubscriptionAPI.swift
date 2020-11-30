//
//  UserPreferenceAPI.swift
//  Longevity
//
//  Created by vivek on 16/09/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Amplify

struct UserSubscriptionResponse: Codable {
    let status:String
    let data: [UserSubscription]?
}

struct UserSubscription:Codable {
    let subscriptionType: UserSubscriptionType
    let communicationType: CommunicationType
    let source = "REJUVE_APP"
    var status:Bool
}

enum UserSubscriptionType:String, Codable {
    case longevityRelease = "LONGEVITY_RELEASE"
}

enum CommunicationType:String, Codable {
    case email = "EMAIL"
}

class UserSubscriptionAPI: BaseAuthAPI {
    
    static var instance = UserSubscriptionAPI()
    
    private let apiName:String = "rejuveDevelopmentAPI"
    
    func getUserSubscriptions() {
        let path = "/user/subscriptions"
        let request = RESTRequest(apiName: "rejuveDevelopmentAPI", path: path,
                                  headers: headers, queryParameters: nil, body: nil)
        
        self.makeAPICall(callType: .apiGET, request: request) { (data, error) in
            if error != nil {
                print("error", error)
            }
            
            guard let data = data else { return }
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let value = try jsonDecoder.decode(UserSubscriptionResponse.self, from: data)
                print("value", value)
                if let subscriptionData = value.data {
                    AppSyncManager.instance.userSubscriptions.value = subscriptionData
                }
            } catch  {
                print("json error", error)
            }
        }
    }
    
    func updateUserSubscriptions(userSubscriptions : [UserSubscription]?, completion: @escaping(() -> Void)){
        guard let userSubscriptions = userSubscriptions else {return}
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        var data:Data
        do {
            data = try jsonEncoder.encode(userSubscriptions)
            print(String(data: data, encoding: .utf8))
        }catch {
            print("json error", error)
            completion()
            return
        }
        let path = "/user/subscriptions"
        let request = RESTRequest(apiName: "rejuveDevelopmentAPI", path: path,
                                  headers: headers, queryParameters: nil, body: data)
        
        self.makeAPICall(callType: .apiPOST, request: request) { (data, error) in
            if error != nil {
                completion()
                print("error", error)
            }
            
            guard let data = data else { return }
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let value = try jsonDecoder.decode(UserSubscriptionResponse.self, from: data)
                print("value", value)
                if let subscriptionData = value.data {
                    AppSyncManager.instance.userSubscriptions.value = subscriptionData
                }
                completion()
            } catch  {
                print("json error", error)
                completion()
            }
        }
    }
}
