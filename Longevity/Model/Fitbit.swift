//
//  Fitbit.swift
//  Longevity
//
//  Created by vivek on 30/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import CommonCrypto
import Amplify
import SwiftyJSON
import Amplify
import AWSPluginsCore


// MARK: - AWSAmplifyConfig
struct AWSAmplifyConfig: Codable {
    let userAgent, version: String
    let auth: Auth
    let api: API

    enum CodingKeys: String, CodingKey {
        case userAgent = "UserAgent"
        case version = "Version"
        case auth, api
    }
}

// MARK: - API
struct API: Codable {
    let plugins: APIPlugins
}

// MARK: - APIPlugins
struct APIPlugins: Codable {
    let awsAPIPlugin: AwsAPIPlugin
}

// MARK: - AwsAPIPlugin
struct AwsAPIPlugin: Codable {
    let rejuveDevelopmentAPI, mockQuestionsAPI, surveyAPI, insightsAPI: InsightsAPIClass
}

// MARK: - InsightsAPIClass
struct InsightsAPIClass: Codable {
    let endpointType, endpoint, region, authorizationType: String
}

// MARK: - Auth
struct Auth: Codable {
    let plugins: AuthPlugins
}

// MARK: - AuthPlugins
struct AuthPlugins: Codable {
    let awsCognitoAuthPlugin: AwsCognitoAuthPlugin
}

// MARK: - AwsCognitoAuthPlugin
struct AwsCognitoAuthPlugin: Codable {
    let userAgent, version: String
    let identityManager: IdentityManager
    let credentialsProvider: CredentialsProvider
    let cognitoUserPool: CognitoUserPool
    let googleSignIn: GoogleSignIn
    let facebookSignIn: FacebookSignIn
    let auth: AuthClass

    enum CodingKeys: String, CodingKey {
        case userAgent = "UserAgent"
        case version = "Version"
        case identityManager = "IdentityManager"
        case credentialsProvider = "CredentialsProvider"
        case cognitoUserPool = "CognitoUserPool"
        case googleSignIn = "GoogleSignIn"
        case facebookSignIn = "FacebookSignIn"
        case auth = "Auth"
    }
}

// MARK: - AuthClass
struct AuthClass: Codable {
    let authDefault: AuthDefault

    enum CodingKeys: String, CodingKey {
        case authDefault = "Default"
    }
}

// MARK: - AuthDefault
struct AuthDefault: Codable {
    let oAuth: OAuth
    let authenticationFlowType: String

    enum CodingKeys: String, CodingKey {
        case oAuth = "OAuth"
        case authenticationFlowType
    }
}

// MARK: - OAuth
struct OAuth: Codable {
    let webDomain, appClientID, appClientSecret, signInRedirectURI: String
    let signOutRedirectURI: String
    let scopes: [String]

    enum CodingKeys: String, CodingKey {
        case webDomain = "WebDomain"
        case appClientID = "AppClientId"
        case appClientSecret = "AppClientSecret"
        case signInRedirectURI = "SignInRedirectURI"
        case signOutRedirectURI = "SignOutRedirectURI"
        case scopes = "Scopes"
    }
}

// MARK: - CognitoUserPool
struct CognitoUserPool: Codable {
    let cognitoUserPoolDefault: CognitoUserPoolDefault

    enum CodingKeys: String, CodingKey {
        case cognitoUserPoolDefault = "Default"
    }
}

// MARK: - CognitoUserPoolDefault
struct CognitoUserPoolDefault: Codable {
    let poolID, appClientID, appClientSecret, region: String

    enum CodingKeys: String, CodingKey {
        case poolID = "PoolId"
        case appClientID = "AppClientId"
        case appClientSecret = "AppClientSecret"
        case region = "Region"
    }
}

// MARK: - CredentialsProvider
struct CredentialsProvider: Codable {
    let cognitoIdentity: CognitoIdentity

    enum CodingKeys: String, CodingKey {
        case cognitoIdentity = "CognitoIdentity"
    }
}

// MARK: - CognitoIdentity
struct CognitoIdentity: Codable {
    let cognitoIdentityDefault: CognitoIdentityDefault

    enum CodingKeys: String, CodingKey {
        case cognitoIdentityDefault = "Default"
    }
}

// MARK: - CognitoIdentityDefault
struct CognitoIdentityDefault: Codable {
    let poolID, region: String

    enum CodingKeys: String, CodingKey {
        case poolID = "PoolId"
        case region = "Region"
    }
}

// MARK: - FacebookSignIn
struct FacebookSignIn: Codable {
    let appID, permissions: String

