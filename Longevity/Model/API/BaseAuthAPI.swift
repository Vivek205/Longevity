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

enum Logintype: String {
    case personal = "PERSONAL"
    case clinicaltrail = "CLINICAL_TRIAL"
}

class BaseAuthAPI {
    
    func getCredentials(completion: @escaping (_ credentials: Credentials)-> Void,
                        onFailure: @escaping (_ error: Error)-> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        if let idTokenExp = try? KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.idTokenExp).readItem() {
            if let expDate = dateFormatter.date(from: idTokenExp) {
                let currentDate = Date()
                if currentDate < expDate {
                    
                    if let idToken = try? KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.idToken).readItem() {
                        return completion(  Credentials(usersub: "", identityId: "", accessKey: "", idToken: idToken))
                    }
                    
                }
            }
        }



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
                    //                print("expiry", awsCredentials.expiration)
                    credentials.accessKey = awsCredentials.accessKey
                }

                // Get cognito user pool token
                if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                    let tokens = try cognitoTokenProvider.getCognitoTokens().get()
                    credentials.idToken = tokens.idToken

                    // FIXME: Temp solution
                    let secondsOffset50Mins = Double(50 * 60)
                    let date50MinFuture = Date().addingTimeInterval(secondsOffset50Mins)
                    let dateString50MinFuture = dateFormatter.string(from: date50MinFuture)

                    guard let idTokenData = tokens.idToken.data(using: .utf8),
                          let idTokenExpData = dateString50MinFuture.data(using: .utf8) else {
                        return completion(credentials)
                    }

                    try? KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.idToken).saveItem(tokens.idToken)
                    try? KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.idTokenExp).saveItem(dateString50MinFuture)
                    
                    //                    KeyChain.save(name: KeychainKeys.idToken, data: idTokenData)
                    //                    KeyChain.save(name: KeychainKeys.idTokenExp, data: idTokenExpData)
                    //                print(tokens.idToken)
                }

                completion(credentials)
            } catch {
                print("Fetch auth session failed with error - \(error)")
                onFailure(error)
            }
        }
    }

}

extension Decodable {
    static func map(json: String) -> Self? {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(Self.self, from: Data(json.utf8))
        }
        catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
}
