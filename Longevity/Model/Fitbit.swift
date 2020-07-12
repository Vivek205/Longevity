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

        let dataTask = URLSession.shared.dataTask(with: urlRequest){data, response,_   in
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200,
                data != nil else { return }
            do {
                if let jsonData: [String:Any] =
                    try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any] {
                    print(jsonData)
                    let accessToken = jsonData["access_token"] as! String
                    let refreshToken = jsonData["refresh_token"] as! String
                    let userId = jsonData["user_id"] as! String
                    
                    self.saveToken(accessToken: accessToken, refreshToken: refreshToken)
                    self.publishData(accessToken: accessToken, userId: userId)
                }
            } catch {}
        }
        dataTask.resume()
    }

    func publishData(accessToken: String, userId: String) {
        let credentials = getCredentials()
        let headers = ["token":credentials.idToken]
        let body = JSON(["access_token":accessToken, "user_id":userId])
        var bodyData:Data = Data();
        do {
            bodyData = try body.rawData()
        } catch  {
            print(error)
        }
        let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/device/FITBIT/synchronize" , headers: headers, body: bodyData)
        _ = Amplify.API.post(request: request, listener: { (result) in
            switch result{
            case .success(let data):
                let responseString = String(data: data, encoding: .utf8)
                print("sucess \(responseString)")

            case .failure(let apiError):
                print("failed \(apiError)")
            }
        })
    }

    func saveToken(accessToken: String, refreshToken: String) {
        guard let accessTokenData = accessToken.data(using: .utf8),
        let refreshTokenData = refreshToken.data(using: .utf8) else {
            return
        }

        KeyChain.save(name: KeychainKeys.FitbitAccessToken, data: accessTokenData)
        KeyChain.save(name: KeychainKeys.FitbitRefreshToken ,data: refreshTokenData)
    }

    func refreshTheToken() {
        guard let refreshTokenData = KeyChain.load(name: KeychainKeys.FitbitRefreshToken) else {return}
        let refreshToken = String(data: refreshTokenData, encoding: .utf8)

        let encodedBasicAuth = base64StringEncode("\(Constants.clientId):\(Constants.clientSecret)")
               var urlComponents = URLComponents(url: Constants.tokenUrl!, resolvingAgainstBaseURL: false)
               urlComponents?.queryItems = [
                   URLQueryItem(name: "grant_type", value: "refresh_token"),
                   URLQueryItem(name: "refresh_token", value:refreshToken),
               ]

        var urlRequest = URLRequest(url: (urlComponents?.url)!)
               urlRequest.httpMethod = "POST"
               urlRequest.addValue("Basic \(encodedBasicAuth)", forHTTPHeaderField: "Authorization")
               urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let dataTask = URLSession.shared.dataTask(with: urlRequest){data, response,_   in
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200,
                data != nil else { return }
            do {
                if let jsonData: [String:Any] =
                    try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any] {
                    print(jsonData)
                    let accessToken = jsonData["access_token"] as! String
                    let refreshToken = jsonData["refresh_token"] as! String
                    let userId = jsonData["user_id"] as! String
                    self.saveToken(accessToken: accessToken, refreshToken: refreshToken)
                    self.publishData(accessToken: accessToken, userId: userId)
                }
            } catch {}
        }
        dataTask.resume()
    }
}
