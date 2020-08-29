//
//  UserAuthAPI.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 29/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import Amplify

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
}
