//
//  CheckinLogHeader.swift
//  Longevity
//
//  Created by vivek on 27/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CheckinLogHeader: UICollectionReusableView {

    lazy var segmentedControl: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["List", "Calendar"])
        if #available(iOS 13.0, *) {
            segment.selectedSegmentTintColor = .themeColor
        } else {
            segment.tintColor = .themeColor
        }

        let titleAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: "Montserrat-Regular", size: 14.0)]
        segment.setTitleTextAttributes(titleAttributes, for: .normal)
        let selectedTitleAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "Montserrat-Regular", size: 14.0)]
        segment.setTitleTextAttributes(selectedTitleAttributes, for: .selected)
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()
    
    lazy var symptomsCircle: UIView = {
        let symptomsView = UIView()
        symptomsView.backgroundColor = UIColor(hexString: "#E1D46A")
        symptomsView.translatesAutoresizingMaskIntoConstraints = false
        return symptomsView
    }()
    
    lazy var symptomsLabel: UILabel = {
        let symptomslabel = UILabel()
        symptomslabel.text = "Symptoms"
        symptomslabel.font = UIFont(name: "Montserrat-Regular", size: 14.0)
        symptomslabel.textColor = UIColor(hexString: "#9B9B9B")
        symptomslabel.translatesAutoresizingMaskIntoConstraints = false
        return symptomslabel
    }()
    
    lazy var nosymptomsCircle: UIView = {
        let nosymptomsView = UIView()
        nosymptomsView.backgroundColor = UIColor(hexString: "#6C8CBF")
        nosymptomsView.translatesAutoresizingMaskIntoConstraints = false
        return nosymptomsView
    }()
    
    lazy var nosymptomsLabel: UILabel = {
        let nosymptomslabel = UILabel()
        nosymptomslabel.text = "No Symptoms"
        nosymptomslabel.font = UIFont(name: "Montserrat-Regular", size: 14.0)
        nosymptomslabel.textColor = UIColor(hexString: "#9B9B9B")
        nosymptomslabel.translatesAutoresizingMaskIntoConstraints = false
        return nosymptomslabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(segmentedControl)
        segmentedControl.selectedSegmentIndex = 0
        let stackview = UIStackView(arrangedSubviews: [symptomsCircle, symptomsLabel, nosymptomsCircle, nosymptomsLabel])
        stackview.axis = .horizontal
        stackview.distribution = .fillProportionally
        stackview.alignment = .fill
        stackview.spacing = 10.0
        stackview.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackview)
        
        NSLayoutConstraint.activate([
//            segmentedControl.centerXAnchor.constraint(equalTo: centerXAnchor),
//            segmentedControl.topAnchor.constraint(equalTo: topAnchor, constant: 80.0),
            symptomsCircle.widthAnchor.constraint(equalToConstant: 18.0),
            symptomsCircle.heightAnchor.constraint(equalTo: symptomsCircle.widthAnchor),
            nosymptomsCircle.widthAnchor.constraint(equalToConstant: 18.0),
            nosymptomsCircle.heightAnchor.constraint(equalTo: nosymptomsCircle.widthAnchor),
            stackview.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackview.topAnchor.constraint(equalTo: topAnchor, constant: 80.0)
        ])
        
        self.symptomsCircle.layer.cornerRadius = 9.0
        self.symptomsCircle.layer.masksToBounds = true
        self.nosymptomsCircle.layer.cornerRadius = 9.0
        self.nosymptomsCircle.layer.masksToBounds = true

        self.segmentedControl.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
