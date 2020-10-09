//
//  Array+Extension.swift
//  Longevity
//
//  Created by vivek on 09/10/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    var uniques: Array {
        var buffer = Array()
        var added = Set<Element>()
        for elem in self {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
}
