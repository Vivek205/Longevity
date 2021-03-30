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
    
    var userToken: String? {
        return try? KeyChain(service: KeychainConfiguration.serviceName,
                             account: KeychainKeys.idToken).readItem()
    }
    
    var headers: [String: String] {
        return ["token": self.userToken ?? "", "content-type":"application/json", "login_type":LoginType.PERSONAL]
    }
    
    var isSyncInprogress = false
    
    fileprivate func fetchUserToken(isSuccess: @escaping(Bool) -> Void) {
        _ = Amplify.Auth.fetchAuthSession { result in
            guard let session = try? result.get() as? AuthCognitoTokensProvider,
                  let tokens = try? session.getCognitoTokens().get() else {
                isSuccess(false)
                return
            }
            do{
                try KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.idToken).saveItem(tokens.idToken)
                isSuccess(true)
            } catch {
                isSuccess(false)
            }
        }
    }
    
    func makeAPICall(callType: APICallType, request: RESTRequest, completion: @escaping(Data?, Error?) -> Void) {
        if callType == .apiGET {
            self.getRequest(request: request, completion: completion)
        } else if callType == .apiPOST {
            self.postRequest(request: request, completion: completion)
        } else if callType == .apiDELETE {
            self.deleteRequest(request: request, completion: completion)
        }
    }
    
    fileprivate func getRequest(request: RESTRequest, isRetry: Bool = false,
                                completion: @escaping(Data?, Error?) -> Void) {
        let newRequest = RESTRequest(apiName: request.apiName,
                                     path: request.path,
                                     headers: self.headers,
                                     queryParameters: request.queryParameters,
                                     body: request.body)
        _ = Amplify.API.get(request: newRequest, listener: { (result) in
            switch result{
            case .success(let data):
                completion(data, nil)
            case .failure(let error):
                print("GET",request.path as Any,error.errorDescription)
                if error.errorDescription.contains("403") && !isRetry {
                    self.fetchUserToken { (success) in
                        if success {
                            self.getRequest(request: request, isRetry: true, completion: completion)
                        }
                    }
                } else {
                    completion(nil, error)
                }
            }
        })
    }
    
    fileprivate func postRequest(request: RESTRequest, isRetry: Bool = false,
                                 completion: @escaping(Data?, Error?) -> Void) {
        let newRequest = RESTRequest(apiName: request.apiName,
                                     path: request.path,
                                     headers: self.headers,
                                     queryParameters: request.queryParameters,
                                     body: request.body)
        _ = Amplify.API.post(request: newRequest, listener: { (result) in
            switch result{
            case .success(let data):
                completion(data, nil)
            case .failure(let apiError):
                print(apiError.errorDescription)
                if apiError.errorDescription.contains("403") && !isRetry {
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
    
    fileprivate func deleteRequest(request: RESTRequest, isRetry: Bool = false,
                                   completion: @escaping(Data?, Error?) -> Void) {
        let newRequest = RESTRequest(apiName: request.apiName,
                                     path: request.path,
                                     headers: self.headers,
                                     queryParameters: request.queryParameters,
                                     body: request.body)
        _ = Amplify.API.delete(request: newRequest, listener: { (result) in
            switch result{
            case .success(let data):
                completion(data, nil)
            case .failure(let apiError):
                print(apiError.errorDescription)
                if apiError.errorDescription.contains("403") && !isRetry {
                    self.fetchUserToken { (success) in
                        if success {
                            self.deleteRequest(request: request, isRetry: true, completion: completion)
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
