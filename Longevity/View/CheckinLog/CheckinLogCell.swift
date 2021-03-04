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
            
            if !history.recordDate.isEmpty {
                let toformat = self.history.surveyID == Strings.coughTest ? "EEE | MMM dd, yyyy | hh:mm a" : "EEE | MMM dd, yyyy"
                let recoredDate = DateUtility.getString(from: history.recordDate, toFormat: toformat)
                self.logDate.text = recoredDate
            }
            
            self.logName.text = self.history.surveyName ?? "COVID Check-in"
            if self.history.surveyID == Strings.covidCheckIn || self.history.surveyID == Strings.coughTest {
                symptomsLabel.isHidden = true
                noofSymptoms.isHidden = true
                symptomsCircle.isHidden = true
                logIcon.isHidden = false
                if self.history.surveyID == Strings.coughTest {
                    if self.history.result != .healthy {
                        logIcon.image = UIImage(named: "cough-positive")
                    } else {
                        logIcon.image = UIImage(named: "cough-negative")
                    }
                } else {
                    logIcon.image = UIImage(named: "logIcon:COVID Risk Assessment")
                }
            } else {
                symptomsLabel.isHidden = false
                noofSymptoms.isHidden = false
                symptomsCircle.isHidden = false
                logIcon.isHidden = true
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
        noofsymptoms.font = UIFont(name: AppFontName.semibold, size: 24.0)
        noofsymptoms.textColor = .white
        noofsymptoms.text = ""
        noofsymptoms.textAlignment = .center
        noofsymptoms.translatesAutoresizingMaskIntoConstraints = false
        return noofsymptoms
    }()
    
    lazy var symptomsLabel: UILabel = {
        let symptomslabel = UILabel()
        symptomslabel.text = "Symptoms"
        symptomslabel.textAlignment = .center
        symptomslabel.font = UIFont(name: AppFontName.regular, size: 10.0)
        symptomslabel.textColor = UIColor(hexString: "#9B9B9B")
        symptomslabel.translatesAutoresizingMaskIntoConstraints = false
        return symptomslabel
    }()
    
    lazy var logName: UILabel = {
        let date = UILabel(text: "Name", font: UIFont(name: AppFontName.medium, size: 20.0),
                           textColor: UIColor.black.withAlphaComponent(0.87),
                           textAlignment: .left, numberOfLines: 1)
        date.translatesAutoresizingMaskIntoConstraints = false
        return date
    }()
    
    lazy var logDate: UILabel = {
        let viewdetails = UILabel()
        viewdetails.text = "View Details"
        viewdetails.textColor = .checkinCompleted
        viewdetails.font = UIFont(name: AppFontName.regular, size: 16.0)
        viewdetails.translatesAutoresizingMaskIntoConstraints = false
        return viewdetails
    }()

    lazy var logIcon: UIImageView = {
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = UIImage(named: "logIcon:COVID Risk Assessment")
        return icon
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        self.contentView.addSubview(symptomsCircle)
        self.symptomsCircle.addSubview(noofSymptoms)
        self.contentView.addSubview(symptomsLabel)
        self.contentView.addSubview(logName)
        self.contentView.addSubview(logDate)
        self.contentView.addSubview(logIcon)
        
        NSLayoutConstraint.activate([
            symptomsCircle.topAnchor.constraint(equalTo: topAnchor, constant: 15.0),
            symptomsCircle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15.0),
            symptomsCircle.heightAnchor.constraint(equalToConstant: 46.0),
            symptomsCircle.widthAnchor.constraint(equalTo: symptomsCircle.heightAnchor),
            noofSymptoms.centerXAnchor.constraint(equalTo: symptomsCircle.centerXAnchor),
            noofSymptoms.centerYAnchor.constraint(equalTo: symptomsCircle.centerYAnchor),
            symptomsLabel.topAnchor.constraint(equalTo: symptomsCircle.bottomAnchor, constant: 3.0),
            symptomsLabel.centerXAnchor.constraint(equalTo: symptomsCircle.centerXAnchor),
            logName.leadingAnchor.constraint(equalTo: symptomsCircle.trailingAnchor, constant: 20.0),
            logName.topAnchor.constraint(equalTo: topAnchor, constant: 15.0),
            logName.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
            logDate.leadingAnchor.constraint(equalTo: logName.leadingAnchor),
            logDate.topAnchor.constraint(equalTo: logName.bottomAnchor, constant: 12.0),
            logIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15.0),
            logIcon.widthAnchor.constraint(equalToConstant: 57.0),
            logIcon.heightAnchor.constraint(equalToConstant: 52.0),
            logIcon.topAnchor.constraint(equalTo: topAnchor, constant: 15.0)
        ])

        logIcon.isHidden = true
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
        detailsViewController.logItem = self.history
        NavigationUtility.presentOverCurrentContext(destination: detailsViewController, style: .overCurrentContext, transitionStyle: .crossDissolve)
    }
}
