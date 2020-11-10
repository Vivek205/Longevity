//
//  TermsOfServiceContextVC.swift
//  Longevity
//
//  Created by vivek on 10/11/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import WebKit

fileprivate let tosWebViewURL = "https://rejuve-public.s3-us-west-2.amazonaws.com/Beta-TOS.html"

class TermsOfServiceContextVC: UIViewController {
    lazy var containerView: UIView = {
        let containerView = UIView(backgroundColor: .white)
        containerView.backgroundColor = .white
        return containerView
    }()

    lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        return webView
    }()

    lazy var spinner:UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.color = .black
        spinner.startAnimating()
        return spinner
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.title == nil {
            self.title = "Terms of Service"
        }

        if let navigationBar = navigationController?.navigationBar {
            navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.sectionHeaderColor,
                NSAttributedString.Key.font: UIFont(name: AppFontName.semibold, size: 17)]
        }

        let leftbutton = UIBarButtonItem(image: UIImage(named: "icon: arrow")?.withHorizontallyFlippedOrientation(), style: .plain, target: self, action: #selector(closeView))
        leftbutton.tintColor = .themeColor
        self.navigationItem.leftBarButtonItem = leftbutton
//        self.containerView.backgroundColor = .orange
        self.view.addSubview(containerView)
        self.containerView.addSubview(webView)
        webView.addSubview(spinner)
        spinner.hidesWhenStopped = true

        let window = UIApplication.shared.keyWindow
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0

        self.containerView.fillSuperview()

        webView.fillSuperview(padding: .init(top: 0, left: 15, bottom: bottomPadding, right: 15))
//        webView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
//        webView.layoutMargins = .init(top: 0, left: 10, bottom: 10, right: 10)
        spinner.centerXTo(webView.centerXAnchor)
        spinner.centerYTo(webView.centerYAnchor)
        if let webviewURL = URL(string: tosWebViewURL) {
            webView.load(URLRequest(url: webviewURL))
        }

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension TermsOfServiceContextVC:  WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        termsOfServiceURLLoaded = true
        spinner.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        spinner.stopAnimating()
    }
}
