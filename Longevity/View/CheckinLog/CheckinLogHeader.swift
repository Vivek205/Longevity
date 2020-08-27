//
//  CheckinLogHeader.swift
//  Longevity
//
//  Created by vivek on 27/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CheckinLogHeader: UITableViewHeaderFooterView {

    lazy var segmentedControl: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Activity", "Settings"])
        if #available(iOS 13.0, *) {
            segment.selectedSegmentTintColor = .themeColor
        } else {
            segment.tintColor = .themeColor
        }

        let titleAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: "Montserrat-Regular", size: 14.0)]
        segment.setTitleTextAttributes(titleAttributes, for: .normal)
        let selectedTitleAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "Montserrat-Regular", size: 14.0)]
        segment.setTitleTextAttributes(selectedTitleAttributes, for: .selected)
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()



}
