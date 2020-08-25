//
//  ExportCheckinDataViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 20/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class ExportCheckinDataViewController: UIViewController {
    
    lazy var blurBackGround: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        return visualEffectView
    }()
    
    lazy var closeButton: UIButton = {
        let close = UIButton()
        close.setImage(UIImage(named: "closex"), for: .normal)
        close.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        close.translatesAutoresizingMaskIntoConstraints = false
        return close
    }()
    
    lazy var containerView: UIView = {
        let container = UIView()
        container.backgroundColor = .white
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.text = "Check-in Data"
        title.font = UIFont(name: "Montserrat-Medium", size: 24.0)
        title.textAlignment = .center
        title.sizeToFit()
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    lazy var infoLabel: UILabel = {
        let info = UILabel()
        info.text = "Your data will be formatted as a PDF and sent to your email address here:\n\ngreg.kuebler@singularitynet.io"
        info.numberOfLines = 0
        info.lineBreakMode = .byWordWrapping
        info.font = UIFont(name: "Montserrat-Regular", size: 16.0)
        info.textColor = UIColor(hexString: "#4E4E4E")
        info.translatesAutoresizingMaskIntoConstraints = false
        info.sizeToFit()
        return info
    }()
    
    lazy var exportButton: UIButton = {
        let export = UIButton()
        export.setTitle("Export Now", for: .normal)
        export.setTitleColor(.white, for: .normal)
        export.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 24.0)
        export.backgroundColor = .themeColor
        export.translatesAutoresizingMaskIntoConstraints = false
        return export
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        self.view.addSubview(containerView)
        self.containerView.addSubview(closeButton)
        self.containerView.addSubview(titleLabel)
        self.containerView.addSubview(infoLabel)
        self.containerView.addSubview(exportButton)
        
        NSLayoutConstraint.activate([
            
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20.0),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20.0),
            containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor),
            containerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            
            closeButton.widthAnchor.constraint(equalToConstant: 25),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20.0),
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20.0),
            
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20.0),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20.0),
            titleLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 5.0),
            
            infoLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18.0),
            infoLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18.0),
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24.0),
            
            exportButton.topAnchor.constraint(greaterThanOrEqualTo: infoLabel.bottomAnchor, constant: 20.0),
            exportButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 60.0),
            exportButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -60.0),
            exportButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -45.0)
        ])
    }
    
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.exportButton.layer.cornerRadius = 10.0
        self.exportButton.layer.masksToBounds = true
        
        self.containerView.layer.cornerRadius = 10.0
        self.containerView.layer.masksToBounds = true
    }
}
