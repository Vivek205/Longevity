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
    
    static var uploadedFileCount: Int = 0
    
    func uploadCoughTestFiles(success: @escaping() -> Void, failure: @escaping(String) -> Void) {
        guard let documentURL = FileManager.default.urls(for: .documentDirectory,
                                                         in: .userDomainMask).first else { return }
        let path = documentURL.appendingPathComponent(SurveyTaskUtility.shared.coughTestFolderName).absoluteURL
        do {
            try FileManager.default.createDirectory(atPath: path.relativePath, withIntermediateDirectories: true)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: path,
                                                                                includingPropertiesForKeys: nil,
                                                                                options: [])
            if directoryContents.count > 0 {
                let filesPath = directoryContents.filter{ $0.pathExtension == "wav" }
                let fileNames = filesPath.map{ (filekey: $0.lastPathComponent, fileURL: $0) }
                CoughRecordUploader.uploadedFileCount = 0
                
                if !fileNames.isEmpty {
                    for filename in fileNames {
                        let fileuploadKey = "\(SurveyTaskUtility.shared.coughTestFolderName)/\(filename.filekey)"
                        
                        guard let fileData = try? Data(contentsOf: filename.fileURL) else { return }
                        
                        self.uploadVoiceData(fileKey: fileuploadKey, coughData: fileData) { (uploaded) in
                            if uploaded {
                                CoughRecordUploader.uploadedFileCount += 1
                                if CoughRecordUploader.uploadedFileCount == fileNames.count {
                                    CoughRecordUploader.uploadedFileCount = 0
                                    success()
                                }
                            } else {
                                failure("Failed to upload files")
                            }
                        }
                    }
                } else {
                    failure("Failed to upload files")
                }
            } else {
                failure("Failed to upload files")
            }
        } catch {
            failure("Failed to upload files")
        }
    }
    
    func uploadVoiceData(fileKey: String, coughData: Data, completion: @escaping(Bool) -> Void) {
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
    
    func removeDirectory() {
        guard let documentURL = FileManager.default.urls(for: .documentDirectory,
                                                         in: .userDomainMask).first else { return }
        let path = documentURL.appendingPathComponent(SurveyTaskUtility.shared.coughTestFolderName).absoluteURL
        
        try? FileManager.default.removeItem(at: path)
    }
    
    func generateURL(for itemKey: String, completion: @escaping(String) -> Void) {
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
