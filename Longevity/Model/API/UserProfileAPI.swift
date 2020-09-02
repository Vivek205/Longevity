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

struct UserActivity: Decodable {
    let title: String
    let username: String
    let activityType: UserActivityType
    let description: String
    let loggedAt: String
    var isLast: Bool?
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
                        let jsonData = try JSON(data: data)
                        let userProfileData = jsonData["data"]
                        let keys = UserDefaultsKeys()
                        let name = userProfileData[keys.name].rawString() ?? ""
                        let email = userProfileData[keys.email].rawString() ?? ""
                        let phone = userProfileData[keys.phone].rawString() ?? ""
                        
                        let userProfile = UserProfile(name: name, email: email, phone: phone)
                        
                        completion(userProfile)
                    } catch {
                        print("json parse error", error)
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
    
    func getHealthProfile(completion: @escaping ((UserHealthProfile?)-> Void)) {
        self.getCredentials(completion: { (credentials) in
            let headers = ["token":credentials.idToken, "login_type":LoginType.PERSONAL]
            let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/health/profile" , headers: headers)
            _ = Amplify.API.get(request: request, listener: { (result) in
                switch result {
                case .success(let data):
                    do {
                        let jsonData = try JSON(data: data)
                        
                        let defaults = UserDefaults.standard
                        let keys = UserDefaultsKeys()
                        let userProfileData = jsonData["data"]
                        let weight = userProfileData[keys.weight].rawString() ?? ""
                        let height = userProfileData[keys.height].rawString() ?? ""
                        let gender = userProfileData[keys.gender].rawString() ?? ""
                        let birthday = userProfileData[keys.birthday].rawString() ?? ""
                        let unit = userProfileData[keys.unit].rawString() ?? ""
                        let devices = userProfileData[keys.devices].rawValue as? [String:[String:Int]]
                        let preExistingConditions = userProfileData["pre_existing_conditions"].rawValue as? [[String:String]]
                        let mesureUnit = MeasurementUnits(rawValue: unit) ?? .metric
                        let healthProfile = UserHealthProfile(weight: weight, height: height, gender: gender, birthday: birthday, unit: mesureUnit, devices: devices, preconditions: preExistingConditions)
                        completion(healthProfile)
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
    
    func getUserAttributes(completion: @escaping ((Bool)-> Void)) {
        let keys = UserDefaultsKeys()
        _ = Amplify.Auth.fetchUserAttributes() { result in
            switch result {
            case .success(let attributes):
                for attribute in attributes {
                    let name = attribute.key
                    let value = attribute.value
                    if name.rawValue == CustomCognitoAttributes.longevityTNC {
                        guard let data = value.data(using: .utf8) as? Data else {
                            completion(false)
                            return
                        }
                        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                            completion(false)
                            return
                        }

                        if json["isAccepted"] as! NSNumber == 1 {
                            completion(true)
                        }
                    }
                }
            case .failure(let error):
                print("Fetching user attributes failed with error \(error)")
                completion(false)
            }
        }
    }
    
    func getUserActivities(completion: @escaping (_ userActivities:[UserActivity])-> Void,
                           onFailure: @escaping (_ error: Error)-> Void) {
        self.getCredentials(completion: { (credentials) in
            let headers = ["token":credentials.idToken, "login_type":Logintype.personal.rawValue]
            let queryParams = ["offset":"0", "limit":"100"]
            let request = RESTRequest(apiName: "rejuveDevelopmentAPI", path: "/user/activities", headers: headers,
                                      queryParameters: queryParams, body: nil)
            Amplify.API.get(request: request) { (result) in
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let value = try decoder.decode([UserActivity].self, from: data)
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
                
            }
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
            var bodyDict = [
                keys.weight: healthProfile.weight,
                keys.height: healthProfile.height,
                keys.gender: healthProfile.gender,
                keys.birthday: healthProfile.birthday,
                keys.unit: healthProfile.unit.rawValue,
                "devices": healthProfile.devices
                ] as [String : Any]

            let body = JSON(bodyDict)

            var bodyData:Data = Data()
            do {
                bodyData = try body.rawData()
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
                    AppSyncManager.instance.updateHealthProfile(deviceName: ExternalDevices.HEALTHKIT, connected: 1)
//                    updateSetupProfileCompletionStatus(currentState: .biodata)
//                    if let devices = defaults.object(forKey: keys.devices) as? [String:[String:Int]] {
//                        let newDevices = [ExternalDevices.HEALTHKIT:["connected":1]]
//                        let enhancedDevices = devices.merging(newDevices) {(_, newValues) in newValues }
//                        defaults.set(enhancedDevices, forKey: keys.devices)
//                    } else {
//                        let newDevices = [ExternalDevices.HEALTHKIT:["connected":1]]
//                        defaults.set(newDevices, forKey: keys.devices)
//                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    onFailure(error)
                    break
                }
            }
        }) { (error) in
            onFailure(error)
        }
        
//        func onGettingCredentials(_ credentials: Credentials){
//            let headers = ["token":credentials.idToken, "login_type":LoginType.PERSONAL]
//            let defaults = UserDefaults.standard
//            let keys = UserDefaultsKeys()
//            var bodyDict = [
//                keys.weight: defaults.value(forKey: keys.weight),
//                keys.height: defaults.value(forKey: keys.height),
//                keys.gender: defaults.value(forKey: keys.gender),
//                keys.birthday: defaults.value(forKey: keys.birthday),
//                keys.unit: defaults.value(forKey: keys.unit)
//            ]
//
//            if let devices = defaults.object(forKey: keys.devices) as? [String:[String:Int]] {
//                var devicesStatus:[String:[String:Int]] = [String:[String:Int]]()
//                if let fitbitStatus = devices[ExternalDevices.FITBIT] as? [String: Int] {
//                    print("fitbitstatus", fitbitStatus)
//                    devicesStatus[ExternalDevices.FITBIT] = fitbitStatus
//                }
//                if let healthkitStatus = devices[ExternalDevices.HEALTHKIT] as? [String: Int] {
//                    devicesStatus[ExternalDevices.HEALTHKIT] = healthkitStatus
//                }
//                bodyDict["devices"] = devicesStatus
//            }
//
//            let body = JSON(bodyDict)
//
//            var bodyData:Data = Data()
//            do {
//                bodyData = try body.rawData()
//                print(String(data: bodyData, encoding: .utf8))
//            } catch  {
//                print(error)
//            }
//
//            let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/health/profile" , headers: headers, body: bodyData)
//            _ = Amplify.API.post(request: request, listener: { (result) in
//                switch result{
//                case .success(let data):
//                    let responseString = String(data: data, encoding: .utf8)
//                    print("sucess \(responseString)")
//                    updateSetupProfileCompletionStatus(currentState: .biodata)
//                    if let devices = defaults.object(forKey: keys.devices) as? [String:[String:Int]] {
//                        let newDevices = [ExternalDevices.HEALTHKIT:["connected":1]]
//                        let enhancedDevices = devices.merging(newDevices) {(_, newValues) in newValues }
//                        defaults.set(enhancedDevices, forKey: keys.devices)
//                    } else {
//                        let newDevices = [ExternalDevices.HEALTHKIT:["connected":1]]
//                        defaults.set(newDevices, forKey: keys.devices)
//                    }
//                case .failure(let apiError):
//                    print("updateHealthProfile failed \(apiError)")
//                }
//            })
//        }
//
//        func onFailureCredentials(_ error: Error?) {
//              print("updateHealthProfile failed to fetch credentials \(error)")
//          }
//
//        _ = getCredentials(completion: onGettingCredentials(_:), onFailure: onFailureCredentials(_:))
    }
}
