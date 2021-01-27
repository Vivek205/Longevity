//
//  CheckInResultHeader.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 06/09/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

protocol CheckInResultHeaderDelegate: class {
    func selected(resultView: CheckInResultView)
}

enum CheckInResultView: Int {
    case analysis =  0
    case insights
}

class CheckInResultHeader: UICollectionReusableView {
    
    weak var delegate: CheckInResultHeaderDelegate?
    
    var currentView: CheckInResultView! {
        didSet {
            self.segmentedControl.removeTarget(self, action: #selector(resultViewSelected), for: .allEvents)
            self.segmentedControl.selectedSegmentIndex = currentView.rawValue
            self.segmentedControl.addTarget(self, action: #selector(resultViewSelected), for: .valueChanged)
            self.headerTitle.isHidden = currentView == .analysis
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
    
    lazy var segmentedControl: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Risk Analysis", "Insights"])
        if #available(iOS 13.0, *) {
            segment.selectedSegmentTintColor = .themeColor
        } else {
            segment.tintColor = .themeColor
        }
        
        let titleAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: AppFontName.regular, size: 14.0)]
        segment.setTitleTextAttributes(titleAttributes, for: .normal)
        let selectedTitleAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: AppFontName.regular, size: 14.0)]
        segment.setTitleTextAttributes(selectedTitleAttributes, for: .selected)
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()
    
    lazy var headerTitle: UILabel = {
        let title = UILabel()
        title.text = "According to our analysis you should:"
        title.font = UIFont(name: AppFontName.medium, size: 14.0)
        title.textColor = UIColor(hexString: "#4E4E4E")
        title.sizeToFit()
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(bgImageView)
        self.addSubview(titleLabel)
        self.addSubview(segmentedControl)
        self.addSubview(headerTitle)
        
        NSLayoutConstraint.activate([
            bgImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bgImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bgImageView.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 100.0),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50.0),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50.0),
            titleLabel.heightAnchor.constraint(equalToConstant: 45.0),
            titleLabel.bottomAnchor.constraint(equalTo: bgImageView.bottomAnchor, constant: -10.0),
            segmentedControl.topAnchor.constraint(equalTo: bgImageView.bottomAnchor, constant: 20.0),
            segmentedControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 30.0),
            segmentedControl.widthAnchor.constraint(equalToConstant: 230.0),
            headerTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15.0),
            headerTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15.0),
            headerTitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(comletedDate: String, surveyName: String, isCheckIn: Bool) {
        if isCheckIn {
            self.titleLabel.text = "Completed \(comletedDate)"
        } else {
            self.titleLabel.text = "\(surveyName)\n completed \(comletedDate)"
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgImageView.addBottomRoundedEdge(desiredCurve: 3.0)
        self.bgImageView.clipsToBounds = true
    }
    
    @objc func resultViewSelected() {
        self.currentView = CheckInResultView(rawValue: self.segmentedControl.selectedSegmentIndex)
        self.delegate?.selected(resultView: self.currentView)
    }
}
