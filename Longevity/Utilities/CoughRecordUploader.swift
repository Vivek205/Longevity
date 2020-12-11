//
//  CoughRecordUploader.swift
//  COVID Signals
//
//  Created by Jagan Kumar Mudila on 10/12/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import Amplify

class CoughRecordUploader {
    func uploadVoiceData(fileKey: String, coughData: Data, completion: @escaping(Bool)-> Void) {
         Amplify.Storage.uploadData(key: fileKey, data: coughData) { (progress) in
            print("Progress: \(progress)")
        } resultListener: { (event) in
            switch event {
            case .success(let data):
                print("Completed: \(data)")
                completion(true)
            case .failure(let storageError):
                print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                completion(false)
        }
        }
    }
    
    func generateURL(for itemKey: String, completion: @escaping(String)-> Void) {
        Amplify.Storage.getURL(key: itemKey) { event in
            switch event {
            case let .success(url):
                print(url.absoluteString)
                completion(url.absoluteString)
            case let .failure(storageError):
                print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
            }
        }
    }
}
