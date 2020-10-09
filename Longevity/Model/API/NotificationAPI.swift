//
//  Notification.swift
//  Longevity
//
//  Created by vivek on 11/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import Amplify
import SwiftyJSON

enum NotificationDevicePlatforms:String, Codable {
    case iphone = "IOS"
}

struct UserNotification: Codable {
    let username:String?
    let deviceId: String?
    let platform: NotificationDevicePlatforms?
    let endpointArn: String?
    let lastSent: String?
    var isEnabled: Bool?
}

class NotificationAPI:BaseAuthAPI {

    func getNotification(completion: @escaping ((UserNotification?)-> Void)) {
        guard let deviceIdForVendor = UIDevice.current.identifierForVendor?.uuidString else {return}
        self.getCredentials(completion: { (credentials) in
            print("scss")
            let headers = ["token":credentials.idToken, "content-type":"application/json", "login_type":LoginType.PERSONAL]
            let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/device/\(deviceIdForVendor)/notification" , headers: headers)
            _ = Amplify.API.get(request: request, listener: { (result) in
                switch result{
                case .success(let data):
                    print("notification data", String(data: data, encoding: .utf8))
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let value = try decoder.decode(UserNotification.self, from: data)
                        completion(value)
                    } catch {
                        print("json error", error)
                    }
                case .failure(let apiError):
                    Logger.log("retrieveARN failed \(apiError)")
                }
            })

        }) { (error) in
            print("err", error)
        }
    }
    struct UpdateNotificationResponse:Codable {
        let status:String?
        let message: UserNotification?
    }
    func updateNotification(userNotification: Bool, completion: @escaping ((UserNotification?)-> Void),
                            failure: @escaping ()-> Void){
        guard let deviceIdForVendor = UIDevice.current.identifierForVendor?.uuidString else {return}

        self.getCredentials(completion: { (credentials) in
            let headers = ["token":credentials.idToken, "content-type":"application/json", "login_type":LoginType.PERSONAL]
            do {
                let body = ["is_enabled":userNotification ? 1 : 0]
                let encoder = JSONEncoder()
                let data = try encoder.encode(body)
                let request = RESTRequest(apiName: "rejuveDevelopmentAPI",
                                          path: "/device/\(deviceIdForVendor)/notification/status",
                                          headers: headers, body: data)

                _ = Amplify.API.post(request: request, listener: { (result) in
                    switch result{
                    case .success(let data):
                        print("notification data", String(data: data, encoding: .utf8))
                        do {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            let value = try decoder.decode(UpdateNotificationResponse.self, from: data)
                            completion(value.message)
                        } catch {
                            print("json error", error)
                            failure()
                        }
                    case .failure(let apiError):
                        Logger.log("retrieveARN failed \(apiError)")
                        failure()
                    }
                })
            } catch {
                failure()
            }
        }) { (error) in
            print("errror", error)
             failure()
        }
    }
}

func registerARN(platform:String, arnEndpoint: String, success: @escaping(()-> Void), failure: @escaping(()-> Void)) {
    guard let deviceIdForVendor = UIDevice.current.identifierForVendor?.uuidString else {return}

    func onGettingCredentials(_ credentials: Credentials){
        let headers = ["token":credentials.idToken, "content-type":"application/json", "login_type":LoginType.PERSONAL]


        let body = JSON([
            "platform" : platform,
            "endpoint_arn" : arnEndpoint
        ])

        var bodyData:Data = Data()
        do {
            bodyData = try body.rawData()
        } catch  {
            print(error)
        }

        let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/device/\(deviceIdForVendor)/notification/register" , headers: headers, body: bodyData)

        _ = Amplify.API.post(request: request, listener: { (result) in
            switch result {
            case .success(let data):
                let responseString = String(data: data, encoding: .utf8)
                Logger.log("register ARN sucess \(responseString)")
                success()
            case .failure(let apiError):
                Logger.log("registerARN failed \(apiError)")
                failure()
            }
        })
    }

    func onFailureCredentials(_ error: Error?) {
        print("registerARN failed to fetch credentials \(error)")
        Logger.log("register ARN failed")
    }

    _ = getCredentials(completion: onGettingCredentials(_:), onFailure: onFailureCredentials(_:))


}

func retrieveARN(){
    guard  let deviceIdForVendor = UIDevice.current.identifierForVendor?.uuidString else { return }

    func onGettingCredentials(_ credentials: Credentials){
        let headers = ["token":credentials.idToken, "content-type":"application/json", "login_type":LoginType.PERSONAL]

        let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/device/\(deviceIdForVendor)/notification" , headers: headers)

        _ = Amplify.API.get(request: request, listener: { (result) in
            switch result{
            case .success(let data):
                do {
                    let responseString = String(data: data, encoding: .utf8)
                    let jsonResponse = try JSON(data: data)
                    print(jsonResponse["endpoint_arn"])
                    if let snsARN =  jsonResponse["endpoint_arn"].rawValue as? String {
                        let defaults = UserDefaults.standard
                        let keys = UserDefaultsKeys()
                        defaults.set(snsARN, forKey: keys.endpointArnForSNS)
                        Logger.log("retrieveARN success")
                    }
                } catch  {
                    Logger.log("retrieveARN failed \(error)")
                }
            case .failure(let apiError):
                Logger.log("retrieveARN failed \(apiError)")
            }
        })
    }

    func onFailureCredentials(_ error: Error?) {
        print("retrieveARN failed to fetch credentials \(error)")
    }

    _ = getCredentials(completion: onGettingCredentials(_:), onFailure: onFailureCredentials(_:))
}
