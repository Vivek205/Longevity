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
    @IBOutlet weak var footer: UIView!
    @IBOutlet weak var viewNavigationItem: UINavigationItem!
    @IBOutlet weak var continueButton: CustomButtonFill!
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Terms of Service & Data Privacy"
        label.font = UIFont(name: "Montserrat-SemiBold", size: 24.0)
        label.textColor = UIColor(hexString: "#4E4E4E")
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
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
//        view.scrollView.delegate = self
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
        self.continueButton.isEnabled = false
        self.navigationController?.navigationBar.barTintColor = .appBackgroundColor
        navigationController?.delegate = self
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.removeBackButtonNavigation()
        self.view.backgroundColor = .appBackgroundColor
        
        self.view.addSubview(titleLabel)
        
        self.view.addSubview(contentContainer)
        contentContainer.addSubview(webView)
        self.view.addSubview(shieldImage)
        
        self.view.addSubview(acceptCard)
        acceptCard.addSubview(acceptLabel)
        acceptCard.addSubview(acceptCheckbox)
//        acceptCard.isHidden = true

        webView.load(URLRequest(url: URL(string: tosWebViewURL)!))
        
        webView.addSubview(spinner)
        spinner.hidesWhenStopped = true
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 64.0),
            
            shieldImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shieldImage.centerYAnchor.constraint(equalTo: contentContainer.topAnchor),
            shieldImage.widthAnchor.constraint(equalToConstant: 55.0),
            shieldImage.heightAnchor.constraint(equalToConstant: 64.0),
            
            contentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0),
            contentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0),
            contentContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 36.5),
            contentContainer.bottomAnchor.constraint(equalTo: acceptCard.topAnchor, constant: -36.0),
            
            webView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 10.0),
            webView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -10.0),
            webView.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 35),
            webView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -10.0),

            spinner.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: webView.centerYAnchor),
            
            acceptCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0),
            acceptCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0),
            acceptCard.bottomAnchor.constraint(equalTo: footer.topAnchor, constant: -12.0),
            acceptCard.heightAnchor.constraint(equalToConstant: 74.0),
            
            acceptCheckbox.centerYAnchor.constraint(equalTo: acceptCard.centerYAnchor),
            acceptCheckbox.trailingAnchor.constraint(equalTo: acceptCard.trailingAnchor, constant: -12.0),
            acceptCheckbox.widthAnchor.constraint(equalToConstant: 24.0),
            acceptCheckbox.heightAnchor.constraint(equalToConstant: 24.0),
            
            acceptLabel.leadingAnchor.constraint(equalTo: acceptCard.leadingAnchor, constant: 15.0),
            acceptLabel.trailingAnchor.constraint(equalTo: acceptCheckbox.leadingAnchor, constant: 14.0),
            acceptLabel.topAnchor.constraint(equalTo: acceptCard.topAnchor, constant: 15.0),
            acceptLabel.bottomAnchor.constraint(equalTo: acceptCard.bottomAnchor, constant: -15.0)
        ])
        
        styleNavigationBar()
        
        if self.isFromSettings {
            let leftbutton = UIBarButtonItem(image: UIImage(named: "icon: arrow")?.withHorizontallyFlippedOrientation(), style: .plain, target: self, action: #selector(closeView))
            leftbutton.tintColor = .themeColor
            self.viewNavigationItem.leftBarButtonItem = leftbutton
            self.viewNavigationItem.rightBarButtonItems = nil
            let titleLabel = UILabel()
            titleLabel.text = "Terms of Service"
            titleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 17.0)
            titleLabel.textColor = UIColor(hexString: "#4E4E4E")
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            self.viewNavigationItem.titleView = titleLabel
            self.footer.isHidden = true
            self.acceptCard.isHidden = true
            self.acceptLabel.isHidden = true
            self.acceptCheckbox.isHidden = true
        }
    }
    
    func customizeFooter(footer: UIView){
        footer.layer.shadowPath = UIBezierPath(rect: footer.bounds).cgPath
        footer.layer.shadowRadius = 5
        footer.layer.shadowOffset = .zero
        footer.layer.shadowOpacity = 1
        footer.layer.shadowColor = UIColor.black.cgColor
        footer.layer.masksToBounds = false
        footer.clipsToBounds = false
        footer.backgroundColor = UIColor.black
    }
    
    @objc func handleAcceptCheckboxTap(_ sender: CardView) {
        acceptCheckbox.isSelected = !acceptCheckbox.isSelected
        continueButton.isEnabled = acceptCheckbox.isSelected
    }
    
    // MARK: Actions
    @IBAction func handleAcceptTerms(_ sender: Any) {
        print("Terms Accepted")
        acceptTNC(value: true)
        performSegue(withIdentifier: "TOSToProfileSetup", sender: self)
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
//        termsOfServiceURLLoaded = true
        spinner.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        spinner.stopAnimating()
    }
}

//extension TermsOfServiceVC: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if termsOfServiceURLLoaded {
//            if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
//                acceptCard.isHidden = false
//            }
//        }
//    }
//}
