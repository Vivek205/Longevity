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
    private let apiName:String = "rejuveDevelopmentAPI"

    func getUserSubscriptions() {

        self.getCredentials(completion: { [weak self] (credentials) in
             let headers = ["token":credentials.idToken, "login_type":Logintype.personal.rawValue]
            let path = "/user/subscriptions"
            let request = RESTRequest(apiName: "rejuveDevelopmentAPI", path: path,
                                      headers: headers, queryParameters: nil, body: nil)
            _ = Amplify.API.get(request: request, listener: { (result) in
                switch result {
                case .success(let data):
                    print(String(data:data, encoding: .utf8))
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
                case .failure(let error):
                    print("error", error)
                }
            })
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    func updateUserSubscriptions(userSubscriptions : [UserSubscription]?, completion: @escaping(() -> Void)){
        guard let userSubscriptions = userSubscriptions else {return}

        self.getCredentials(completion: { [weak self] (credentials) in
            let headers = ["token":credentials.idToken, "login_type":Logintype.personal.rawValue]
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
            _ = Amplify.API.post(request: request, listener: { (result) in
                print("result",result)
                switch result {
                case .success(let data):
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
                case .failure(let error):
                    completion()
                    print("error", error)
                }
            })
        }) { (error) in
             print(error.localizedDescription)
            completion()
        }
    }
}
