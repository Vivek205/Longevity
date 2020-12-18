//
//  TermsOfServiceVC.swift
//  Longevity
//
//  Created by vivek on 03/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify
import Sentry
import WebKit

fileprivate let termsOfServiceContent = TermsOfServiceContent()
fileprivate let tosWebViewURL = "https://rejuve-public.s3-us-west-2.amazonaws.com/Beta-TOS.html"

class TermsOfServiceVC: BaseProfileSetupViewController, UINavigationControllerDelegate {
    // MARK: Outlets
    @IBOutlet weak var viewNavigationItem: UINavigationItem!

    lazy var continueButton: CustomButtonFill = {
        let button = CustomButtonFill(title: "Continue", target: self, action: #selector(handleAcceptTerms(_:)))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var acceptCard: CardView = {
        let card = CardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 4.0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAcceptCheckboxTap(_:)))
        card.addGestureRecognizer(tapGesture)
        
        return card
    }()
    
    lazy var acceptLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "I agree to the Terms of Service Agreement."
        label.font = UIFont(name: "Montserrat-Medium", size: 18)
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()
    
    lazy var acceptCheckbox: CheckboxButton = {
        let button = CheckboxButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleAcceptCheckboxTap(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var contentContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 10
        return container
    }()
    
    lazy var webView: WKWebView = {
        let view = WKWebView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.navigationDelegate = self
        view.scrollView.isScrollEnabled = false
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy var shieldImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "temsAndConditionsShield")
        return image
    }()
    
    lazy var spinner:UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .black
        spinner.startAnimating()
        return spinner
    }()
    
    var isFromSettings: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        NOTE: - keep the styleNavigationBar on the top
        styleNavigationBar()

        if !isFromSettings {
            AppSyncManager.instance.syncSurveyList()
        }

        self.continueButton.isEnabled = false
        self.navigationController?.navigationBar.barTintColor = .appBackgroundColor
        navigationController?.delegate = self
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.removeBackButtonNavigation()
        self.view.backgroundColor = .appBackgroundColor
        self.title = "Terms of Service"
        self.navigationController?.navigationBar.isTranslucent = true
        
        self.view.addSubview(contentContainer)
        contentContainer.addSubview(webView)
        self.view.addSubview(shieldImage)
        
        self.view.addSubview(acceptCard)
        acceptCard.addSubview(acceptLabel)
        acceptCard.addSubview(acceptCheckbox)

        self.view.addSubview(continueButton)

        webView.load(URLRequest(url: URL(string: tosWebViewURL)!))
        
        webView.addSubview(spinner)
        spinner.hidesWhenStopped = true

        let navBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (navigationController?.navigationBar.frame.height ?? 0.0)

        let shieldImageHeight: CGFloat = 64.0
        let containerTopPadding = navBarHeight + (shieldImageHeight / 2)
        
        NSLayoutConstraint.activate([
            
            shieldImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shieldImage.centerYAnchor.constraint(equalTo: contentContainer.topAnchor),
            shieldImage.widthAnchor.constraint(equalToConstant: 55.0),
            shieldImage.heightAnchor.constraint(equalToConstant: shieldImageHeight),
            
            contentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0),
            contentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0),
            contentContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: containerTopPadding),
            contentContainer.bottomAnchor.constraint(equalTo: acceptCard.topAnchor, constant: -38),
            
            webView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 10.0),
            webView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -10.0),
            webView.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 35),
            webView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -10.0),

            spinner.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: webView.centerYAnchor),
            
            acceptCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0),
            acceptCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0),
            acceptCard.heightAnchor.constraint(equalToConstant: 74.0),
            acceptCard.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -36),

            acceptCheckbox.centerYAnchor.constraint(equalTo: acceptCard.centerYAnchor),
            acceptCheckbox.trailingAnchor.constraint(equalTo: acceptCard.trailingAnchor, constant: -12.0),
            acceptCheckbox.widthAnchor.constraint(equalToConstant: 24.0),
            acceptCheckbox.heightAnchor.constraint(equalToConstant: 24.0),
            
            acceptLabel.leadingAnchor.constraint(equalTo: acceptCard.leadingAnchor, constant: 15.0),
            acceptLabel.trailingAnchor.constraint(equalTo: acceptCheckbox.leadingAnchor, constant: 14.0),
            acceptLabel.topAnchor.constraint(equalTo: acceptCard.topAnchor, constant: 15.0),
            acceptLabel.bottomAnchor.constraint(equalTo: acceptCard.bottomAnchor, constant: -15.0),

            continueButton.heightAnchor.constraint(equalToConstant: 48),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15)
        ])


        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleWebviewTap(_:)))
        contentContainer.addGestureRecognizer(tapGesture)
    }

    override func viewDidLayoutSubviews() {
        contentContainer.layer.borderWidth = 2
        contentContainer.layer.borderColor = UIColor.themeColor.cgColor
        contentContainer.layer.cornerRadius = 10
    }

    @objc func handleAcceptCheckboxTap(_ sender: CardView) {
        acceptCheckbox.isSelected = !acceptCheckbox.isSelected
        acceptCard.layer.cornerRadius = 4.0
        if acceptCheckbox.isSelected {
            acceptCard.layer.borderWidth = 2.0
            acceptCard.layer.borderColor = UIColor.themeColor.cgColor
        } else {
            acceptCard.layer.borderWidth = 0
        }
        continueButton.isEnabled = acceptCheckbox.isSelected
    }

    @objc func handleAcceptTerms(_ sender: Any) {
        print("Terms Accepted")
        UserAPI.instance.acceptTNC(value: true)
        performSegue(withIdentifier: "TOSToProfileSetup", sender: self)
    }

    @objc func handleWebviewTap(_ sender: Any) {
        //        Alert(title: "handle Web view tap", message: "webview tap")
        let termsOfServiceContextVC = TermsOfServiceContextVC()
        termsOfServiceContextVC.title = "Terms of Service Details"
        let navigationController = UINavigationController(rootViewController: termsOfServiceContextVC)

        NavigationUtility.presentOverCurrentContext(destination: navigationController)
    }
    
    
    @IBAction func unwindToTermsOfService(_ sender: UIStoryboardSegue){
        print("unwound to terms of service")
    }
    
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension UIViewController {
    func removeBackButtonNavigation() {
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    func styleNavigationBar() {
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = UIColor.white
        navigationBar?.isTranslucent = false
        navigationBar?.setBackgroundImage(UIImage(), for: .default)
        navigationBar?.shadowImage = UIImage()
        navigationBar?.tintColor = #colorLiteral(red: 0.4175422788, green: 0.7088702321, blue: 0.7134250998, alpha: 1)
    }
}

extension TermsOfServiceVC:  WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinner.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        spinner.stopAnimating()
    }
}

