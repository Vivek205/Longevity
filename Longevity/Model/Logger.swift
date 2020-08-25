//
//  Logger.swift
//  Longevity
//
//  Created by vivek on 25/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation

fileprivate let dateTimeFormat = "MMM-dd HH:mm:ss"

struct LogItem: Codable {
    var time: String
    var info: String
}

class Logger {
    static func log(_ info: String){
        let formatter = DateFormatter()
        formatter.dateFormat = dateTimeFormat
        let dateString = formatter.string(from: Date())
        let logItem: LogItem = LogItem(time: dateString, info: info)

        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()

        var loggerData: [LogItem] = [LogItem]()

        if var loggerDataEncoded = defaults.object(forKey: keys.logger) as? Data {
            do {
                let decodedData = try PropertyListDecoder().decode([LogItem].self, from: loggerDataEncoded)
                loggerData += decodedData
                loggerData += [logItem]
                
                    let encodedData = try PropertyListEncoder().encode(loggerData)
                defaults.set(encodedData, forKey: keys.logger)
            } catch {
                print("log error", error)
            }
        } else {
            loggerData += [logItem]
            do {
                let encodedData = try PropertyListEncoder().encode(loggerData)
                defaults.set(encodedData, forKey: keys.logger)
            } catch {
                print("log error", error)
            }
        }
    }

    func getLoggerData() -> [LogItem]?{
        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()
        if let loggerData = defaults.object(forKey: keys.logger) as? Data {
            do {
                let decodedData = try PropertyListDecoder().decode([LogItem].self, from: loggerData)
                return decodedData
            } catch  {
                  print("log error", error)
            }

        }
        return nil
    }
}
