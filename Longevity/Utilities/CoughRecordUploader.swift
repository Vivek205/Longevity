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
        guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let path = documentURL.appendingPathComponent(SurveyTaskUtility.shared.coughTestFolderName).absoluteURL
            do {
                try FileManager.default.createDirectory(atPath: path.relativePath, withIntermediateDirectories: true)
                let directoryContents = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
                let filesPath = directoryContents.filter{ $0.pathExtension == "wav" }
                let fileNames = filesPath.map{ (filekey: $0.lastPathComponent, fileURL: $0) }
                CoughRecordUploader.uploadedFileCount = 0
                
                for filename in fileNames {
                    let fileuploadKey = "\(SurveyTaskUtility.shared.coughTestFolderName)/\(filename.filekey)"
                    
                    guard let fileData = try? Data(contentsOf: filename.fileURL) else { return }
                    
                    self.uploadVoiceData(fileKey: fileuploadKey, coughData: fileData) { [weak self] (uploaded) in
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
            } catch {
                print(error.localizedDescription)
            }
    }
    
//    guard let url = self.audioRecorder?.url, let coughData = try? Data(contentsOf: url) else {
//        return
//    }
//
//    let coughRecordUploader = CoughRecordUploader()
//    coughRecordUploader.uploadVoiceData(fileKey: "COUGH_TEST/" + self.fileKey,
//                                        coughData: coughData,
//                                        completion: { [weak self] (success) in
//        if success {
//            guard let filekey = self?.fileKey else { return }
//            coughRecordUploader.generateURL(for: filekey) { [weak self] (fileURL) in
//                if let questionId = self?.step?.identifier as? String {
//                    SurveyTaskUtility.shared.setCurrentSurveyLocalAnswer(questionIdentifier: questionId,
//                                                                         answer: fileURL)
//                }
//                DispatchQueue.main.async {
//                    self?.removeSpinner()
//                    self?.goForward()
//                }
//            }
//        } else {
//            DispatchQueue.main.async {
//                self?.removeSpinner()
//            }
//        }
//    })
    
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
