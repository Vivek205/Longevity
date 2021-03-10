//
//  UserProfileAPI.swift
//  Longevity
//
//  Created by vivek on 20/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import Amplify
import SwiftyJSON

struct UserProfileResponse: Decodable {
    let status: Int
    let message: String
    let data: UserProfilePartial
}

struct UserProfilePartial: Decodable {
    var id: String?
    var name: String? // shall I make this var?
    let email: String?
    var phone: String?
}

struct HealthProfileResponse:Decodable {
    let data: UserHealthProfile
}

class UserProfileAPI: BaseAuthAPI {
    
    static var instance = UserProfileAPI()
    
    func getProfile(completion: @escaping ((UserProfile?)-> Void)) {
        
        let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/profile" , headers: headers)
        
        self.makeAPICall(callType: .apiGET, request: request) { (data, error) in
            if error != nil {
                print("getProfile failed \(error!.localizedDescription)")
                completion(nil)
            }
            
            guard let data = data else { return }
            
            do {
                let jsonDecoder = JSONDecoder()
                print("user profile string", String(data: data, encoding: .utf8))
                let userProfileResponse = try jsonDecoder.decode(UserProfileResponse.self, from: data)
                guard let email = userProfileResponse.data.email else {completion(nil);return}
                var userProfile = UserProfile(name: "User", email: email, phone: "")
                if let name = userProfileResponse.data.name, !name.isEmpty {
                    userProfile.name = name
                }
                if let phone = userProfileResponse.data.phone, !phone.isEmpty {
                    userProfile.phone = phone
                }
                completion(userProfile)
            } catch {
                print("json decode error", error)
                completion(nil)
            }
        }
    }
    
    func getHealthProfile(completion: @escaping ((UserHealthProfile?)-> Void)) {
        
        let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/health/profile" , headers: headers)
        
        self.makeAPICall(callType: .apiGET, request: request) { (data, error) in
            if error != nil {
                print("get Health Profile failed \(error!.localizedDescription)")
                completion(nil)
            }
            
            guard let data = data else { return }
            
            do {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedData = try jsonDecoder.decode(HealthProfileResponse.self, from: data)
                print(decodedData)

                if let preExistingConditions = decodedData.data.preExistingConditions {
                    preExistingConditions.forEach({ (condition) in
                        if condition["type"] == "OTHER" {
                            preExistingMedicalCondtionOtherText = condition["condition"]
                            return
                        }
                        guard let optionIndex = preExistingMedicalConditionData.firstIndex(where: { (element) -> Bool in
                            return element.id.rawValue == condition["condition"]
                        }) else { return }
                        preExistingMedicalConditionData[optionIndex].selected = true
                    })
                }
                completion(decodedData.data)
            } catch {
                print("json parse error", error)
            }
        }
    }
    
