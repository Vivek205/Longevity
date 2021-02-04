//
//  UserAuthAPI.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 29/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import Amplify
import AWSSNS
import AWSPluginsCore

class UserAuthAPI {
    
    static let shared = UserAuthAPI()
    
    func checkUserSignedIn(completion: @escaping(Bool)-> Void) {
        if let token = try? KeyChain(service: KeychainConfiguration.serviceName,
                                     account: KeychainKeys.idToken).readItem(),
           !token.isEmpty {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func fetchAuthentication(completion: @escaping(Bool, Error?) -> Void) {
        _ = Amplify.Auth.fetchAuthSession { (result) in
            switch result {
            case .success(let loginSession):
                guard let session = try? result.get() as? AuthCognitoTokensProvider,
                      let tokens = try? session.getCognitoTokens().get() else {
                    completion(false, nil)
                    return
                }

                try? KeyChain(service: KeychainConfiguration.serviceName,
                              account: KeychainKeys.idToken).saveItem(tokens.idToken)
                completion(true, nil)
                
            case .failure(let error):
                print(error.localizedDescription)
                completion(false, error)
            }
        }
    }

    func signout(completion: ((Error?) -> Void)?) {
        func signoutFromAws() {
            _ = Amplify.Auth.signOut(listener: { (result) in
                switch result {
                case .success():
                    try? KeyChain(service: KeychainConfiguration.serviceName,
                                  account: KeychainKeys.idToken).deleteItem()
                    AppSyncManager.instance.cleardata()
                    completion?(nil)
                case .failure(let error):
                    completion?(error)
                }
            })
        }

        guard let endpointArn = AppSyncManager.instance.userNotification.value?.endpointArn
        else {
            signoutFromAws()
            return
        }

        let notificationAPI = NotificationAPI()
        let appDelegate = AppDelegate()

        appDelegate.deleteARNEndpoint(endpointArn: endpointArn) { (error) in
            guard error == nil else {
                completion?(error)
                return
            }

            notificationAPI.deleteNotification { (error) in
                guard error == nil else {
                    signoutFromAws()
                    return
                }
                signoutFromAws()
            }
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
            case .failure(let error):
                print("Fetching user attributes failed with error \(error)")
                completion(.error)
            }
        }
    }
}
