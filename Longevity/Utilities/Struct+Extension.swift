//
//  Struct+Extension.swift
//  Longevity
//
//  Created by vivek on 11/11/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation

extension Encodable {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}
