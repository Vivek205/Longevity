//
//  Date.swift
//  Longevity
//
//  Created by vivek on 18/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation

func UTCStringToLocalDate(dateString:String, dateFormat:String = "yyyy-MM-dd HH:mm:ss") -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

    let date = dateFormatter.date(from: dateString)
    dateFormatter.timeZone = TimeZone.current
    return dateFormatter.date(from: dateString)
}
