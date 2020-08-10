//
//  TitleView.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 06/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class TitleView: UIView {
    
    var viewTab: RejuveTab?
    
    lazy var bgImageView: UIImageView = {
        let bgImage = UIImageView()
        bgImage.image = UIImage(named: "home-bg")
        bgImage.contentMode = .scaleAspectFill
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()
    
    lazy var titleImageView: UIImageView = {
        let titleImage = UIImageView()
        titleImage.image = UIImage(named: "home-title")
        titleImage.contentMode = .scaleAspectFit
        titleImage.translatesAutoresizingMaskIntoConstraints = false
        return titleImage
    }()
    
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.font = UIFont(name: "Montserrat-SemiBold", size: 24.0)
        title.textColor = .white
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    init(viewTab: RejuveTab) {
        super.init(frame: CGRect.zero)
        self.viewTab = viewTab
        
        let vTop: CGFloat = UIDevice.hasNotch ? 50.0 : 20.0
        
        self.addSubview(bgImageView)
        NSLayoutConstraint.activate([
            bgImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bgImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bgImageView.topAnchor.constraint(equalTo: self.topAnchor),
            bgImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        if viewTab == .home {
            self.addSubview(titleImageView)
            NSLayoutConstraint.activate([
                titleImageView.heightAnchor.constraint(equalToConstant: 34.0),
                titleImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                titleImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                titleImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: vTop),
                titleImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10.0)
            ])
        } else {
            self.addSubview(titleLabel)
            self.titleLabel.text = self.viewTab?.tabViewTitle
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: vTop),
                titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10.0)
            ])
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let vtab = self.viewTab, vtab != .home {
            self.addBottomRoundedEdge(desiredCurve: 3.0)
        }
        
        self.layer.masksToBounds = true
    }
}
