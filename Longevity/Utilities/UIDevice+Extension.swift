//
//  UIDevice+Extension.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 07/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

extension UIDevice {

    /// Returns 'true' if the device has a notch
   static var hasNotch: Bool {
        guard #available(iOS 11.0, *), let window = UIApplication.shared.keyWindow else { return false }
        let orientation = UIApplication.shared.statusBarOrientation
        if orientation.isPortrait {
            return window.safeAreaInsets.top >= 44
        } else {
            return window.safeAreaInsets.left > 0 || window.safeAreaInsets.right > 0
        }
    }
}
