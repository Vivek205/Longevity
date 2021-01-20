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
        bgImage.clipsToBounds = true
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()
    
    lazy var titleImageView: UIImageView = {
        let titleImage = UIImageView()
        titleImage.image = UIImage(named: "rejuveIconWBg")
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
        
        self.addSubview(bgImageView)
        self.addSubview(titleImageView)
        self.addSubview(titleLabel)
        
        let centerConstant: CGFloat = viewTab == .home ? 17.0 : 0.0
        
        NSLayoutConstraint.activate([
            bgImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bgImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bgImageView.topAnchor.constraint(equalTo: self.topAnchor),
            bgImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            titleImageView.heightAnchor.constraint(equalToConstant: 34.0),
            titleImageView.widthAnchor.constraint(equalTo: titleImageView.heightAnchor),
            titleImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10.0),
            titleImageView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -6.0),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: centerConstant),
            titleLabel.centerYAnchor.constraint(equalTo: titleImageView.centerYAnchor)
        ])
        
        if viewTab == .home {
            let covid = "COVID"
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Regular", size: 24.0)!,.foregroundColor: UIColor.white]
            let attributedTitle = NSMutableAttributedString(string: covid, attributes: attributes)
            
            let signals = " SIGNALS"
            let attributes2: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-SemiBold", size: 24.0)!,.foregroundColor: UIColor.white]
            let attributedTitle2 = NSMutableAttributedString(string: signals, attributes: attributes2)
            
            attributedTitle.append(attributedTitle2)
            self.titleLabel.attributedText = attributedTitle
        } else {
            self.titleLabel.text = self.viewTab?.tabViewTitle
        }
        
        self.titleImageView.isHidden = viewTab != .home
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
