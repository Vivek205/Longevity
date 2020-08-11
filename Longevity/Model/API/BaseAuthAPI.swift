//
//  BaseAuthAPI.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 11/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import Amplify
import AWSPluginsCore
import SwiftyJSON

class BaseAuthAPI {
    func getCredentials(completion: @escaping (_ credentials: Credentials)-> Void,
                        onFailure: @escaping (_ error: Error)-> Void) {
        var usersub = "", identityId = "", accessKey = "", idToken = ""
        var credentials = Credentials()
        _ = Amplify.Auth.fetchAuthSession { result in
            do {
                let session = try result.get()

                if let identityProvider = session as? AuthCognitoIdentityProvider {
                    credentials.usersub = try identityProvider.getUserSub().get()
                    credentials.identityId = try identityProvider.getIdentityId().get()
                }

                // Get aws credentials
                if let awsCredentialsProvider = session as? AuthAWSCredentialsProvider {
                    let awsCredentials = try awsCredentialsProvider.getAWSCredentials().get()
                    credentials.accessKey = awsCredentials.accessKey
                }

                // Get cognito user pool token
                if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                    let tokens = try cognitoTokenProvider.getCognitoTokens().get()
                    credentials.idToken = tokens.idToken
                }

                completion(credentials)
            } catch {
                print("Fetch auth session failed with error - \(error)")
                onFailure(error)
            }
        }
    }
}