    func getUserActivities(offset:Int = 0 ,limit:Int = 10 ,completion: @escaping (_ userActivities:UserActivity)-> Void,
                           onFailure: @escaping (_ error: Error)-> Void) {

        let queryParams = ["offset":"\(offset)", "limit":"\(limit)"]
        let request = RESTRequest(apiName: "rejuveDevelopmentAPI", path: "/user/activities", headers: headers,
                                  queryParameters: queryParams, body: nil)
        
        self.makeAPICall(callType: .apiGET, request: request) { (data, error) in
            if error != nil {
                print(error!.localizedDescription)
                onFailure(error!)
            }
            
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let value = try decoder.decode(UserActivity.self, from: data)
                completion(value)
            }
            catch {
                print("JSON error", error)
                onFailure(error)
            }
        }
    }
    
    func getAppLink(completion: @escaping(String?) -> Void) {
        guard let appurl = URL(string: "https://rejuve-public.s3-us-west-2.amazonaws.com/app-location") else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: appurl) { (data, response, error) in
            if error != nil {
                completion(nil)
            } else {
                guard let data = data else {
                    completion(nil)
                    return
                }
                let urlString = String(data: data, encoding: .utf8)
                completion(urlString)
            }
        }.resume()
    }
    
    func getUserAvatar(completion: @escaping (_ userActivities:String?)-> Void,
                       onFailure: @escaping (_ error: Error)-> Void) {
//        self.getCredentials(completion: { (credentials) in
//            let headers = ["token":credentials.idToken, "login_type":Logintype.personal.rawValue]
            let request = RESTRequest(apiName: "rejuveDevelopmentAPI", path: "/user/profile/picture", headers: headers,
                                      queryParameters: nil, body: nil)

        self.makeAPICall(callType: .apiGET, request: request) { (data, error) in
            if error != nil {
                print(error!.localizedDescription)
                onFailure(error!)
            } else {
                guard  let data = data else {
                    return
                }
                
                let profileURL = String(data: data, encoding: .utf8)
                completion(profileURL)
            }
        }
        
//            Amplify.API.get(request: request) { (result) in
//                switch result {
//                case .success(let data):
//                    do {
//                        let profileURL = String(data: data, encoding: .utf8)
//                        completion(profileURL)
//                    }
//                    catch {
//                        print("JSON error", error)
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
    
    func saveUserAvatar (profilePic: String,completion: @escaping (()-> Void), onFailure: @escaping (_ error: Error)-> Void) {
//        self.getCredentials(completion: { (credentials) in
//            let headers = ["token":credentials.idToken, "login_type":Logintype.personal.rawValue]
            
            let parameters: [String: String] = [
                "image": profilePic
            ]
            
            guard let bodyData:Data = profilePic.data(using: .utf8, allowLossyConversion: false) else { return }
            
            let request = RESTRequest(apiName: "rejuveDevelopmentAPI", path: "/user/profile/picture", headers: headers, queryParameters: nil, body: bodyData)
        
        self.makeAPICall(callType: .apiPOST, request: request) { (data, error) in
            if let error = error {
                print("JSON error: ", error.localizedDescription)
                onFailure(error)
            }
            
            guard let data = data else { return }
            
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
        }
//
//            Amplify.API.post(request: request) { (result) in
//                switch result {
//                case .success(let data):
//                    do {
//                        let decoder = JSONDecoder()
//                        decoder.keyDecodingStrategy = .convertFromSnakeCase
//                        let value = try decoder.decode(String.self, from: data)
//                        print(value)
//                    }
//                    catch let error {
//                        print("JSON error: ", error.localizedDescription)
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
    
    func saveUserHealthProfile(healthProfile: UserHealthProfile,completion: @escaping (()-> Void), onFailure: @escaping (_ error: Error)-> Void) {
//        self.getCredentials(completion: { (credentials) in
//            let headers = ["token":credentials.idToken, "login_type":Logintype.personal.rawValue]
            let keys = UserDefaultsKeys()

            guard var enhancedHealthProfile = healthProfile.dictionary else {
                return
            }

            if healthProfile.birthday.isEmpty {
                enhancedHealthProfile.removeValue(forKey: keys.birthday)
            }

            var bodyData:Data = Data()
            do {
                let jsonEncoder = JSONEncoder()
                jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
                bodyData = try JSONSerialization.data(withJSONObject: enhancedHealthProfile)
                print(String(data: bodyData, encoding: .utf8))
            } catch  {
                print(error)
            }
            
            let request = RESTRequest(apiName: "rejuveDevelopmentAPI", path: "/health/profile", headers: headers, body: bodyData)
        
        self.makeAPICall(callType: .apiPOST, request: request) { (data, error) in
            
        }
            Amplify.API.post(request: request) { (result) in
                switch result {
                case .success(let data):
                    let responseString = String(data: data, encoding: .utf8)
                    print("sucess \(responseString)")
                    completion()
                case .failure(let error):
                    print(error.localizedDescription)
                    onFailure(error)
                    break
                }
            }
//        }) { (error) in
//            onFailure(error)
//        }
    }
}
