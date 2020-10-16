//
//  CheckinLogCell.swift
//  Longevity
//
//  Created by vivek on 27/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CheckinLogCell: UICollectionViewCell {

    var history: History! {
        didSet {
           let symptomsCount = history.symptoms.count
            if symptomsCount > 0 {
                self.symptomsCircle.backgroundColor = UIColor(hexString: "#E1D46A")
            } else {
                self.symptomsCircle.backgroundColor = UIColor(hexString: "#6C8CBF")
            }
            self.noofSymptoms.text = "\(symptomsCount)"
            
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd"
            if let date = dateformatter.date(from: history.recordDate) {
                dateformatter.dateFormat = "EEE | MMM dd, yyyy"
                self.logDate.text = dateformatter.string(from: date)
            }
        }
    }
    
    lazy var symptomsCircle: UIView = {
        let symptomsView = UIView()
        symptomsView.backgroundColor = UIColor(hexString: "#E1D46A")
        symptomsView.translatesAutoresizingMaskIntoConstraints = false
        return symptomsView
    }()
    
    lazy var noofSymptoms: UILabel = {
        let noofsymptoms = UILabel()
        noofsymptoms.font = UIFont(name: "Montserrat-SemiBold", size: 24.0)
        noofsymptoms.textColor = .white
        noofsymptoms.text = "99"
        noofsymptoms.textAlignment = .center
        noofsymptoms.translatesAutoresizingMaskIntoConstraints = false
        return noofsymptoms
    }()
    
    lazy var symptomsLabel: UILabel = {
        let symptomslabel = UILabel()
        symptomslabel.text = "Symptoms"
        symptomslabel.textAlignment = .center
        symptomslabel.font = UIFont(name: "Montserrat-Regular", size: 10.0)
        symptomslabel.textColor = UIColor(hexString: "#9B9B9B")
        symptomslabel.translatesAutoresizingMaskIntoConstraints = false
        return symptomslabel
    }()
    
    lazy var logDate: UILabel = {
        let date = UILabel()
        date.font = UIFont(name: "Montserrat-Medium", size: 20.0)
        date.textColor = UIColor.black.withAlphaComponent(0.87)
        date.translatesAutoresizingMaskIntoConstraints = false
        return date
    }()
    
    lazy var viewDetailsLabel: UILabel = {
        let viewdetails = UILabel()
        viewdetails.text = "View Details"
        viewdetails.textColor = UIColor(hexString: "#5AA7A7")
        viewdetails.font = UIFont(name: "Montserrat-Medium", size: 16.0)
        viewdetails.translatesAutoresizingMaskIntoConstraints = false
        return viewdetails
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        self.contentView.addSubview(symptomsCircle)
        self.symptomsCircle.addSubview(noofSymptoms)
        self.contentView.addSubview(symptomsLabel)
        self.contentView.addSubview(logDate)
        self.contentView.addSubview(viewDetailsLabel)
        
        NSLayoutConstraint.activate([
            symptomsCircle.topAnchor.constraint(equalTo: topAnchor, constant: 15.0),
            symptomsCircle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.0),
            symptomsCircle.heightAnchor.constraint(equalToConstant: 46.0),
            symptomsCircle.widthAnchor.constraint(equalTo: symptomsCircle.heightAnchor),
            noofSymptoms.centerXAnchor.constraint(equalTo: symptomsCircle.centerXAnchor),
            noofSymptoms.centerYAnchor.constraint(equalTo: symptomsCircle.centerYAnchor),
            symptomsLabel.topAnchor.constraint(equalTo: symptomsCircle.bottomAnchor, constant: 3.0),
            symptomsLabel.centerXAnchor.constraint(equalTo: symptomsCircle.centerXAnchor),
            logDate.leadingAnchor.constraint(equalTo: symptomsCircle.trailingAnchor, constant: 20.0),
            logDate.topAnchor.constraint(equalTo: topAnchor, constant: 15.0),
            logDate.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
            viewDetailsLabel.leadingAnchor.constraint(equalTo: logDate.leadingAnchor),
            viewDetailsLabel.topAnchor.constraint(equalTo: logDate.bottomAnchor, constant: 12.0)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        contentView.layer.cornerRadius = 5.0
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.cornerRadius = 5.0
        layer.shadowRadius = 1.0
        layer.shadowOpacity = 0.25
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
        
        symptomsCircle.layer.cornerRadius = 23.0
        symptomsCircle.layer.masksToBounds = true
    }
    
    func onViewDetails() {
        let detailsViewController = CheckInLogDetailsViewController()
        detailsViewController.history = self.history
        NavigationUtility.presentOverCurrentContext(destination: detailsViewController, style: .overCurrentContext, transitionStyle: .crossDissolve)
    }
}
