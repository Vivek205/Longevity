//
//  DashboardCheckInCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 09/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

fileprivate let dateFormat = "yyyy-MM-dd HH:mm:ss"

enum CheckInStatus: String, Decodable {
    case notstarted = "NOT_SUBMITTED"
    case completedToday = "COMPLETED_TODAY"
    case completed = "PROCESSED"
    case pending = "PENDING"
}

extension CheckInStatus {
    func statusTitle(lastSubmissionDateString: String?) -> String? {
        switch self {
        case .notstarted:
            return "Get started today"
        case .completed:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateFormat
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            if let lastSubmissionDate = dateFormatter.date(from: lastSubmissionDateString ?? "") {
                let timeAgo = lastSubmissionDate.timeAgoDisplay()
                return "Last tracked: \(timeAgo)"
            }
            return ""
        default:
            return nil
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
        case .pending:
            return UIImage(named: "checkinpending")
        }
    }
    
    func titleText(surveyName: String) -> String {
        switch self {
        case .notstarted:
            return surveyName
        case .completedToday:
            return "View Today’s Results"
        case .completed:
            return surveyName
        case .pending:
            return "Processing…"
        }
    }
    
    var titleColor: UIColor {
        switch self {
        case .pending:
            return .checkinpending
        default:
            return .themeColor
        }
    }
    
    var subtitleText: String {
        switch self {
        case .completedToday:
            return "You can view results here or in your Check-in Log"
        case .pending:
            return "Your check-in results will be avaliable soon"
        default:
            return "How are you feeling today?"
        }
    }
    
    var subtitleColor: UIColor {
        switch self {
        case .completedToday:
            return .statusColor
        case .pending:
            return .statusColor
        default:
            return .checkinCompleted
        }
    }
    
    var subtitleFont: UIFont {
        switch self {
        case .completedToday:
            return UIFont(name: AppFontName.regular, size: 16.0)!
        case .pending:
            return UIFont(name: AppFontName.regular, size: 16.0)!
        default:
            return UIFont(name: AppFontName.semibold, size: 16.0)!
        }
    }
}

class DashboardCheckInCell: UICollectionViewCell {
    var surveyId: String?
    var submissionID: String?

    var status: CheckInStatus = .notstarted
    var isSurveySubmittedToday:Bool = false
    
    var surveyResponse: SurveyListItem! {
        didSet {
            self.isSurveySubmittedToday = checkIsSurveySubmittedToday(lastSubmissionDate: surveyResponse.lastSubmission)
            self.status = surveyResponse.lastSurveyStatus

            if surveyResponse.lastSurveyStatus != .pending &&
                surveyResponse.lastSurveyStatus != .notstarted {
                if self.isSurveySubmittedToday {
                    status = .completedToday
                } else {
                    status = .completed
                }
            }
            self.setupCell(title: surveyResponse.name, lastSubmissionDateString:surveyResponse.lastSubmission,
                           noOfTimesSurveyTaken: surveyResponse.noOfTimesSurveyTaken)
            self.surveyId = surveyResponse.surveyId
            self.submissionID = surveyResponse.lastSubmissionId
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
        title.numberOfLines = 0
        title.lineBreakMode = .byWordWrapping
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    lazy var bgView: UIView = {
        let bgview = UIView()
        bgview.backgroundColor = .white
        bgview.translatesAutoresizingMaskIntoConstraints = false
        return bgview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.contentView.addSubview(checkInIcon)
        self.contentView.addSubview(checkInTitle)
        
        NSLayoutConstraint.activate([
            checkInIcon.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10.0),
            checkInIcon.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10.0),
            checkInIcon.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10.0),
            checkInIcon.widthAnchor.constraint(equalTo: checkInIcon.heightAnchor),
            checkInTitle.leadingAnchor.constraint(equalTo: checkInIcon.trailingAnchor, constant: 10.0),
            checkInTitle.topAnchor.constraint(equalTo: checkInIcon.topAnchor),
            checkInTitle.bottomAnchor.constraint(equalTo: checkInIcon.bottomAnchor),
            checkInTitle.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10.0)
        ])
        
        self.setupCell(title: "COVID Check-in", lastSubmissionDateString: nil, noOfTimesSurveyTaken: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(title: String, lastSubmissionDateString: String?, noOfTimesSurveyTaken: Int?) {
        self.checkInIcon.image = status.statusIcon
        
        let checkinTitle = "\(status.titleText(surveyName: title))\n"
        
        let titlefont = UIFont(name: AppFontName.medium, size: 20.0)!
        let paragraphStyle1 = NSMutableParagraphStyle()
        paragraphStyle1.lineSpacing = 5
        let attributes: [NSAttributedString.Key: Any] = [.font: titlefont,
                                                         .foregroundColor: status.titleColor,
                                                         .paragraphStyle: paragraphStyle1]
        let attributedcheckinTitle = NSMutableAttributedString(string: checkinTitle, attributes: attributes)
        
        let checkinSubTitle = status.subtitleText
        let paragraphStyle2 = NSMutableParagraphStyle()
        paragraphStyle2.lineSpacing = 5
        let subTitleAttributes: [NSAttributedString.Key: Any] = [.font: status.subtitleFont,
                                                                 .foregroundColor: status.subtitleColor,
                                                                 .paragraphStyle: paragraphStyle2]
        let attributedcheckinSubTitle = NSMutableAttributedString(string: checkinSubTitle,
                                                                  attributes: subTitleAttributes)
        attributedcheckinTitle.append(attributedcheckinSubTitle)
        
        if status == .notstarted || status == .completed {
            if let statusText = status.statusTitle(lastSubmissionDateString: lastSubmissionDateString) {
                let statusFont = UIFont(name: AppFontName.regular, size: 14.0)!
                let paragraphStyle3 = NSMutableParagraphStyle()
                paragraphStyle3.lineSpacing = 2.5
                let statusTextAttributes: [NSAttributedString.Key: Any] =
                    [.font: statusFont,
                     .foregroundColor: UIColor.statusColor,
                     .paragraphStyle: paragraphStyle3]
                let attributedstatusText = NSMutableAttributedString(string: "\n\(statusText)",
                                                                     attributes: statusTextAttributes)
                attributedcheckinTitle.append(attributedstatusText)
            }
        }
        
        self.checkInTitle.attributedText = attributedcheckinTitle
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = 5.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.cornerRadius = 5.0
        layer.shadowRadius = 1.0
        layer.shadowOpacity = 0.25
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }

    func checkIsSurveySubmittedToday(lastSubmissionDate: String?) -> Bool {
        guard let lastSubmission = surveyResponse.lastSubmission,
              !lastSubmission.isEmpty else {
            return false
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        var calendar = Calendar.current
        if let lastSubmissionDate = dateFormatter.date(from: lastSubmission),
           let timezone = TimeZone(abbreviation: "UTC"){
            calendar.timeZone = timezone
            if calendar.isDateInToday(lastSubmissionDate) {
                return true
            }
        }
        return false
    }
}
