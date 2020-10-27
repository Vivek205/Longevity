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
        return progressView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = .appBackgroundColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 24.0)!,
                                                                        NSAttributedString.Key.foregroundColor: UIColor.sectionHeaderColor]
        self.view.backgroundColor = .appBackgroundColor
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let progressViewHeight = progressView.frame.size.height
        progressView.layer.cornerRadius = progressViewHeight / 2
        progressView.clipsToBounds = true
        progressView.subviews.forEach { (subview) in
            subview.layer.masksToBounds = true
            subview.layer.cornerRadius = progressViewHeight / 2.0
            subview.clipsToBounds = true
        }
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
