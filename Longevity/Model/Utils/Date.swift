//
//  Date.swift
//  Longevity
//
//  Created by vivek on 18/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation

func UTCStringToLocalDateString(dateString:String, dateFormat:String = "yyyy-MM-dd HH:mm:ss",
                          outputDateFormat:String = "yyyy-MM-dd HH:mm:ss") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    let utcDate = dateFormatter.date(from: dateString)

    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = outputDateFormat
    return dateFormatter.string(from: utcDate ?? Date())
}
