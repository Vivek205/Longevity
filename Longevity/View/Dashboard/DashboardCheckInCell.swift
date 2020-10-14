//
//  DashboardCheckInCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 09/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

fileprivate let dateFormat = "yyyy-MM-dd HH:mm:ss"

enum CheckInStatus: Int {
    case notstarted
    case completedToday
    case completed
}

extension CheckInStatus {
    func status(lastSubmissionDateString: String?, noOfTimesSurveyTaken: Int?) -> String {
        switch self {
        case .notstarted:
            return "Get started today"
        case .completedToday:
            guard let noOfTimesSurveyTaken = noOfTimesSurveyTaken else {return ""}
            return "\(noOfTimesSurveyTaken) days logged"
        case .completed:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateFormat
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            if let lastSubmissionDate = dateFormatter.date(from: lastSubmissionDateString ?? "") {
                let timeAgo = lastSubmissionDate.timeAgoDisplay()
                return "last tracked: \(timeAgo)"
            }
            return ""
        }
    }
    
    var statusIcon: UIImage? {
        switch self {
        case .notstarted:
            return UIImage(named: "checkinnotdone")
        case .completedToday:
            return UIImage(named: "checkindone")
        case .completed:
            return UIImage(named: "checkinnotdone")
        }
    }

    var titleText: String? {
        switch self {
        case .notstarted:
            return "COVID Check-in"
        case .completedToday:
            return "Check-in Complete"
        case .completed:
            return "COVID Check-in"
        }
    }
    
    var titleColor: UIColor {
        switch self {
        case .notstarted:
            return .checkinNotCompleted
        case .completedToday:
            return .checkinCompleted
        case .completed:
            return .checkinNotCompleted
        }
    }

    var subtitleText: String {
        switch self {
        case .notstarted:
            return "How are you feeling today?"
        case .completedToday:
            return "View your check-in log"
        case .completed:
            return "How are you feeling today?"
        }
    }

    var subtitleColor: UIColor {
        switch self {
        case .notstarted:
            return .checkinCompleted
        case .completedToday:
            return .checkinNotCompleted
        case .completed:
            return .checkinCompleted
        }
    }
}

class DashboardCheckInCell: UITableViewCell {
    var surveyId: String?

    var isRepetitiveSurveyList: Bool = false

    var status: CheckInStatus = .notstarted
    
    var surveyResponse: SurveyListItem! {
        didSet {
            if let lastSubmission = surveyResponse.lastSubmission, !lastSubmission.isEmpty {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = dateFormat
                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

                if let lastSubmissionDate = dateFormatter.date(from: lastSubmission){
                    var calendar = Calendar.current
                    calendar.timeZone = TimeZone(abbreviation: "UTC")!
                    if calendar.isDateInToday(lastSubmissionDate) {
                        status = .completedToday
                    } else {
                        status = .completed
                    }
                }
            }
            self.setupCell(title: surveyResponse.name, lastSubmissionDateString:surveyResponse.lastSubmission,
                           noOfTimesSurveyTaken: surveyResponse.noOfTimesSurveyTaken)
            self.surveyId = surveyResponse.surveyId
        }
    }
    
    lazy var checkInIcon: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    
    lazy var checkInTitle: UILabel = {
        let title = UILabel()
        title.font = UIFont(name: "Montserrat-Medium", size: 20.0)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    lazy var checkInTitle2: UILabel = {
        let title2 = UILabel()
        title2.font = UIFont(name: "Montserrat-SemiBold", size: 16.0)
        title2.translatesAutoresizingMaskIntoConstraints = false
        title2.textColor = .checkinCompleted
        return title2
    }()
    
    lazy var lastUpdated: UILabel = {
        let lastupdated = UILabel()
        lastupdated.font = UIFont(name: "Montserrat-Regular", size: 14.0)
        lastupdated.translatesAutoresizingMaskIntoConstraints = false
        return lastupdated
    }()
    
    lazy var verticleStack : UIStackView = {
        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.distribution = .equalSpacing
        vStack.alignment = .fill
        vStack.addArrangedSubview(checkInTitle)
        vStack.addArrangedSubview(checkInTitle2)
        vStack.addArrangedSubview(lastUpdated)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        return vStack
    }()
    
    lazy var bgView: UIView = {
        let bgview = UIView()
        bgview.backgroundColor = .white
        bgview.translatesAutoresizingMaskIntoConstraints = false
        return bgview
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        
        self.addSubview(bgView)
        bgView.addSubview(checkInIcon)
        bgView.addSubview(verticleStack)
        
        NSLayoutConstraint.activate([
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
            bgView.topAnchor.constraint(equalTo: topAnchor, constant: 10.0),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0),
            checkInIcon.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 10.0),
            checkInIcon.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -10.0),
            checkInIcon.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 10.0),
            checkInIcon.widthAnchor.constraint(equalTo: checkInIcon.heightAnchor),
            verticleStack.leadingAnchor.constraint(equalTo: checkInIcon.trailingAnchor, constant: 10.0),
            verticleStack.topAnchor.constraint(equalTo: checkInIcon.topAnchor),
            verticleStack.bottomAnchor.constraint(equalTo: checkInIcon.bottomAnchor),
            verticleStack.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -10.0)
        ])
        
        self.setupCell(title: "COVID Check-in", lastSubmissionDateString: nil, noOfTimesSurveyTaken: nil)
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(title: String, lastSubmissionDateString: String?, noOfTimesSurveyTaken: Int?) {
        self.checkInIcon.image = status.statusIcon
        self.checkInTitle.text = status.titleText
        self.checkInTitle.textColor = status.titleColor
        self.checkInTitle2.text = status.subtitleText
        self.checkInTitle2.textColor = status.subtitleColor
        self.checkInTitle2.font = UIFont(name: AppFontName.semibold, size: 16.0)
        self.lastUpdated.text = status.status(lastSubmissionDateString: lastSubmissionDateString,
                                              noOfTimesSurveyTaken: noOfTimesSurveyTaken)
        self.lastUpdated.textColor = .statusColor

        if status == .completedToday {
            self.checkInTitle2.font = UIFont(name: AppFontName.regular, size: 16.0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.layer.masksToBounds = true
        bgView.layer.shadowColor = UIColor.black.cgColor
        bgView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        bgView.layer.cornerRadius = 5.0
        bgView.layer.shadowRadius = 2.0
        bgView.layer.shadowOpacity = 0.25
        bgView.layer.masksToBounds = false
        bgView.layer.shadowPath = UIBezierPath(roundedRect: bgView.bounds, cornerRadius: bgView.layer.cornerRadius).cgPath
    }
}
