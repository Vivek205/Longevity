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
                    self.publishData(accessToken: accessToken, userId: userId)
                }
            } catch {
                print("fitbit token error", error)
            }
        }
        dataTask.resume()
    }

    func publishData(accessToken: String, userId: String) {
        func onGettingCredentials(_ credentials: Credentials){
            let headers = ["token":credentials.idToken, "login_type":LoginType.PERSONAL]
                   let body = JSON(["access_token":accessToken, "user_id":userId])
                   var bodyData:Data = Data()
                   do {
                       bodyData = try body.rawData()
                   } catch  {
                       print(error)
                   }
                   let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/health/application/FITBIT/synchronize" , headers: headers, body: bodyData)
                           _ = Amplify.API.post(request: request, listener: { (result) in
                       switch result{
                       case .success(let data):
                           let responseString = String(data: data, encoding: .utf8)
                           Logger.log("Fitbit data published")
                       case .failure(let apiError):
                           print(" publish data error \(apiError)")
                           Logger.log("Fitbit publish failure \(apiError)")
                       }
                   })
        }

        func onFailureCredentials(_ error: Error?) {
              print("publishData failed to fetch credentials \(error)")
          }

        _ = getCredentials(completion: onGettingCredentials(_:), onFailure: onFailureCredentials(_:))
    }

    func saveToken(accessToken: String, refreshToken: String) {
        guard let accessTokenData = accessToken.data(using: .utf8),
        let refreshTokenData = refreshToken.data(using: .utf8) else {
            return
        }

        try? KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.FitbitAccessToken).saveItem(accessToken)
        try? KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.FitbitRefreshToken).saveItem(refreshToken)
        
//        KeyChain.save(name: KeychainKeys.FitbitAccessToken, data: accessTokenData)
//        KeyChain.save(name: KeychainKeys.FitbitRefreshToken ,data: refreshTokenData)
        Logger.log("fitbit token saved in keychain")
    }

    func refreshTheToken() {
        guard let refreshToken = try? KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.FitbitRefreshToken).readItem() else { return }
//        let refreshToken = String(data: refreshTokenData, encoding: .utf8)

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

//        let configuration = URLSessionConfiguration.background(withIdentifier: "come.rejuve.fitbitrefresh")

//        let bgSession = URLSession(configuration: configuration) //URLSession(configuration: configuration, delegate: self, delegateQueue: nil)

//        bgSession.dataTask(with: <#T##URLRequest#>, completionHandler: <#T##(Data?, URLResponse?, Error?) -> Void#>)
//        BackgroundSession.shared.start(urlRequest) //.startdataTask(urlRequest)
//        BackgroundSession.shared.delegate = self

//        let dataTask
//        let dataTask = URLSession.shared.dataTask(with: urlRequest){data, response,_   in
//            guard let httpResponse = response as? HTTPURLResponse,
//                httpResponse.statusCode == 200,
//                data != nil else { return }
//            do {
//                if let jsonData: [String:Any] =
//                    try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any] {
//                    let accessToken = jsonData["access_token"] as! String
//                    let refreshToken = jsonData["refresh_token"] as! String
//                    let userId = jsonData["user_id"] as! String
//                    Logger.log("fitbit token refreshed")
//                    self.saveToken(accessToken: accessToken, refreshToken: refreshToken)
//                    self.publishData(accessToken: accessToken, userId: userId)
//                }
//            } catch {}
//        }
//        dataTask.resume()
    }
    
    static func getOperationsToRefreshFitbitToken() -> [Operation] {
        let fetchFitbitToken = FetchFitbitTokenOperation()
        let publishToServer = PublishFitbitTokenOperation()
        let refreshFitbitToken = BlockOperation { [unowned fetchFitbitToken, unowned publishToServer] in
            guard let accessToken = fetchFitbitToken.accessToken, let userID = fetchFitbitToken.userID, let refreshToken = fetchFitbitToken.refreshToken else {
                publishToServer.cancel()
                return
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
}

extension FitbitModel {
//    func receivedtoken() {
//        do {
//            if let jsonData: [String:Any] =
//                try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
//                let accessToken = jsonData["access_token"] as! String
//                let refreshToken = jsonData["refresh_token"] as! String
//                let userId = jsonData["user_id"] as! String
//                Logger.log("fitbit token refreshed")
//                self.saveToken(accessToken: accessToken, refreshToken: refreshToken)
//                self.publishData(accessToken: accessToken, userId: userId)
//            }
//        } catch {}
//    }
}

protocol BackgroundSessionDelegate {
    func receivedtoken(refreshToken: String?, accessToken: String?, userID: String?)
}

class FitbitFetchBackground: NSObject {
    static let shared = FitbitFetchBackground()

    static let identifier = "com.rejuve.fitbitrefresh"

    var delegate: BackgroundSessionDelegate?

    var receivedData: Data?
    
    private var session: URLSession!

    #if !os(macOS)
    var savedCompletionHandler: (() -> Void)?
    #endif

    private override init() {
        super.init()

        let configuration = URLSessionConfiguration.background(withIdentifier: FitbitFetchBackground.identifier)
        if #available(iOS 13.0, *) {
            configuration.allowsConstrainedNetworkAccess = true
        }
        configuration.allowsCellularAccess = true
        configuration.isDiscretionary = true
        configuration.sessionSendsLaunchEvents = true
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    func start(refreshToken: String) {
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
        
        session.downloadTask(with: urlRequest).resume()
    }
}

extension FitbitFetchBackground: URLSessionDelegate {
    #if !os(macOS)
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.savedCompletionHandler?()
            self.savedCompletionHandler = nil
        }
    }
    #endif
}

