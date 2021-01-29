//
//  SurveyIntroViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 05/10/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

class SurveyIntroViewController: ORKInstructionStepViewController {
    var keyboardHeight: CGFloat?
    var initialYOrigin: CGFloat = CGFloat(0)
    
    var isCoughTest: Bool = false

    lazy var containerView: UIView = {
        let container = UIView()
        container.backgroundColor = .appBackgroundColor
        return container
    }()

    lazy var headerView: UIView = {
        let headerView = UIView()
        headerView.backgroundColor = .white
        return headerView
    }()

    lazy var coughTestImageView: UIImageView = {
        let coughtestImageView = UIImageView(image: UIImage(named: "coughtestImage"))
        coughtestImageView.contentMode = .scaleAspectFit
        coughtestImageView.translatesAutoresizingMaskIntoConstraints = false
        return coughtestImageView
    }()
    
    lazy var headerLabel: UILabel = {
        let headerLabel  = UILabel(text: "title",
                                   font: UIFont(name: AppFontName.semibold, size: 24),
                                   textColor: .sectionHeaderColor,
                                   textAlignment: .center)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        return headerLabel
    }()
    
    lazy var headerDate: UILabel = {
        let headerdate  = UILabel(text: "",
                                  font: UIFont(name: AppFontName.light, size: 14.0),
                                  textColor: .sectionHeaderColor,
                                  textAlignment: .center)
        headerdate.translatesAutoresizingMaskIntoConstraints = false
        return headerdate
    }()

    lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel(text: "title", font: UIFont(name: AppFontName.regular, size: 20), textColor: .sectionHeaderColor, textAlignment: .left, numberOfLines: 0)
        descriptionLabel.sizeToFit()
        return descriptionLabel
    }()

    lazy var footerView:UIView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.backgroundColor = .white
        return uiView
    }()

    lazy var continueButton: CustomButtonFill = {
        let buttonView = CustomButtonFill()
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.setTitle("Begin", for: .normal)
        return buttonView
    }()
    
    init() {
        super.init(step: nil)
        self.isCoughTest = false
    }
    
    init(isCoughTest: Bool) {
        super.init(step: nil)
        self.isCoughTest = isCoughTest
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationItem.hidesBackButton = true
        
        presentViews()
        print("did load", self.view.frame.origin.y )
        self.initialYOrigin = self.view.frame.origin.y
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.addBottomRoundedEdge(desiredCurve: 0.5)
        
        self.footerView.layer.shadowColor = UIColor.black.cgColor
        self.footerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.footerView.layer.shadowRadius = 3.0
        self.footerView.layer.shadowOpacity = 0.14
        self.footerView.layer.masksToBounds = false
        self.footerView.layer.shadowPath = UIBezierPath(roundedRect: self.footerView.bounds,
                                                        cornerRadius: self.footerView.layer.cornerRadius).cgPath
    }

    func presentViews() {
        if let step = self.step as? ORKInstructionStep {
            descriptionLabel.text = step.text
        }

        self.view.addSubview(containerView)
        self.view.addSubview(headerView)
        self.view.addSubview(footerView)
        self.view.addSubview(coughTestImageView)
        footerView.addSubview(continueButton)
        let footerViewHeight = CGFloat(130)
        headerView.addSubview(headerLabel)
        headerView.addSubview(headerDate)
        containerView.addSubview(descriptionLabel)

        containerView.anchor(top: view.topAnchor, leading: view.leadingAnchor,
                             bottom: footerView.topAnchor, trailing: view.trailingAnchor)
        headerView.anchor(top: view.topAnchor, leading: view.leadingAnchor,
                          bottom: nil, trailing: view.trailingAnchor)
        headerView.anchor(.height(71.0))
        
        descriptionLabel.anchor(top: coughTestImageView.bottomAnchor,
                                leading: view.leadingAnchor,
                                bottom: nil,
                                trailing: view.trailingAnchor,
                                padding: .init(top: 21, left: 15, bottom: 0, right: 15))
        let descriptionLabelHeight:CGFloat = descriptionLabel.text?.height(withConstrainedWidth: view.frame.size.width - 30.0, font: descriptionLabel.font) ?? 0
        descriptionLabel.anchor(.height(descriptionLabelHeight))

        let imageHeight: CGFloat = self.isCoughTest ? 190.0 : 0.0
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor, constant: 15.0),
            headerLabel.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor, constant: -15.0),
            headerLabel.topAnchor.constraint(equalTo: self.headerView.topAnchor),
            headerDate.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor, constant: 15.0),
            headerDate.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor, constant: -15.0),
            headerDate.topAnchor.constraint(equalTo: self.headerLabel.bottomAnchor),
            headerDate.bottomAnchor.constraint(equalTo: self.headerView.bottomAnchor),
            coughTestImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            coughTestImageView.heightAnchor.constraint(equalToConstant: imageHeight),
            coughTestImageView.widthAnchor.constraint(equalTo: coughTestImageView.heightAnchor),
            coughTestImageView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12.0),
            footerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: footerViewHeight),
            continueButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 15),
            continueButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -15),
            continueButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 24),
            continueButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        continueButton.isEnabled = true
        continueButton.addTarget(self, action: #selector(handleContinue(sender:)), for: .touchUpInside)
        
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "EEE.MMM.dd"
        let dateString = dateformatter.string(from: Date())
        
        self.headerLabel.text = SurveyTaskUtility.shared.getCurrentSurveyName()
        self.headerDate.text = dateString
    }

    @objc func handleContinue(sender: UIButton) {
        if self.isCoughTest {
            let permission = AVAudioSession.sharedInstance().recordPermission
            switch permission {
            case .undetermined:
                    AVAudioSession.sharedInstance().requestRecordPermission() { [unowned self] allowed in
                     DispatchQueue.main.async {
                         if allowed {
                             self.goForward()
                         } else {
                             Alert(title: "Microphone Permission", message: "Microphone access is required to record the cough. Please allow in app settings", actions: UIAlertAction(title: "No Thanks", style: .destructive, handler: { (action) in

                             }), UIAlertAction(title: "Go to Settings", style: .default, handler: { (action) in
                                 if let settingsURL = URL(string: UIApplication.openSettingsURLString),
                                    UIApplication.shared.canOpenURL(settingsURL) {
                                     UIApplication.shared.openURL(settingsURL)
                                 }
                             }))
                         }
                     }
                 }
                break
            case .granted:
                self.goForward()
                break
            case .denied:
                Alert(title: "Microphone Permission", message: "Microphone access is required to record the cough. Please allow in app settings", actions: UIAlertAction(title: "No Thanks", style: .destructive, handler: { (action) in

                }), UIAlertAction(title: "Go to Settings", style: .default, handler: { (action) in
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString),
                       UIApplication.shared.canOpenURL(settingsURL) {
                        UIApplication.shared.openURL(settingsURL)
                    }
                }))
                break
            }
        } else {
            self.goForward()
        }
    }
}
