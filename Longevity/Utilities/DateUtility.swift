//
//  DateUtility.swift
//  COVID Signals
//
//  Created by Jagan Kumar Mudila on 04/03/2021.
//  Copyright © 2021 vivek. All rights reserved.
//

import Foundation

class DateUtility {
    
    static let dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    static func getTodayString() -> String {
        return getString(from: Date())
    }
    
    static func getString(from date: Date, format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = format
        return dateformatter.string(from: date)
    }
    
    static func getDate(from string: String, format: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = format
        return dateformatter.date(from: string)
    }
    
    static func getString(from string: String, fromFormat:String = "yyyy-MM-dd HH:mm:ss",
                              toFormat:String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let utcDate = dateFormatter.date(from: string)

        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = toFormat
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        return dateFormatter.string(from: utcDate ?? Date())
    }
}