extension FitbitFetchBackground: URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let response = response as? HTTPURLResponse,
            (200...299).contains(response.statusCode),
            let mimeType = response.mimeType,
            mimeType == "text/html" else {
            completionHandler(.cancel)
            return
        }
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        //self.delegate?.receivedtoken(data: data)
        self.receivedData?.append(data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else if let receivedData = self.receivedData,
                  let string = String(data: receivedData, encoding: .utf8) {
            print(string)
        }
    }
}

extension FitbitFetchBackground: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)
            guard let jsonData: [String:Any] = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {
                self.delegate?.receivedtoken(refreshToken: nil, accessToken: nil, userID: nil)
                return
            }
            guard let accessToken = jsonData["access_token"] as? String,
                  let refreshToken = jsonData["refresh_token"] as? String,
                  let userId = jsonData["user_id"] as? String else {
                self.delegate?.receivedtoken(refreshToken: nil, accessToken: nil, userID: nil)
                return
            }
            
            try? KeyChain(service: KeychainConfiguration.serviceName,
                          account: KeychainKeys.FitbitAccessToken).saveItem(accessToken)
            try? KeyChain(service: KeychainConfiguration.serviceName,
                          account: KeychainKeys.FitbitRefreshToken).saveItem(refreshToken)
            self.delegate?.receivedtoken(refreshToken: refreshToken, accessToken: accessToken, userID: userId)
            Logger.log("fitbit token saved in keychain")
        } catch {
            print("\(error.localizedDescription)")
            self.delegate?.receivedtoken(refreshToken: nil, accessToken: nil, userID: nil)
        }
    }
}

protocol FitbitPublishBackgroundDelegate {
    func published(success: Bool)
}


class FitbitPublishBackground: NSObject {
    static let shared = FitbitPublishBackground()

    static let identifier = "com.rejuve.fitbitpublish"

    var delegate: FitbitPublishBackgroundDelegate?

    var receivedData: Data?
    
    private var session: URLSession!

    #if !os(macOS)
    var publishedCompletionHandler: (() -> Void)?
    #endif

    private override init() {
        super.init()

        let configuration = URLSessionConfiguration.background(withIdentifier: FitbitPublishBackground.identifier)
        if #available(iOS 13.0, *) {
            configuration.allowsConstrainedNetworkAccess = true
        }
        configuration.allowsCellularAccess = true
        configuration.isDiscretionary = true
        configuration.sessionSendsLaunchEvents = true
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    func start(accessToken: String, userID: String, userToken: String) {
        
        guard let path = Bundle.main.path(forResource: "amplifyconfiguration", ofType: "json"),
              let fileURL = URL(fileURLWithPath: path) as? URL,
              let fileData = try? String(contentsOf: fileURL).data(using: .utf8) else {
            self.delegate?.published(success: false)
            return
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let configData = try? decoder.decode(AWSAmplifyConfig.self, from: fileData) as? AWSAmplifyConfig,
              let apiURL = URL(string: "\(configData.api.plugins.awsAPIPlugin.rejuveDevelopmentAPI.endpoint)/health/application/FITBIT/synchronize") else {
            self.delegate?.published(success: false)
            return
        }
        
        var urlRequest = URLRequest(url: apiURL)
        urlRequest.httpMethod = "POST"
        urlRequest.allHTTPHeaderFields = ["token":userToken, "login_type":LoginType.PERSONAL]
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: ["access_token": accessToken, "user_id": userID], options: [])
        } catch let error {
            print(error.localizedDescription)
            self.delegate?.published(success: false)
            return
        }
        
