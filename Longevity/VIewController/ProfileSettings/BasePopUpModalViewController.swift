//
//  BasePopUpModalViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 27/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class BasePopUpModalViewController: UIViewController {
    lazy var backdrop: UIView = {
        let backdropView = UIView()
        backdropView.translatesAutoresizingMaskIntoConstraints = false
        backdropView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return backdropView
    }()

    var showBackdrop: Bool = false {
        didSet {
            self.backdrop.isHidden = !self.showBackdrop
        }
    }
    
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
        title.text = ""
        title.font = UIFont(name: "Montserrat-Medium", size: 24.0)
        title.textAlignment = .center
        title.sizeToFit()
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    lazy var infoLabel: UILabel = {
        let info = UILabel()
        info.numberOfLines = 0
        info.lineBreakMode = .byWordWrapping
        info.translatesAutoresizingMaskIntoConstraints = false
        info.sizeToFit()
        return info
    }()
    
    lazy var actionButton: UIButton = {
        let export = UIButton()
        export.setTitle("Export Now", for: .normal)
        export.setTitleColor(.white, for: .normal)
        export.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 24.0)
        export.backgroundColor = .themeColor
        export.translatesAutoresizingMaskIntoConstraints = false
        export.addTarget(self, action: #selector(primaryButtonPressed(_:)), for: .touchUpInside)
        return export
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        
        self.view.addSubview(containerView)
        self.containerView.addSubview(closeButton)
        self.containerView.addSubview(titleLabel)
        self.containerView.addSubview(infoLabel)
        self.view.addSubview(backdrop)
        
        NSLayoutConstraint.activate([
            backdrop.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backdrop.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backdrop.topAnchor.constraint(equalTo: view.topAnchor),
            backdrop.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20.0),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20.0),
//            containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor),
            containerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            
            closeButton.widthAnchor.constraint(equalToConstant: 25),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20.0),
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20.0),
            
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20.0),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20.0),
            titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            
            infoLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18.0),
            infoLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18.0),
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24.0),
        ])
        
//        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(closeView))
//        tapgesture.numberOfTouchesRequired = 1
//
        self.view.sendSubviewToBack(backdrop)
    }
    
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.actionButton.layer.cornerRadius = 10.0
        self.actionButton.layer.masksToBounds = true
        
        self.containerView.layer.cornerRadius = 10.0
        self.containerView.layer.masksToBounds = true
        
//        UIView.animate(withDuration: 0.5) {
//            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.50)
//        }
    }

    @objc func primaryButtonPressed(_ sender: UIButton) {

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIView.animate(withDuration: 0.1) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        }
    }
}

