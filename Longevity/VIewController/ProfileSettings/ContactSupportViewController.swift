//
//  ContactSupportViewController.swift
//  Longevity
//
//  Created by vivek on 29/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import WebKit

class ContactSupportViewController: BasePopupViewController {
    lazy var webView: WKWebView = {
        let view = WKWebView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.load(URLRequest(url: URL(string: "https://rejuve.io/contact/")!))
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
        self.title = "Contact Support"

        let navigationBar = navigationController?.navigationBar
        navigationBar?.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.sectionHeaderColor,
            NSAttributedString.Key.font: UIFont(name: AppFontName.semibold, size: 17)]

        let leftbutton = UIBarButtonItem(image: UIImage(named: "icon: arrow")?.withHorizontallyFlippedOrientation(), style: .plain, target: self, action: #selector(closeView))
        leftbutton.tintColor = .themeColor
        self.navigationItem.leftBarButtonItem = leftbutton

        self.view.addSubview(webView)
        webView.addSubview(spinner)         
        spinner.hidesWhenStopped = true

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            spinner.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: webView.centerYAnchor)
        ])
    }
}

extension ContactSupportViewController:  WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinner.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        spinner.stopAnimating()
    }
}


