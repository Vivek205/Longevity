//
//  CheckInTitleView.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 06/09/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CheckInTitleView: UIView {
    
    lazy var bgImageView: UIImageView = {
        let bgImage = UIImageView()
        bgImage.image = UIImage(named: "home-bg")
        bgImage.contentMode = .scaleAspectFill
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()
    
    lazy var closeButton: UIButton = {
        let close = UIButton()
        close.setImage(UIImage(named: "closex")?.withRenderingMode(.alwaysTemplate), for: .normal)
        close.setImage(UIImage(named: "closex")?.withRenderingMode(.alwaysTemplate), for: .highlighted)
        close.tintColor = .white
        close.translatesAutoresizingMaskIntoConstraints = false
        return close
    }()
    
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.font = UIFont(name: "Montserrat-SemiBold", size: 24.0)
        title.textColor = .white
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    init() {
        super.init(frame: CGRect.zero)

        self.addSubview(bgImageView)
        self.addSubview(titleLabel)
        self.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            bgImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bgImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bgImageView.topAnchor.constraint(equalTo: self.topAnchor),
            bgImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10.0),
            closeButton.widthAnchor.constraint(equalToConstant: 30.0),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
            closeButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20.0),
            closeButton.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor)
        ])
        
        self.closeButton.tintColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.masksToBounds = true
    }
}