    enum CodingKeys: String, CodingKey {
        case appID = "AppId"
        case permissions = "Permissions"
    }
}

// MARK: - GoogleSignIn
struct GoogleSignIn: Codable {
    let permissions, clientIDWebApp, clientIDIOS: String

    enum CodingKeys: String, CodingKey {
        case permissions = "Permissions"
        case clientIDWebApp = "ClientId-WebApp"
        case clientIDIOS = "ClientId-iOS"
    }
}

// MARK: - IdentityManager
struct IdentityManager: Codable {
    let identityManagerDefault: IdentityManagerDefault

    enum CodingKeys: String, CodingKey {
        case identityManagerDefault = "Default"
    }
}

// MARK: - IdentityManagerDefault
struct IdentityManagerDefault: Codable {
}

func generateCodeVerifier() -> String {
    var buffer = [UInt8](repeating: 0, count: 32)
    _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
    let codeVerifier = Data(bytes: buffer).base64EncodedString()
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
        .trimmingCharacters(in: .whitespaces)
    return codeVerifier
}

func generateCodeChallenge(codeVerifier: String) -> String {
    guard let data = codeVerifier.data(using: .utf8) else { return "" }
    var buffer = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes {
        _ = CC_SHA256($0, CC_LONG(data.count), &buffer)
    }
    let hash = Data(bytes: buffer)
    let codeChallenge = hash.base64EncodedString()
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
        .trimmingCharacters(in: .whitespaces)
    return codeChallenge
}

func base64StringEncode(_ inputString: String) -> String {
    let data = inputString.data(using: .utf8)!
    var base64 = data.base64EncodedString()
    base64 = base64.replacingOccurrences(of: "=", with: "")
    base64 = base64.replacingOccurrences(of: "+", with: "-")
    base64 = base64.replacingOccurrences(of: "/", with: "_")
    return base64
}

let codeVerifierString = generateCodeVerifier()
let codeChallengeString = generateCodeChallenge(codeVerifier: codeVerifierString)

struct Constants {
    static let authUrl = URL(string: "https://www.fitbit.com/oauth2/authorize")
    static let tokenUrl = URL(string:"https://api.fitbit.com/oauth2/token")
    static let revokeTokenUrl = URL(string: "https://api.fitbit.com/oauth2/revoke")
    static let responseType = "code"
    static let codeVerifier = codeVerifierString
    static let codeChallenge = codeChallengeString
    static let codeChallengeMethod = "S256"
    static let clientId = "22BNS6"
    static let clientSecret = "e10696ffdc570f7206d55bd5c61fedfc"
    static let redirectScheme = "myapp://" // YOU MUST DEFINE THAT SCHEME IN PROJECT SETTIGNS
    static let redirectUrl = "\(redirectScheme)fitbit/auth"
    static let scope = ["activity", "heartrate", "location", "nutrition", "profile", "settings", "sleep", "social", "weight"]
    static let expires = "604800"
    private init() {}

}

class FitbitModel: AuthHandlerType {

    var session: NSObject? = nil
    var contextProvider: AuthContextProvider?

    func auth(_ completion: @escaping ((String?, Error?) -> Void)) {
        guard let authUrl = Constants.authUrl else {
            completion(nil, nil)
            return
        }

        var urlComponents = URLComponents(url: authUrl, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "response_type", value: Constants.responseType),
            URLQueryItem(name:"code_challenge", value: Constants.codeChallenge),
            URLQueryItem(name:"code_challenge_method", value: Constants.codeChallengeMethod),
            URLQueryItem(name: "client_id", value: Constants.clientId),
            URLQueryItem(name: "redirect_url", value: Constants.redirectUrl),
            URLQueryItem(name: "scope", value: Constants.scope.joined(separator: " ")),
            URLQueryItem(name: "expires_in", value: String(Constants.expires))
        ]

        guard let authURL = urlComponents?.url else {
            completion(nil, nil)
            return
        }

