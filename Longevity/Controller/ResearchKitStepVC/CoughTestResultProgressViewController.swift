//
//  CoughTestResultProgressViewController.swift
//  COVID Signals
//
//  Created by Jagan Kumar Mudila on 03/03/2021.
//  Copyright © 2021 vivek. All rights reserved.
//

import UIKit

protocol CoughTestResultCancelDelegate: class {
    func cancel()
}

class CoughTestResultProgressViewController: UIViewController {
    
    weak var delegate: CoughTestResultCancelDelegate?
    
    lazy var containerView: UIView = {
        let container = UIView()
        container.backgroundColor = .white
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.text = "Processing Results..."
        title.font = UIFont(name: AppFontName.medium, size: 24.0)
        title.textAlignment = .center
        title.sizeToFit()
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    lazy var spinnerControl: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.color = .gray
        spinner.startAnimating()
        spinner.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    lazy var infoLabel: UILabel = {
        let info = UILabel()
        info.text = "AI is processing your data and this may take a few seconds"
        info.textAlignment = .center
        info.font = UIFont(name: AppFontName.regular, size: 16.0)
        info.textColor = UIColor(hexString: "#4E4E4E")
        info.numberOfLines = 0
        info.lineBreakMode = .byWordWrapping
        info.translatesAutoresizingMaskIntoConstraints = false
        info.sizeToFit()
        return info
    }()
    
    lazy var actionButton: CustomButtonFill = {
        let export = CustomButtonFill()
        export.setTitle("Cancel", for: .normal)
        export.setTitleColor(.white, for: .normal)
        export.titleLabel?.font = UIFont(name: AppFontName.medium, size: 24.0)
        export.backgroundColor = .themeColor
        export.translatesAutoresizingMaskIntoConstraints = false
        export.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        return export
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        self.view.addSubview(containerView)
        self.containerView.addSubview(titleLabel)
        self.containerView.addSubview(spinnerControl)
        self.containerView.addSubview(infoLabel)
        self.containerView.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20.0),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20.0),
            containerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 18.0),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20.0),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20.0),
            spinnerControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24.0),
            spinnerControl.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
            spinnerControl.widthAnchor.constraint(equalToConstant: 48.0),
            spinnerControl.heightAnchor.constraint(equalTo: spinnerControl.widthAnchor),
            infoLabel.topAnchor.constraint(equalTo: spinnerControl.bottomAnchor, constant: 24.0),
            infoLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18.0),
            infoLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18.0),
            actionButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 24.0),
            actionButton.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 59.0),
            actionButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -59.0),
            actionButton.heightAnchor.constraint(equalToConstant: 48.0),
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24.0)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.containerView.layer.cornerRadius = 10.0
        self.containerView.layer.masksToBounds = true
    }
    
    @objc func closeView() {
        self.dismiss(animated: true) { [unowned self] in
            self.delegate?.cancel()
        }
    }
}
