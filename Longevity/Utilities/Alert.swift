//
//  Alert.swift
//  Longevity
//
//  Created by vivek on 23/10/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit


final class Alert {
    @discardableResult
    convenience init(title: String, message: String) {
        self.init()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert: alert, animated: true)
    }

    @discardableResult
    convenience init(title: String, message: String, action: UIAlertAction) {
        self.init()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(action)
        self.present(alert: alert, animated: true)
    }
    
    @discardableResult
    convenience init(type: UIAlertType) {
        self.init()
        let alert = UIAlertController(title: type.title, message: type.message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default ))
        if let subview = alert.view.subviews.first?.subviews.first?.subviews.first {
            subview.backgroundColor = type.color
        }
        self.present(alert: alert, animated: true)
    }

    private func present(alert:UIAlertController, animated: Bool) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(alert, animated: true)
        }
    }
}