        auth(authURL: authURL, callbackScheme: Constants.redirectScheme) {
            authURL, error in
            if error != nil {
                completion(nil, error)
            } else if let `authURL` = authURL {
                guard let components = URLComponents(url: authURL, resolvingAgainstBaseURL: false),
                    let item = components.queryItems?.first(where: { $0.name == "code" }),
                    let code = item.value else {
                        completion(nil, nil)
                        return
                }
                completion(code, nil)
            }
        }
    }

    func token(authCode:String) {
        let encodedBasicAuth = base64StringEncode("\(Constants.clientId):\(Constants.clientSecret)")
        var urlComponents = URLComponents(url: Constants.tokenUrl!, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "code", value: authCode),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectUrl),
            URLQueryItem(name:"code_verifier", value: Constants.codeVerifier)
        ]

        var urlRequest = URLRequest(url: (urlComponents?.url)!)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("Basic \(encodedBasicAuth)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let dataTask = URLSession.shared.dataTask(with: urlRequest) {data, response,_   in
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200,
                data != nil else { return }
            do {
                if let jsonData: [String:Any] =
                    try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any] {
                    let accessToken = jsonData["access_token"] as! String
                    let refreshToken = jsonData["refresh_token"] as! String
                    let userId = jsonData["user_id"] as! String

                    self.saveToken(accessToken: accessToken, refreshToken: refreshToken)
                    FitbitAPI.instance.publishData(accessToken: accessToken, userId: userId)
                }
            } catch {
                print("fitbit token error", error)
            }
        }
        dataTask.resume()
    }

    func saveToken(accessToken: String, refreshToken: String) {
        guard let accessTokenData = accessToken.data(using: .utf8),
        let refreshTokenData = refreshToken.data(using: .utf8) else {
            return
        }

        try? KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.FitbitAccessToken).saveItem(accessToken)
        try? KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.FitbitRefreshToken).saveItem(refreshToken)

        Logger.log("fitbit token saved in keychain")
    }

    func refreshTheToken() {
        guard let refreshToken = try? KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.FitbitRefreshToken).readItem() else { return }


        let encodedBasicAuth = base64StringEncode("\(Constants.clientId):\(Constants.clientSecret)")
               var urlComponents = URLComponents(url: Constants.tokenUrl!, resolvingAgainstBaseURL: false)
               urlComponents?.queryItems = [
                   URLQueryItem(name: "grant_type", value: "refresh_token"),
                   URLQueryItem(name: "refresh_token", value:refreshToken)
               ]

        var urlRequest = URLRequest(url: (urlComponents?.url)!)
               urlRequest.httpMethod = "POST"
               urlRequest.addValue("Basic \(encodedBasicAuth)", forHTTPHeaderField: "Authorization")
               urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    }
    
    static func getOperationsToRefreshFitbitToken() -> [Operation] {
        let fetchFitbitToken = FetchFitbitTokenOperation()
        let publishToServer = PublishFitbitTokenOperation()
        let refreshFitbitToken = BlockOperation { [unowned fetchFitbitToken, unowned publishToServer] in
            guard let accessToken = fetchFitbitToken.accessToken,
                  let userID = fetchFitbitToken.userID,
                  let refreshToken = fetchFitbitToken.refreshToken else {
                publishToServer.cancel()
                return
            }
            
            if fetchFitbitToken.isCancelled {
                publishToServer.cancel()
            }
            
            publishToServer.accessToken = accessToken
            publishToServer.refreshToken = refreshToken
            publishToServer.userID = userID
        }
        refreshFitbitToken.addDependency(fetchFitbitToken)
        publishToServer.addDependency(refreshFitbitToken)
        
        return [fetchFitbitToken,
                refreshFitbitToken,
                publishToServer]
    }

    func revokeToken() {
        guard let accessToken = try? KeyChain(service: KeychainConfiguration.serviceName,
                                              account: KeychainKeys.FitbitAccessToken).readItem() else {return}
        guard let revokeTokenUrl = Constants.revokeTokenUrl as? URL else {return}
        let encodedBasicAuth = base64StringEncode("\(Constants.clientId):\(Constants.clientSecret)")
        var urlComponents = URLComponents(url: revokeTokenUrl, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "token", value: accessToken)
        ]

        var urlRequest = URLRequest(url: (urlComponents?.url)!)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("Basic \(encodedBasicAuth)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let dataTask = URLSession.shared.dataTask(with: urlRequest) {data, response,_   in
            print("data", String(data:data!, encoding: .utf8))
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                print("error")
                return }
            print("token revoked")
        }
        dataTask.resume()
    }
}

class FitbitAPI: BaseAuthAPI {
    
    static var instance = FitbitAPI()
    
    func publishData(accessToken: String, userId: String) {
                   let body = JSON(["access_token":accessToken, "user_id":userId])
                   var bodyData:Data = Data()
                   do {
                       bodyData = try body.rawData()
                   } catch  {
                       print(error)
                   }
                   let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/health/application/FITBIT/synchronize" , headers: headers, body: bodyData)
        self.makeAPICall(callType: .apiPOST, request: request) { (data, error) in
            if let error = error {
                print(" publish data error \(error)")
                Logger.log("Fitbit publish failure \(error)")
            }
            guard let data = data else { return }
            let responseString = String(data: data, encoding: .utf8)
            Logger.log("Fitbit data published")
        }
    }
}
