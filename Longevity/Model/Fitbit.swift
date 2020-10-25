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

extension FitbitModel: BackgroundSessionDelegate {
    func receivedtoken(data: Data) {
        do {
            if let jsonData: [String:Any] =
                try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                let accessToken = jsonData["access_token"] as! String
                let refreshToken = jsonData["refresh_token"] as! String
                let userId = jsonData["user_id"] as! String
                Logger.log("fitbit token refreshed")
                self.saveToken(accessToken: accessToken, refreshToken: refreshToken)
                self.publishData(accessToken: accessToken, userId: userId)
            }
        } catch {}
    }
}

protocol BackgroundSessionDelegate {
    func receivedtoken(data: Data)
}

class BackgroundSession: NSObject {
    static let shared = BackgroundSession()

    static let identifier = "come.rejuve.fitbitrefresh"

    var delegate: BackgroundSessionDelegate?

    var receivedData: Data?
    
    private var session: URLSession!

    #if !os(macOS)
    var savedCompletionHandler: (() -> Void)?
    #endif

    private override init() {
        super.init()

        let configuration = URLSessionConfiguration.background(withIdentifier: BackgroundSession.identifier)
        configuration.waitsForConnectivity = true
        configuration.sessionSendsLaunchEvents = true
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    func start(_ request: URLRequest) {
        session.downloadTask(with: request).resume()
    }

    func startdataTask(_ request: URLRequest) {
        session.dataTask(with: request).resume()
    }
}

extension BackgroundSession: URLSessionDelegate {
    #if !os(macOS)
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.savedCompletionHandler?()
            self.savedCompletionHandler = nil
        }
    }
    #endif
}

extension BackgroundSession: URLSessionTaskDelegate {

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

extension BackgroundSession: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)
            if let jsonData: [String:Any] =
                try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                let accessToken = jsonData["access_token"] as! String
                let refreshToken = jsonData["refresh_token"] as! String
                let userId = jsonData["user_id"] as! String
                guard let accessTokenData = accessToken.data(using: .utf8),
                let refreshTokenData = refreshToken.data(using: .utf8) else {
                    return
                }

                try? KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.FitbitAccessToken).saveItem(accessToken)
                try? KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.FitbitRefreshToken).saveItem(refreshToken)
                Logger.log("fitbit token saved in keychain")
            }
        } catch {
            print("\(error.localizedDescription)")
        }
    }
}

class FetchFitbitTokenOperation: Operation {
    
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

            let dataTask = URLSession.shared.dataTask(with: urlRequest){data, response,_   in
                guard let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200,
                    data != nil else {
                    self.cancel()
                    return
                }
                do {
                    if let jsonData: [String:Any] =
                        try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any] {
                        self.accessToken = jsonData["access_token"] as! String
                        self.refreshToken = jsonData["refresh_token"] as! String
                        self.userID = jsonData["user_id"] as! String
                        
                        try? KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.FitbitAccessToken).saveItem(self.accessToken!)
                        try? KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.FitbitRefreshToken).saveItem(self.refreshToken!)
                        
                        self.finish()
                    }
                } catch {
                    self.cancel()
                    return
                }
            }
            dataTask.resume()
    }
}

class PublishFitbitTokenOperation: Operation {
    
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
        
        func onGettingCredentials(_ credentials: Credentials){
            let headers = ["token":credentials.idToken, "login_type":LoginType.PERSONAL]
            let body = JSON(["access_token": self.accessToken, "user_id": self.userID])
            var bodyData:Data = Data()
            do {
                bodyData = try body.rawData()
            } catch  {
                print(error)
            }
            let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/health/application/FITBIT/synchronize" , headers: headers, body: bodyData)
            _ = Amplify.API.post(request: request, listener: { [weak self] (result) in
                switch result{
                case .success(let data):
                    self?.responseString = String(data: data, encoding: .utf8)
                    self?.finish()
                    Logger.log("Fitbit data published")
                case .failure(let apiError):
                    print(" publish data error \(apiError)")
                    Logger.log("Fitbit publish failure \(apiError)")
                    self?.cancel()
                }
            })
        }
        
        func onFailureCredentials(_ error: Error?) {
            print("publishData failed to fetch credentials \(error)")
            self.downloading = false
        }
        
        _ = getCredentials(completion: onGettingCredentials(_:), onFailure: onFailureCredentials(_:))
    }
}
