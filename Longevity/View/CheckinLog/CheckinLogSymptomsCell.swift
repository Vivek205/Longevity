//
//  CheckinLogSymptomsCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 15/09/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CheckinLogSymptomsCell: UITableViewCell {
    
    var symptom: String! {
        didSet {
            self.symptomLabel.text = symptom
        }
    }
    
    lazy var symptomLabel: UILabel = {
        let symptomLabel = UILabel()
        symptomLabel.font = UIFont(name: "Montserrat-Regular", size: 18.0)
        symptomLabel.numberOfLines = 0
        symptomLabel.textColor = UIColor(hexString: "#4E4E4E")
        symptomLabel.translatesAutoresizingMaskIntoConstraints = false
        return symptomLabel
    }()
    
    lazy var checkImage: UIImageView = {
        let checkImage = UIImageView()
        checkImage.image = UIImage(named: "icon: checkbox-selected")
        checkImage.contentMode = .scaleAspectFit
        checkImage.translatesAutoresizingMaskIntoConstraints = false
        return checkImage
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white
        
        addSubview(symptomLabel)
        addSubview(checkImage)
        NSLayoutConstraint.activate([
            symptomLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14.0),
            symptomLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5.0),
            symptomLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5.0),
            checkImage.leadingAnchor.constraint(greaterThanOrEqualTo: symptomLabel.trailingAnchor, constant: 10.0),
            checkImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14.0),
            checkImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkImage.widthAnchor.constraint(equalToConstant: 24.0),
            checkImage.heightAnchor.constraint(equalTo: checkImage.widthAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
