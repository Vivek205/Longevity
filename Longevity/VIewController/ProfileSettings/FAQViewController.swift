//
//  FAQViewController.swift
//  Longevity
//
//  Created by vivek on 28/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import WebKit

class FAQViewController: BasePopUpModalViewController {

    lazy var webview: WKWebView = {
        let view = WKWebView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.containerView.addSubview(webview)

        let screenHeight = UIScreen.main.bounds.height
        let modalHeight = screenHeight - (UIDevice.hasNotch ? 100.0 : 60.0)

        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: modalHeight),
            webview.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            webview.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            webview.topAnchor.constraint(equalTo: self.closeButton.bottomAnchor, constant: 2),
            webview.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor)
        ])

        webview.load(URLRequest(url: URL(string: "https://www.apple.com")!))
    }


}
