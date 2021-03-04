//
//  CoughTestResultHeader.swift
//  COVID Signals
//
//  Created by Jagan Kumar Mudila on 03/03/2021.
//  Copyright © 2021 vivek. All rights reserved.
//

import UIKit

class CoughTestResultHeader: UICollectionReusableView {
    
    var completionDate: String! {
        didSet {
            if let datestring = completionDate, !datestring.isEmpty {
                let recoredDate = DateUtility.getString(from: datestring, toFormat: "EEE.MMM.dd | hh:mm a")
                self.titleLabel.text = "Completed \(recoredDate)"
            }
        }
    }
    
    lazy var bgImageView: UIImageView = {
        let bgImage = UIImageView()
        bgImage.image = UIImage(named: "home-bg")
        bgImage.contentMode = .scaleAspectFill
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()
    
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.font = UIFont(name: AppFontName.medium, size: 14.0)
        title.numberOfLines = 0
        title.textColor = .white
        title.textAlignment = .center
        title.lineBreakMode = .byWordWrapping
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(bgImageView)
        self.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            bgImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bgImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bgImageView.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 100.0),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50.0),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50.0),
            titleLabel.heightAnchor.constraint(equalToConstant: 45.0),
            titleLabel.bottomAnchor.constraint(equalTo: bgImageView.bottomAnchor, constant: -10.0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgImageView.addBottomRoundedEdge(desiredCurve: 3.0)
        self.bgImageView.clipsToBounds = true
    }
}

