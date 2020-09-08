//
//  CheckInResultHeader.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 06/09/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CheckInResultHeader: UICollectionReusableView {
    lazy var bgImageView: UIImageView = {
        let bgImage = UIImageView()
        bgImage.image = UIImage(named: "home-bg")
        bgImage.contentMode = .scaleAspectFill
        bgImage.translatesAutoresizingMaskIntoConstraints = false
        return bgImage
    }()
    
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.font = UIFont(name: "Montserrat-Medium", size: 14.0)
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
            bgImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50.0),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50.0),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20.0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(comletedDate: String) {
        self.titleLabel.text = "Completed \(comletedDate)for \(AppSyncManager.instance.userProfile.value?.name ?? "")"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addBottomRoundedEdge(desiredCurve: 3.0)
        self.layer.masksToBounds = true
    }
}
