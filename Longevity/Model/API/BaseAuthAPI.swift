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

enum APICallType {
    case apiGET
    case apiPOST
    case apiPUT
    case apiDELETE
}

class BaseAuthAPI {
    
    var headers: [String: String] {
        return ["token": self.getUserToken() ?? "", "content-type":"application/json", "login_type":LoginType.PERSONAL]
    }
    
    fileprivate func getUserToken() -> String? {
        let token = try? KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.idToken).readItem()
        print("Id token - \(token) ")
        return token
    }
    
    fileprivate func fetchUserToken(isSuccess: @escaping(Bool) -> Void) {
        _ = Amplify.Auth.fetchAuthSession { result in
            guard let session = try? result.get() as? AuthCognitoTokensProvider,
                  let tokens = try? session.getCognitoTokens().get() else {
                isSuccess(false)
                return
            }
            
            do{
                print("Id token - \(tokens.idToken) ")
                try KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.idToken).saveItem(tokens.idToken)
                isSuccess(true)
            } catch {
                isSuccess(false)
            }
        }
    }
    
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

                    let secondsOffset50Mins = Double(50 * 60)
                    let date50MinFuture = Date().addingTimeInterval(secondsOffset50Mins)
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
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
    
    
    
    func makeAPICall(callType: APICallType, request: RESTRequest, completion: @escaping(Data?, Error?) -> Void) {
        if callType == .apiGET {
            self.getRequest(request: request, completion: completion)
        } else if callType == .apiPOST {
            self.postRequest(request: request, completion: completion)
        }
    }
    
    fileprivate func getRequest(request: RESTRequest, isRetry: Bool = false, completion: @escaping(Data?, Error?) -> Void) {
        let newRequest = RESTRequest(apiName: request.apiName, path: request.path, headers: self.headers, queryParameters: request.queryParameters, body: request.body)
        _ = Amplify.API.get(request: request, listener: { (result) in
            switch result{
            case .success(let data):
                completion(data, nil)
            case .failure(let apiError):
                if !isRetry {
                self.fetchUserToken { (success) in
                    if success {
                        self.getRequest(request: request, isRetry: true, completion: completion)
                    }
                }
                } else {
                    completion(nil, apiError)
                }
            }
        })
    }
    
    fileprivate func postRequest(request: RESTRequest, isRetry: Bool = false, completion: @escaping(Data?, Error?) -> Void) {
        let newRequest = RESTRequest(apiName: request.apiName, path: request.path, headers: self.headers, queryParameters: request.queryParameters, body: request.body)
        _ = Amplify.API.post(request: request, listener: { (result) in
            switch result{
            case .success(let data):
                completion(data, nil)
            case .failure(let apiError):
                if !isRetry {
                self.fetchUserToken { (success) in
                    if success {
                        self.postRequest(request: request, isRetry: true, completion: completion)
                    }
                }
                } else {
                    completion(nil, apiError)
                }
            }
        })
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
