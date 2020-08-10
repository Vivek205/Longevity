//
//  NavigationUtility.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 06/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class NavigationUtility {
    static func presentWithNavigationController(source: UIViewController, destination: UIViewController, with animation: UIModalTransitionStyle? = nil, completion: (() -> Void)? = nil) {
        let navigationController = UINavigationController(rootViewController: destination)
        navigationController.navigationBar.barTintColor = .clear
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.tintColor = .white
        navigationController.modalPresentationStyle = .currentContext
        navigationController.modalTransitionStyle = animation != nil ? animation! : .crossDissolve
        source.present(navigationController, animated: true, completion: completion)
    }
    
    static func presentOverCurrentContext(source: UIViewController, destination: UIViewController, completion: (() -> Void)? = nil) {
        destination.modalPresentationStyle = .overCurrentContext
        destination.modalTransitionStyle = .coverVertical
        source.present(destination, animated: true, completion: completion)
    }
    
    static func presentOverCurrentContext(destination: UIViewController, style: UIModalPresentationStyle = .pageSheet, completion: (() -> Void)? = nil) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            destination.modalPresentationStyle = style
            destination.modalTransitionStyle = .coverVertical
            topController.present(destination, animated: true, completion: completion)
        }
    }
}
