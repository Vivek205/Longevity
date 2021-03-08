//
//  FitbitPublishBackground.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 30/11/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

protocol FitbitPublishBackgroundDelegate: class {
    func published(success: Bool)
}

class FitbitPublishBackground: NSObject {
    static let shared = FitbitPublishBackground()

    static let identifier = "com.rejuve.fitbitpublish"

    weak var delegate: FitbitPublishBackgroundDelegate?

    var receivedData: Data?
    
    private var session: URLSession!
    
    var uploadTask: URLSessionUploadTask?

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

    func start(accessToken: String, userID: String, userToken: String) -> URLSessionUploadTask? {
        
        guard let path = Bundle.main.path(forResource: Strings.configFile, ofType: "json"),
              let fileURL = URL(fileURLWithPath: path) as? URL,
              let fileData = try? String(contentsOf: fileURL).data(using: .utf8) else {
            self.delegate?.published(success: false)
            return nil
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let configData = try? decoder.decode(AWSAmplifyConfig.self, from: fileData) as? AWSAmplifyConfig,
              let apiURL = URL(string: "\(configData.api.plugins.awsAPIPlugin.rejuveDevelopmentAPI.endpoint)/health/application/FITBIT/synchronize") else {
            self.delegate?.published(success: false)
            return nil
        }
        
        var urlRequest = URLRequest(url: apiURL)
        urlRequest.httpMethod = "POST"
        urlRequest.allHTTPHeaderFields = ["token":userToken, "Content-Type": "application/json", "login_type":LoginType.PERSONAL]
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject:
                                                                ["access_token": accessToken, "user_id": userID], options: [])
        } catch let error {
            print(error.localizedDescription)
            self.delegate?.published(success: false)
            return nil
        }
        
        let uploadTask = session.uploadTask(withStreamedRequest: urlRequest)
        uploadTask.resume()
        return uploadTask
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
