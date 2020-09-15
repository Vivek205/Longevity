//
//  RecordedSymptomsCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 08/09/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class RecordedSymptomsCell: UICollectionViewCell {
    var symptoms:[String]? {
        didSet {
            self.detailsView.symptoms = symptoms
            if let count = symptoms?.count {
                 self.symptomsCount.text = "\(count)"
            }
        }
    }
    
    var isCellExpanded: Bool! {
        didSet {
            if isCellExpanded ?? false {
                expandCollapseImage.image = UIImage(named: "rightArrow")?.rotate(radians: .pi / 2)
            } else {
                expandCollapseImage.image = UIImage(named: "rightArrow")
            }
        }
    }
    
    lazy var expandCollapseImage: UIImageView = {
        let expandCollapse = UIImageView()
        expandCollapse.image = UIImage(named: "rightArrow")
        expandCollapse.contentMode = .scaleAspectFit
        expandCollapse.translatesAutoresizingMaskIntoConstraints = false
        return expandCollapse
    }()
    
    lazy var tileTitle: UILabel = {
        let title = UILabel()
        title.textAlignment = .left
        title.text = "Recorded Symptoms"
        title.font = UIFont(name: "Montserrat-SemiBold", size: 18)
        title.textColor = UIColor(hexString: "#4E4E4E")
        title.numberOfLines = 2
        title.lineBreakMode = .byWordWrapping
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    lazy var symptomsCount: UILabel = {
        let count = UILabel()
        count.textAlignment = .center
        count.font = UIFont(name: "Montserrat-SemiBold", size: 18)
        count.textColor = .themeColor
        count.numberOfLines = 2
        count.lineBreakMode = .byWordWrapping
        count.translatesAutoresizingMaskIntoConstraints = false
        return count
    }()
    
    lazy var detailsView: RecordedSymptomsDetailView = {
        let detailsview = RecordedSymptomsDetailView()
        detailsview.translatesAutoresizingMaskIntoConstraints = false
        return detailsview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        self.addSubview(expandCollapseImage)
        self.addSubview(tileTitle)
        self.addSubview(symptomsCount)
        self.addSubview(detailsView)
        
        NSLayoutConstraint.activate([
            self.expandCollapseImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
            self.expandCollapseImage.topAnchor.constraint(equalTo: topAnchor, constant: 10.0),
            self.expandCollapseImage.widthAnchor.constraint(equalToConstant: 20.0),
            self.expandCollapseImage.heightAnchor.constraint(equalTo: self.expandCollapseImage.widthAnchor),
            
            self.tileTitle.leadingAnchor.constraint(equalTo: self.expandCollapseImage.trailingAnchor, constant: 10.0),
            self.tileTitle.topAnchor.constraint(equalTo: self.expandCollapseImage.topAnchor),
            self.tileTitle.widthAnchor.constraint(equalToConstant: 110.0),
            
            self.symptomsCount.centerYAnchor.constraint(equalTo: self.tileTitle.centerYAnchor),
            self.symptomsCount.widthAnchor.constraint(equalToConstant: 80.0),
            self.symptomsCount.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -80.0),
            
            self.detailsView.topAnchor.constraint(equalTo: self.topAnchor, constant: 80.0),
            self.detailsView.leadingAnchor.constraint(equalTo: self.tileTitle.leadingAnchor),
            self.detailsView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.detailsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20.0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.cornerRadius = 5.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.borderColor.cgColor
        contentView.layer.masksToBounds = true
    }
}
