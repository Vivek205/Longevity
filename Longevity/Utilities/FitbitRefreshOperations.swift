//
//  FitbitRefreshOperations.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 30/11/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class FetchFitbitTokenOperation: Operation, BackgroundSessionDelegate {
    
    var refreshToken: String?
    var accessToken: String?
    var userID: String?
    
    var downLoadTask : URLSessionDownloadTask?
    
    override var isExecuting: Bool {
        return downloading
    }
    
    override var isFinished: Bool {
        return refreshToken != nil && accessToken != nil
    }
    
    override func cancel() {
        super.cancel()
        self.downLoadTask?.cancel()
    }
    
    private var downloading = false
    
    override init() {
        super.init()
        
        self.name = "FetchFitbitToken"
    }
    
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
        
        guard let refreshToken = try? KeyChain(service: KeychainConfiguration.serviceName,
                                               account: KeychainKeys.FitbitRefreshToken).readItem() else {
            self.cancel()
            return
        }
        
        self.downLoadTask = FitbitFetchBackground.shared.start(refreshToken: refreshToken)
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
    override init() {
        super.init()
        
        self.name = "PublishFitbitToken"
    }
    
    var refreshToken: String?
    var accessToken: String?
    var userID: String?
   
    var succeeded: Bool = false
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        return downloading
    }
    
    override var isFinished: Bool {
        return self.succeeded
    }
    
    override func cancel() {
        super.cancel()
        FitbitPublishBackground.shared.uploadTask?.cancel()
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
        do {
            let idToken = try KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.idToken).readItem()
            
            FitbitPublishBackground.shared.start(accessToken: accessToken,
                                                                    userID: userID,
                                                                    userToken: idToken)
            FitbitPublishBackground.shared.delegate = self
        } catch {
            print("Fetch auth session failed with error - \(error)")
            self.cancel()
        }
    }
    
    func published(success: Bool) {
        self.succeeded = success
        if success {
            self.finish()
        } else {
            self.cancel()
        }
    }
}
