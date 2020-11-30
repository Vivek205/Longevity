//
//  FitbitFetchBackground.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 30/11/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

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

    func start(refreshToken: String) -> URLSessionDownloadTask {
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
        
        let downloadTask = session.downloadTask(with: urlRequest)
        downloadTask.resume()
        return downloadTask
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
