//
//  BasePopUpModalViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 27/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class BasePopUpModalViewController: UIViewController {
    
    private enum ModalDismissDirection {
        case upwards
        case downwards
    }

    var showBackdrop: Bool = false {
        didSet {
//            self.backdrop.isHidden = !self.showBackdrop
        }
    }
    
    private var dismissalDirection: ModalDismissDirection = .downwards
    
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
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20.0),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20.0),
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
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(closeView))
        tapgesture.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(tapgesture)
        containerView.center = CGPoint(x: self.view.center.x, y: self.view.center.y * 2)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged))
        containerView.addGestureRecognizer(gesture)
    }
    
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    
    @objc func wasDragged(sender: UIPanGestureRecognizer) {
        switch sender.state {
            case .changed:
                viewTranslation = sender.translation(in: view)
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.containerView.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
                })
            case .ended:
                if viewTranslation.y > -100 && viewTranslation.y < 200 {
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                        self.containerView.transform = .identity
                    })
                } else {
                    
                    if viewTranslation.y < 0 {
                        self.dismissalDirection = .upwards
                    } else {
                        self.dismissalDirection = .downwards
                    }
                    
                    dismiss(animated: true, completion: nil)
                }
            default:
                break
            }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.actionButton.layer.cornerRadius = 10.0
        self.actionButton.layer.masksToBounds = true
        
        self.containerView.layer.cornerRadius = 10.0
        self.containerView.layer.masksToBounds = true
    }

    @objc func primaryButtonPressed(_ sender: UIButton) {

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.50)
            self.containerView.center = self.view.center
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.50)
            if self.dismissalDirection == .downwards {
                self.containerView.center = CGPoint(x: self.view.center.x, y: self.view.center.y * 2)
            } else {
                self.containerView.center = CGPoint(x: self.view.center.x, y: -(self.view.center.y * 2))
            }
        }
    }
}