        session.uploadTask(withStreamedRequest: urlRequest).resume()
    }
}

extension FitbitPublishBackground: URLSessionDelegate {
    #if !os(macOS)
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.publishedCompletionHandler?()
            self.publishedCompletionHandler = nil
        }
    }
    #endif
}

extension FitbitPublishBackground: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.delegate?.published(success: true)
        print("uploaded")
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("\(error.localizedDescription)")
            self.delegate?.published(success: false)
        } else {
            self.delegate?.published(success: true)
        }
    }
}

class FetchFitbitTokenOperation: Operation, BackgroundSessionDelegate {
    
    var refreshToken: String?
    var accessToken: String?
    var userID: String?
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        return downloading
    }
    
    override var isFinished: Bool {
        return refreshToken != nil && accessToken != nil
    }
    
    override func cancel() {
        super.cancel()
    }
    
    private var downloading = false
    
    func finish() {
        guard downloading else { return }
        
        willChangeValue(forKey: #keyPath(isExecuting))
        willChangeValue(forKey: #keyPath(isFinished))
        
        downloading = false
        
        didChangeValue(forKey: #keyPath(isFinished))
        didChangeValue(forKey: #keyPath(isExecuting))
    }
    
    override func start() {
        willChangeValue(forKey: #keyPath(isExecuting))
        downloading = true
        didChangeValue(forKey: #keyPath(isExecuting))
        
        guard let refreshToken = try? KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.FitbitRefreshToken).readItem() else {
            self.cancel()
            return
        }
        
        FitbitFetchBackground.shared.start(refreshToken: refreshToken)
        FitbitFetchBackground.shared.delegate = self
    }
    
    func receivedtoken(refreshToken: String?, accessToken: String?, userID: String?) {
        if accessToken == nil {
            self.cancel()
            return
        }
        self.refreshToken = refreshToken
        self.accessToken = accessToken
        self.userID = userID
        self.finish()
    }
}

class PublishFitbitTokenOperation: Operation, FitbitPublishBackgroundDelegate {
    
    var refreshToken: String?
    var accessToken: String?
    var userID: String?
    
    var responseString: String?
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        return downloading
    }
    
    override var isFinished: Bool {
        return responseString != nil
    }
    
    override func cancel() {
        super.cancel()
    }
    
    private var downloading = false
    
    func finish() {
        guard downloading else { return }
        
        willChangeValue(forKey: #keyPath(isExecuting))
        willChangeValue(forKey: #keyPath(isFinished))
        
        downloading = false
        
        didChangeValue(forKey: #keyPath(isFinished))
        didChangeValue(forKey: #keyPath(isExecuting))
    }
    
    override func start() {
        willChangeValue(forKey: #keyPath(isExecuting))
        downloading = true
        didChangeValue(forKey: #keyPath(isExecuting))
        
        guard let accessToken = self.accessToken, let userID = self.userID else {
            self.cancel()
            return
        }
        
        func onGettingCredentials(_ credentials: Credentials){
            FitbitPublishBackground.shared.start(accessToken: accessToken, userID: userID,
                                                 userToken: credentials.idToken)
            FitbitPublishBackground.shared.delegate = self
        }
        
        func onFailureCredentials(_ error: Error?) {
            print("publishData failed to fetch credentials \(error?.localizedDescription)")
            self.cancel()
        }
        
        _ = getCredentials(completion: onGettingCredentials(_:),
                           onFailure: onFailureCredentials(_:))
    }
    
    func published(success: Bool) {
        if success {
            self.finish()
        } else {
            self.cancel()
        }
    }
}
