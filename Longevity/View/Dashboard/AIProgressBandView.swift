//
//  AIProgressBandView.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 10/11/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class AIProgressBandView: UIView {
    
    lazy var processingImage: UIImageView = {
        let processingImage = UIImageView(image: UIImage(named: "hourglass"))
        processingImage.contentMode = .scaleAspectFit
        processingImage.translatesAutoresizingMaskIntoConstraints = false
        return processingImage
    }()
    
    lazy var processingLabel: UILabel = {
        let processingLabel = UILabel(text: "AI processing your updates…", font: UIFont(name: "Montserrat-Regular", size: 14.2), textColor: .black, textAlignment: .left, numberOfLines: 0)
        processingLabel.sizeToFit()
        processingLabel.translatesAutoresizingMaskIntoConstraints = false
        return processingLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(hexString: "#FDF3E5")
        self.addSubview(processingImage)
        self.addSubview(processingLabel)
        
        NSLayoutConstraint.activate([
            processingLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            processingLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            processingImage.trailingAnchor.constraint(equalTo: processingLabel.leadingAnchor, constant: -8.0),
            processingImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 8.0),
            processingImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8.0),
            processingImage.widthAnchor.constraint(equalTo: processingImage.heightAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.25
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 0.0).cgPath
    }
}
