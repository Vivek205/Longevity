//
//  BaseProfileSetupViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 26/09/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class BaseProfileSetupViewController: UIViewController {
   
    lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        let progressViewHeight = progressView.bounds.height
        progressView.subviews.forEach { (subview) in
            subview.layer.masksToBounds = true
            subview.layer.cornerRadius = progressViewHeight / 2.0
        }
        return progressView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "#F5F6FA")
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 24.0)!,
                                                                        NSAttributedString.Key.foregroundColor: UIColor(hexString: "#4E4E4E")]
    }
    
    func addProgressbar(progress: Float) {
        self.navigationItem.titleView = UIView()
        self.navigationItem.titleView?.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            progressView.widthAnchor.constraint(equalToConstant: 200.0),
            progressView.heightAnchor.constraint(equalToConstant: 4.0),
            progressView.centerYAnchor.constraint(equalTo: (self.navigationItem.titleView?.centerYAnchor)!),
            progressView.centerXAnchor.constraint(equalTo: (self.navigationItem.titleView?.centerXAnchor)!)
        ])
        progressView.setProgress(progress / 100, animated: false)
    }
}
