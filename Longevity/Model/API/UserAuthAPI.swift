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

class UserAuthAPI {
    
    static let shared = UserAuthAPI()
    
    func checkUserSignedIn() -> Bool {
        var isSignedIn: Bool = false
        let semaphore = DispatchSemaphore(value: 0)
        _ = Amplify.Auth.fetchAuthSession { (result) in
                   switch result {
                   case .success(let session):
                        isSignedIn = session.isSignedIn
                        semaphore.signal()
                   case .failure(let error):
                        print(error.localizedDescription)
                        isSignedIn = false
                        semaphore.signal()
                   }
        }
        _ = semaphore.wait(timeout: .distantFuture)
        return isSignedIn
    }

    func signout(completion: ((Error?) -> Void)?) {
        func signoutFromAws() {
            _ = Amplify.Auth.signOut(listener: { (result) in
                print(try? result.get())
                switch result {
                case .success():
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

        appDelegate.deleteARNEndpoint(endpointArn: "endpointArn") { (error) in
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

}
