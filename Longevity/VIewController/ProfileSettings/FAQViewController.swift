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

    lazy var webView: WKWebView = {
        let view = WKWebView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.navigationDelegate = self
        return view
    }()

    lazy var spinner:UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .black
        spinner.startAnimating()
        return spinner
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.containerView.addSubview(webView)

        let screenHeight = UIScreen.main.bounds.height
        let modalHeight = screenHeight - (UIDevice.hasNotch ? 100.0 : 60.0)

        webView.addSubview(spinner)
        spinner.hidesWhenStopped = true

        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: modalHeight),
            webView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            webView.topAnchor.constraint(equalTo: self.closeButton.bottomAnchor, constant: 2),
            webView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),

            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        webView.load(URLRequest(url: URL(string: "https://forum.rejuve.io/faq")!))
    }
}

extension FAQViewController:  WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinner.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        spinner.stopAnimating()
    }
}
