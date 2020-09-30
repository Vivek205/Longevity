//
//  BasePopupViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 13/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class BasePopupViewController: UIViewController {
    var viewTab: RejuveTab?
    
    let headerHeight = UIDevice.hasNotch ? 100.0 : 70.0
    
    lazy var blurBackGround: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        return visualEffectView
    }()
    
    lazy var containerView: UIView = {
        let container = UIView()
        container.backgroundColor = .white
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    lazy var closeButton: UIButton = {
        let close = UIButton()
        close.setTitle("Close", for: .normal)
        close.setTitleColor(.black, for: .normal)
        close.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        close.translatesAutoresizingMaskIntoConstraints = false
        return close
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        
//        self.view.addSubview(blurBackGround)
        self.view.addSubview(containerView)
        self.containerView.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            blurBackGround.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            blurBackGround.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            blurBackGround.topAnchor.constraint(equalTo: self.view.topAnchor),
            blurBackGround.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20.0),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20.0),
            containerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 40.0),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20.0),
            
            closeButton.widthAnchor.constraint(equalToConstant: 50.0),
            closeButton.heightAnchor.constraint(equalToConstant: 25.0),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20.0),
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20.0)
        ])
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(closeView))
        tapgesture.numberOfTouchesRequired = 1
        
        self.view.addGestureRecognizer(tapgesture)
    }
    
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        UIView.animate(withDuration: 1.0) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIView.animate(withDuration: 0.1) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        }
    }
}

