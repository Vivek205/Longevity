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

class NotificationAPI: BaseAuthAPI {
    
    static var instance = NotificationAPI()
    
    private let apiName = "rejuveDevelopmentAPI"
    
    func getDeviceIdForVendor() -> String? {
        let deviceIdForVendor = try? KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.identifierForVendor).readItem()
        return deviceIdForVendor
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
        
        let path = "/device/\(deviceIdForVendor)/notification/\(NotificationType.pushNotification.rawValue)"
        let request = RESTRequest(apiName:self.apiName, path: path , headers: headers)
        self.makeAPICall(callType: .apiGET, request: request) { (data, error) in
            
            if error != nil {
                Logger.log("retrieveARN failed \(error)")
                completion(nil)
            }
            
            do {
                guard let data = data else {
                    completion(nil)
                    return
                }
                print("notification data", String(data: data, encoding: .utf8))
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
        }
    }
    
    func updateNotification(userNotification: Bool, completion: @escaping ((UserNotification?)-> Void),
                            failure: @escaping ()-> Void){
        guard let deviceIdForVendor = self.getDeviceIdForVendor(),
              let endpointArn = AppSyncManager.instance.userNotification.value?.endpointArn
        else {
            return
        }
        
        //        self.getCredentials(completion: { (credentials) in
        //            let headers = ["token":credentials.idToken, "content-type":"application/json", "login_type":LoginType.PERSONAL]
        do {
            let body = NotificationPayload(platform: NotificationDevicePlatforms.iphone.rawValue, endpointArn: endpointArn, isEnabled: userNotification)
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let data = try encoder.encode(body)
            let path = "/device/\(deviceIdForVendor)/notification/\(NotificationType.pushNotification.rawValue)"
            let request = RESTRequest(apiName: self.apiName, path: path, headers: headers, body: data)
            
            self.makeAPICall(callType: .apiPOST, request: request) { (data, error) in
                guard let data = data else {
                    failure()
                    return
                }
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
            }
        } catch {
            failure()
        }
    }
    
    func registerARN(platform: NotificationDevicePlatforms, arnEndpoint: String) {
        let body = NotificationPayload(platform: platform.rawValue, endpointArn: arnEndpoint, isEnabled:  true)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        var data:Data = Data()
        
        do {
            data = try encoder.encode(body)
        } catch {
            print("register ARN json error", error)
        }
        
        var deviceIdForVendor = self.getDeviceIdForVendor()
        if deviceIdForVendor == nil {
            deviceIdForVendor = createDeviceIdForVendor()
        }
        let path = "/device/\(deviceIdForVendor!)/notification/\(NotificationType.pushNotification.rawValue)"
        let request = RESTRequest(apiName:self.apiName, path: path , headers: headers, body: data)
        
        self.makeAPICall(callType: .apiPOST, request: request) { (data, error) in
            if error != nil {
                AppSyncManager.instance.userNotification.value?.endpointArn = nil
                AppSyncManager.instance.userNotification.value?.isEnabled = false
                Logger.log("registerARN failed \(error)")
            } else {
                guard let data = data else { return }
                AppSyncManager.instance.userNotification.value?.endpointArn = arnEndpoint
                AppSyncManager.instance.userNotification.value?.isEnabled = true
                let responseString = String(data: data, encoding: .utf8)
                Logger.log("register ARN sucess \(responseString)")
            }
        }
    }
    
    func deleteNotification(completion: ((_ error:Error?)-> Void)? = nil) {
        guard let deviceIdForVendor = self.getDeviceIdForVendor() else { return }
        
        let path = "/device/\(deviceIdForVendor)/notification/\(NotificationType.pushNotification.rawValue)"
        let request = RESTRequest(apiName: self.apiName,
                                  path: path,
                                  headers: headers)
        
        self.makeAPICall(callType: .apiDELETE, request: request) { (data, error) in
            if error != nil {
                completion?(error)
                return
            }
            guard data != nil else { return }
            completion?(nil)
        }
    }
}
