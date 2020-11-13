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

enum UserActivityType: String, Codable {
    case ACCOUNTCREATED = "ACCOUNT_CREATED"
    case FITBITSYNCED = "FITBIT_SYNCED"
    case PROFILEUPDATED = "USER_PROFILE_UPDATED"
    case HEALTHPROFILECREATED = "HEALTH_PROFILE_CREATED"
    case HEALTHPROFILEUPDATED = "HEALTH_PROFILE_UPDATED"
    case COVIDSYMPTOMSUPDATED = "COVID_SYMPTOMS_UPDATED"
    case SURVEYSAVED = "SURVEY_SAVED"
    case SURVEYSUBMITTED = "SURVEY_SUBMITTED"
}
extension UserActivityType {
    var activityIcon: UIImage? {
        switch self {
        case .ACCOUNTCREATED: return UIImage(named: "activity : Account born")
        case .FITBITSYNCED: return UIImage(named: "activity : Fitbit Sync")
        case .PROFILEUPDATED: return UIImage(named: "activity : Health profile")
        case .HEALTHPROFILECREATED: return UIImage(named: "activity : Health profile")
        case .HEALTHPROFILEUPDATED: return UIImage(named: "activity : Health profile")
        case .COVIDSYMPTOMSUPDATED: return UIImage(named: "activity : covid checkin")
        case .SURVEYSAVED: return UIImage(named: "activity : mvp covid survey")
        case .SURVEYSUBMITTED: return UIImage(named: "activity : mvp covid survey")
        }
    }
}

struct UserActivityDetails: Decodable {
    let title: String
    let username: String
    let activityType: UserActivityType
    let description: String
    let loggedAt: String
    var isLast: Bool?
    var isLoading: Bool?
}

struct UserActivity: Decodable {
    let offset: Int
    let limit: Int
    let totalActivitiesCount: Int
    var activities: [UserActivityDetails]
}

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


class UserProfileAPI: BaseAuthAPI {
    
    func getProfile(completion: @escaping ((UserProfile?)-> Void)) {
        self.getCredentials(completion: { (credentials) in
            let headers = ["token":credentials.idToken, "login_type":LoginType.PERSONAL]
            let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/profile" , headers: headers)
            _ = Amplify.API.get(request: request, listener: { (result) in
                switch result {
                case .success(let data):
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
                        }
                case .failure(let apiError):
                    print("getProfile failed \(apiError.localizedDescription)")
                    completion(nil)
                }
            })
        }) { (error) in
            print("getProfile failed \(error.localizedDescription)")
            completion(nil)
        }
    }

    struct HealthProfileResponse:Decodable {
        let data: UserHealthProfile
    }
    
    func getHealthProfile(completion: @escaping ((UserHealthProfile?)-> Void)) {
        self.getCredentials(completion: { (credentials) in
            let headers = ["token":credentials.idToken, "login_type":LoginType.PERSONAL]
            let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/health/profile" , headers: headers)
            _ = Amplify.API.get(request: request, listener: { (result) in
                switch result {
                case .success(let data):
                    do {
//                        let jsonData = try JSON(data: data)

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
                case .failure(let apiError):
                    print("getHealthProfile failed \(apiError)")
                }
            })
        }) { (error) in
            print("getProfile failed \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    func getUserAttributes(completion: @escaping ((TOCStatus)-> Void)) {
        let keys = UserDefaultsKeys()
        _ = Amplify.Auth.fetchUserAttributes() { result in
            switch result {
            case .success(let attributes):
                
                if !(attributes.contains { $0.key.rawValue == CustomCognitoAttributes.longevityTNC }) {
                    completion(.notaccepted)
                    return
                }
                
                let tncattribute = attributes.first { $0.key.rawValue == CustomCognitoAttributes.longevityTNC }
                
                guard let data = tncattribute?.value.data(using: .utf8) as? Data else {
                    completion(.unknown)
                    return
                }
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    completion(.unknown)
                    return
                }

                if json["isAccepted"] as! NSNumber == 1 {
                    completion(.accepted)
                } else {
                    completion(.notaccepted)
                }
                
//                for attribute in attributes {
//                    let name = attribute.key
//                    let value = attribute.value
//                    if name.rawValue == CustomCognitoAttributes.longevityTNC {
//                        guard let data = value.data(using: .utf8) as? Data else {
//                            completion(nil)
//                            return
//                        }
//                        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
//                            completion(nil)
//                            return
//                        }
//
//                        if json["isAccepted"] as! NSNumber == 1 {
//                            completion(true)
//                        } else {
//                            completion(false)
//                        }
//                    }
//                }
            case .failure(let error):
                print("Fetching user attributes failed with error \(error)")
                completion(.unknown)
            }
        }
    }
    
    func getUserActivities(offset:Int = 0 ,limit:Int = 10 ,completion: @escaping (_ userActivities:UserActivity)-> Void,
                           onFailure: @escaping (_ error: Error)-> Void) {

        self.getCredentials(completion: { (credentials) in
            let headers = ["token":credentials.idToken, "login_type":Logintype.personal.rawValue]
            let queryParams = ["offset":"\(offset)", "limit":"\(limit)"]
            let request = RESTRequest(apiName: "rejuveDevelopmentAPI", path: "/user/activities", headers: headers,
                                      queryParameters: queryParams, body: nil)
            Amplify.API.get(request: request) { (result) in
                switch result {
                case .success(let data):
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
    
    func getAppLink(completion: @escaping((String?) -> Void)) {
        guard let appurl = URL(string: "https://rejuve-public.s3-us-west-2.amazonaws.com/app-location") else { return }
        URLSession.shared.dataTask(with: appurl) { (data, response, error) in
            if error != nil {
                print(error?.localizedDescription)
                completion(nil)
            } else {
                guard let data = data else {
                    completion(nil)
                    return
                }
                let urlString = String(data: data, encoding: .utf8)
                completion(urlString)
            }
        }
    }
    
    func getUserAvatar(completion: @escaping (_ userActivities:String?)-> Void,
                       onFailure: @escaping (_ error: Error)-> Void) {
        self.getCredentials(completion: { (credentials) in
            let headers = ["token":credentials.idToken, "login_type":Logintype.personal.rawValue]
            let request = RESTRequest(apiName: "rejuveDevelopmentAPI", path: "/user/profile/picture", headers: headers,
                                      queryParameters: nil, body: nil)

            Amplify.API.get(request: request) { (result) in
                switch result {
                case .success(let data):
                    do {
                        let profileURL = String(data: data, encoding: .utf8)
                        completion(profileURL)
                    }
                    catch {
                        print("JSON error", error)
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
    
    func saveUserAvatar (profilePic: String,completion: @escaping (()-> Void), onFailure: @escaping (_ error: Error)-> Void) {
        self.getCredentials(completion: { (credentials) in
            let headers = ["token":credentials.idToken, "login_type":Logintype.personal.rawValue]
            
            let parameters: [String: String] = [
                "image": profilePic
            ]
            
            guard let bodyData:Data = profilePic.data(using: .utf8, allowLossyConversion: false) else { return }
            
            let request = RESTRequest(apiName: "rejuveDevelopmentAPI", path: "/user/profile/picture", headers: headers, queryParameters: nil, body: bodyData)
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
    
    func saveUserHealthProfile(healthProfile: UserHealthProfile,completion: @escaping (()-> Void), onFailure: @escaping (_ error: Error)-> Void) {
        self.getCredentials(completion: { (credentials) in
            let headers = ["token":credentials.idToken, "login_type":Logintype.personal.rawValue]
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
        }) { (error) in
            onFailure(error)
        }
    }
}
