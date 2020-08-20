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

extension Date {
  func timeAgoDisplay() -> String {
    let calendar = Calendar.current
    let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
    let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
    let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
    if minuteAgo < self {
      let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
      return "\(diff) sec ago"
    } else if hourAgo < self {
      let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
      return "\(diff) min ago"
    } else if dayAgo < self {
      let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
      return "\(diff) hrs ago"
    }
    let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
    return "\(diff) day(s) ago"
  }
}
