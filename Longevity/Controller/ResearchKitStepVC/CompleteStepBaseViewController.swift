//
//  CompleteStepBaseViewController.swift
//  COVID Signals
//
//  Created by Jagan Kumar Mudila on 03/03/2021.
//  Copyright © 2021 vivek. All rights reserved.
//

import UIKit
import ResearchKit

class CompleteStepBaseViewController: ORKStepViewController {
    var currentSurveyId: String?
    var currentSurveyName: String?
    var isCurrentSurveyRepetitive: Bool?
    
    lazy var iconView:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "SetupComplete")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: AppFontName.regular, size: 20.0)
        label.textColor = UIColor(hexString: "#4E4E4E")
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var footerView:UIView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.backgroundColor = .clear
        return uiView
    }()
    
    lazy var primaryActionButton: CustomButtonFill = {
        let buttonView = CustomButtonFill()
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.setTitle("Done", for: .normal)
        return buttonView
    }()
    
    lazy var secondaryActionButton: UIButton = {
        let nextsurvey = UIButton()
        nextsurvey.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 24.0)
        nextsurvey.translatesAutoresizingMaskIntoConstraints = false
        return nextsurvey
    }()
    
    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .appBackgroundColor
        self.backButtonItem = nil
        
        self.currentSurveyId = SurveyTaskUtility.shared.currentSurveyId
        self.currentSurveyName = SurveyTaskUtility.shared.getCurrentSurveyName()
        self.isCurrentSurveyRepetitive = SurveyTaskUtility.shared.isCurrentSurveyRepetitive()
        self.navigationItem.hidesBackButton = true
        
        self.presentViews()
        
        SurveyTaskUtility.shared.setStatus(surveyId: self.currentSurveyId!)
        
        self.secondaryActionButton.disableSecondaryButton()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "closex"),
                                                                 style: .plain, target: self, action: #selector(handleContinue(sender:)))
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor(hexString: "#4E4E4E"),
                              .font: UIFont(name: AppFontName.semibold, size: 22.0)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes as [NSAttributedString.Key : Any]
        self.navigationController?.navigationBar.barTintColor = .appBackgroundColor
    }
    
    func isDateToday(date: String?) -> Bool {
        guard let date = date else {return false}
        let dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // referring to the timezon of the date provided for comparision
        var calendar = Calendar.current
        if let lastSubmissionDate = dateFormatter.date(from: date)
        {
            calendar.timeZone = .current // referring to the local timezone to be checked against
            if calendar.isDateInToday(lastSubmissionDate) {
                return true
            }
        }
        return false
    }
    
    func completeSurvey(completion: @escaping () -> Void, onFailure: @escaping (_ error: Error) -> Void) {
        DispatchQueue.main.async {
            self.showSpinner()
        }
        SurveyTaskUtility.shared.completeSurvey(completion: completion, onFailure: onFailure)
    }
    
    func presentViews() {
        
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(iconView)
        self.scrollView.addSubview(infoLabel)
        self.scrollView.addSubview(footerView)
        self.footerView.addSubview(primaryActionButton)
        self.footerView.addSubview(secondaryActionButton)
        
        let bottomMargin: CGFloat = UIDevice.hasNotch ? -54.0 : -30.0
         
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 10),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor,constant: 10),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -10),
            
            iconView.topAnchor.constraint(equalTo: self.scrollView.topAnchor, constant: 24.0),
            iconView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            iconView.heightAnchor.constraint(equalToConstant: 200.0),
            iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor),
            
            infoLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 24.0),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15.0),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0),
            infoLabel.bottomAnchor.constraint(greaterThanOrEqualTo: footerView.topAnchor, constant: 20.0),
            
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor),
            footerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            primaryActionButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 15),
            primaryActionButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -15),
            primaryActionButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 60),
            primaryActionButton.heightAnchor.constraint(equalToConstant: 48),
            secondaryActionButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 15),
            secondaryActionButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -15),
            secondaryActionButton.topAnchor.constraint(equalTo: primaryActionButton.bottomAnchor, constant: 24),
            secondaryActionButton.heightAnchor.constraint(equalToConstant: 48),
            secondaryActionButton.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: bottomMargin)
        ])
        primaryActionButton.isEnabled = true
    }
    
    @objc func handleContinue(sender: UIButton) {
        self.goForward()
    }
}
