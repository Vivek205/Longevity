//
//  UserPreferenceAPI.swift
//  Longevity
//
//  Created by vivek on 16/09/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Amplify

struct UserPreference:Codable {
    let preferenceType: UserPreferenceType
    let communicationType: CommunicationType
    let source = "REJUVE_APP"
    var status:Bool
}

enum UserPreferenceType:String, Codable {
    case longevityRelease = "LONGEVITY_RELEASE"
}

enum CommunicationType:String, Codable {
    case email = "EMAIL"
}

class UserPreferenceAPI: BaseAuthAPI {
    private let apiName:String = "rejuveDevelopmentAPI"

    func getUserPreferences() {
        let path = "/user/notification/preference"
        self.getCredentials(completion: { [weak self] (credentials) in
             let headers = ["token":credentials.idToken, "login_type":Logintype.personal.rawValue]
            let request = RESTRequest(apiName: self?.apiName, path: path,
                                      headers: headers, queryParameters: nil, body: nil)
            _ = Amplify.API.get(request: request, listener: { (result) in
                switch result {
                case .success(let data):
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try jsonDecoder.decode([UserPreference].self, from: data)
                        AppSyncManager.instance.userPreferences.value = value
                    } catch  {
                        print("json error", error)
                    }
                case .failure(let error):
                    print("error")
                }
                print("result",result)
            })
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    func updateUserPreferences(userPreferences : [UserPreference]?){
        guard let userPreferences = userPreferences else {return}
        let path = "/user/notification/preference"
        self.getCredentials(completion: { [weak self] (credentials) in
            let headers = ["token":credentials.idToken, "login_type":Logintype.personal.rawValue]
            let jsonEncoder = JSONEncoder()
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
            var data:Data
            do {
                data = try jsonEncoder.encode(userPreferences)
                print(String(data: data, encoding: .utf8))
            }catch {
                print("json error", error)
                return
            }

            let request = RESTRequest(apiName: self?.apiName, path: path,
            headers: headers, queryParameters: nil, body: data)
            _ = Amplify.API.post(request: request, listener: { (result) in
                print("result",result)
                switch result {
                case .success(let data):
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try jsonDecoder.decode([UserPreference].self, from: data)
                        AppSyncManager.instance.userPreferences.value = value
                    } catch  {
                        print("json error", error)
                    }
                case .failure(let error):
                    print("error")
                }
            })
        }) { (error) in
             print(error.localizedDescription)
        }
    }
}
