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

enum NotificationType: String {
    case pushNotification = "PUSH_NOTIFICATION"
}

enum NotificationDevicePlatforms:String, Codable {
    case iphone = "IOS"
}

struct UserNotification: Codable {
    let username:String?
    let deviceId: String?
    let platform: NotificationDevicePlatforms?
    var endpointArn: String?
    let lastSent: String?
    var isEnabled: Bool?
}

struct UpdateNotificationResponse:Codable {
    let status:String?
    let data: UserNotification?
}

struct NotificationPayload: Codable {
    let platform: String
    let endpointArn:String
    let isEnabled: Bool
}

class NotificationAPI:BaseAuthAPI {
    private let apiName = "rejuveDevelopmentAPI"
    func getDeviceIdForVendor() -> String? {
        do {
            let deviceIdForVendor = try KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.identifierForVendor).readItem()
            return deviceIdForVendor
        } catch  {
            return nil
        }
    }

    func createDeviceIdForVendor() -> String? {
        guard let deviceIdForVendor = UIDevice.current.identifierForVendor?.uuidString
        else {
            Logger.log("deviceIdForVendor is not generated")
            return nil
        }
        do {
            try KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.identifierForVendor).saveItem(deviceIdForVendor)
            return deviceIdForVendor
        } catch  {
            Logger.log("unable to save deviceIdForVendor in KeyChain \(error)")
            return nil
        }
        return deviceIdForVendor
    }


    func getNotification(completion: @escaping ((UserNotification?)-> Void)) {
        guard let deviceIdForVendor = self.getDeviceIdForVendor() else {
            completion(nil)
            return
        }

        self.getCredentials(completion: { (credentials) in
            print("scss")
            let headers = ["token":credentials.idToken, "content-type":"application/json", "login_type":LoginType.PERSONAL]
            let path = "/device/\(deviceIdForVendor)/notification/\(NotificationType.pushNotification.rawValue)"

            let request = RESTRequest(apiName:self.apiName, path: path , headers: headers)
            _ = Amplify.API.get(request: request, listener: { (result) in
                switch result{
                case .success(let data):
                    print("notification data", String(data: data, encoding: .utf8))
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let value = try decoder.decode(UpdateNotificationResponse.self, from: data)
                        if let message = value.data, message.endpointArn != nil {
                            completion(message)
                        } else {
                            completion(nil)
                        }
                    } catch {
                        print("json error", error)
                        completion(nil)
                    }
                case .failure(let apiError):
                    Logger.log("retrieveARN failed \(apiError)")
                    completion(nil)
                }
            })

        }) { (error) in
            print("err", error)
        }
    }

    func updateNotification(userNotification: Bool, completion: @escaping ((UserNotification?)-> Void),
                            failure: @escaping ()-> Void){
        guard let deviceIdForVendor = self.getDeviceIdForVendor(),
              let endpointArn = AppSyncManager.instance.userNotification.value?.endpointArn
        else {return}

        self.getCredentials(completion: { (credentials) in
            let headers = ["token":credentials.idToken, "content-type":"application/json", "login_type":LoginType.PERSONAL]
            do {
                let body = NotificationPayload(platform: NotificationDevicePlatforms.iphone.rawValue, endpointArn: endpointArn, isEnabled: userNotification)
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                let data = try encoder.encode(body)
                let path = "/device/\(deviceIdForVendor)/notification/\(NotificationType.pushNotification.rawValue)"
                let request = RESTRequest(apiName: self.apiName, path: path, headers: headers, body: data)

                _ = Amplify.API.post(request: request, listener: { (result) in
                    switch result{
                    case .success(let data):
                        print("notification data", String(data: data, encoding: .utf8))
                        do {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            let value = try decoder.decode(UpdateNotificationResponse.self, from: data)
                            if let message = value.data, message.endpointArn != nil {
                                completion(message)
                            }
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

    func registerARN(platform: NotificationDevicePlatforms, arnEndpoint: String) {
        func onGettingCredentials(_ credentials: Credentials){
            let headers = ["token":credentials.idToken, "content-type":"application/json", "login_type":LoginType.PERSONAL]
            let body = NotificationPayload(platform: platform.rawValue, endpointArn: arnEndpoint, isEnabled:  true)
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            var data:Data = Data()
            do {
                data = try encoder.encode(body)
            }catch {
                print("register ARN json error", error)
            }

            var deviceIdForVendor = self.getDeviceIdForVendor()
            if deviceIdForVendor == nil {
                deviceIdForVendor = createDeviceIdForVendor()
            }
            let path = "/device/\(deviceIdForVendor!)/notification/\(NotificationType.pushNotification.rawValue)"
            let request = RESTRequest(apiName:self.apiName, path: path , headers: headers, body: data)

            _ = Amplify.API.post(request: request, listener: { (result) in
                switch result {
                case .success(let data):
                    AppSyncManager.instance.userNotification.value?.endpointArn = arnEndpoint
                    AppSyncManager.instance.userNotification.value?.isEnabled = true
                    let responseString = String(data: data, encoding: .utf8)
                    Logger.log("register ARN sucess \(responseString)")
                case .failure(let apiError):
                    AppSyncManager.instance.userNotification.value?.endpointArn = nil
                    AppSyncManager.instance.userNotification.value?.isEnabled = false
                    Logger.log("registerARN failed \(apiError)")
                }
            })
        }

        func onFailureCredentials(_ error: Error?) {
            print("registerARN failed to fetch credentials \(error)")
            Logger.log("register ARN failed")
        }

        self.getCredentials(completion: onGettingCredentials(_:), onFailure: onFailureCredentials(_:))
    }

    func deleteNotification(completion: ((_ error:Error?)-> Void)? = nil) {
        guard let deviceIdForVendor = self.getDeviceIdForVendor()
        else {return}
        self.getCredentials { (credentials) in
            let headers = ["token":credentials.idToken, "content-type":"application/json", "login_type":LoginType.PERSONAL]
            let path = "/device/\(deviceIdForVendor)/notification/\(NotificationType.pushNotification.rawValue)"
            let request = RESTRequest(apiName: self.apiName,
                                                    path: path,
                                                    headers: headers)
            _ = Amplify.API.delete(request: request, listener: { (result) in
                print(try? result.get())
                switch result {
                case .success(_):
                    completion?(nil)
                case .failure(let error):
                    completion?(error)
                }
            })
        } onFailure: { (error) in
            completion?(error)
        }

    }
}



