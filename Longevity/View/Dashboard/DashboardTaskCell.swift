//
//  DashboardTaskCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 10/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class DashboardTaskCell: UITableViewCell {

    var surveyDetails: SurveyListItem? {
        didSet {
            if let status = surveyDetails?.lastSurveyStatus, status == .pending {
                taskIcon.image = status.statusIcon
                self.setupCell(title: status.titleText, taskDescription: status.subtitleText)
                self.progressLabel.isHidden = true
                self.progressBar.isHidden = true
                
                NSLayoutConstraint.activate([
                    self.progressView.heightAnchor.constraint(equalToConstant: 0.0)
                ])
            } else {
                self.setupCell(title: surveyDetails?.name ?? "",
                               taskDescription: surveyDetails?.description.shortDescription ?? "")
                
                if let surveyId = surveyDetails?.surveyId {
                    taskIcon.image = UIImage(named: "icon: \(surveyId)")

                    if let details = SurveyTaskUtility.shared.surveyDetails[surveyId] as? SurveyDetails,
                       let questions = details.questions as? [Question],
                       let localAnswers = SurveyTaskUtility.shared.localSavedAnswers[surveyId] as? [String:String],
                       let traversedQuestions = SurveyTaskUtility.shared.traversedQuestions[surveyId],
                       var lastAnsweredQuestion = traversedQuestions.last
                    {
                        if localAnswers[lastAnsweredQuestion] == nil {
                            lastAnsweredQuestion = traversedQuestions[traversedQuestions.count - 2]
                        }

                        let lastAnsweredQuestionIndex = questions.firstIndex { (ques) -> Bool in
                            return ques.quesId == lastAnsweredQuestion
                        } ?? 0

                        let totalQuestions = Float(questions.count)
                        let answeredQuestions = Float(lastAnsweredQuestionIndex + 1)
                        let userProgress = answeredQuestions / totalQuestions
                        let userProgressPercent = String(format: "%.0f", userProgress * 100)
                        self.progressLabel.isHidden = false
                        self.progressLabel.text = "\(userProgressPercent) %"

                        self.progressBar.isHidden = false
                        self.progressBar.setProgress(userProgress, animated: true)
                    } else {
                        self.setDefaultProgressBar()
                    }
                }
                NSLayoutConstraint.activate([
                    self.progressView.heightAnchor.constraint(equalToConstant: 30.0)
                ])
            }
        }
    }
    
    lazy var taskIcon: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    
    lazy var taskTitle: UILabel = {
        let title = UILabel()
        title.numberOfLines = 0
        title.lineBreakMode = .byWordWrapping
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    lazy var progressLabel: UILabel = {
        let lastupdated = UILabel()
        lastupdated.textColor = UIColor(hexString: "#9B9B9B")
        lastupdated.font = UIFont(name: "Montserrat-Regular", size: 14.0)
        lastupdated.textAlignment = .center
        lastupdated.translatesAutoresizingMaskIntoConstraints = false
        return lastupdated
    }()
    
    lazy var progressBar: UIProgressView = {
        let progressbar = UIProgressView()
        progressbar.trackTintColor = .progressTrackColor
        progressbar.progressTintColor = .progressColor
        progressbar.translatesAutoresizingMaskIntoConstraints = false
        return progressbar
    }()
    
    lazy var progressView: UIView = {
        let progressview = UIView()
        progressview.backgroundColor = .clear
        progressview.translatesAutoresizingMaskIntoConstraints = false
        progressview.addSubview(progressLabel)
        progressview.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            progressLabel.leadingAnchor.constraint(equalTo: progressview.leadingAnchor, constant: 10.0),
            progressLabel.centerYAnchor.constraint(equalTo: progressview.centerYAnchor),
            progressLabel.widthAnchor.constraint(equalToConstant: 52.0),
            progressBar.leadingAnchor.constraint(equalTo: progressLabel.trailingAnchor, constant: 10.0),
            progressBar.trailingAnchor.constraint(equalTo: progressview.trailingAnchor, constant: -10.0),
            progressBar.centerYAnchor.constraint(equalTo: progressLabel.centerYAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 4.0)
        ])
        
        return progressview
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
        bgView.addSubview(taskIcon)
        bgView.addSubview(taskTitle)
        bgView.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
            bgView.topAnchor.constraint(equalTo: topAnchor, constant: 10.0),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0),
            taskIcon.centerYAnchor.constraint(equalTo: taskTitle.centerYAnchor),
            taskIcon.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 10.0),
            taskIcon.heightAnchor.constraint(equalToConstant: 52.0),
            taskIcon.widthAnchor.constraint(equalTo: taskIcon.heightAnchor),
            taskTitle.leadingAnchor.constraint(equalTo: taskIcon.trailingAnchor, constant: 10.0),
            taskTitle.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -10.0),
            taskTitle.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 10.0),
            taskTitle.bottomAnchor.constraint(equalTo: progressView.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor),
            progressView.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -10.0)
        ])
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupCell(title: String, taskDescription: String) {
        let titlefont = UIFont(name: "Montserrat-Medium", size: 20.0)!
        let paragraphStyle1 = NSMutableParagraphStyle()
        paragraphStyle1.lineSpacing = 5
        let attributes: [NSAttributedString.Key: Any] = [.font: titlefont,
                                                         .foregroundColor: UIColor.black.withAlphaComponent(0.87),
                                                         .paragraphStyle: paragraphStyle1]
        let attributedcheckinTitle = NSMutableAttributedString(string: "\(title)\n", attributes: attributes)
        
        let subtitlefont = UIFont(name: "Montserrat-Regular", size: 14.0)!
        let paragraphStyle2 = NSMutableParagraphStyle()
        paragraphStyle2.lineSpacing = 5
        let subTitleAttributes: [NSAttributedString.Key: Any] = [.font: subtitlefont,
                                                                 .foregroundColor: UIColor(hexString: "#4A4A4A"),
                                                                 .paragraphStyle: paragraphStyle2]
        let attributedcheckinSubTitle = NSMutableAttributedString(string: taskDescription,
                                                                  attributes: subTitleAttributes)
        attributedcheckinTitle.append(attributedcheckinSubTitle)
        
        self.taskTitle.attributedText = attributedcheckinTitle
        self.setDefaultProgressBar()
    }

    func setDefaultProgressBar() {
        self.progressLabel.isHidden = false
        self.progressBar.isHidden = false
        self.progressLabel.text = "0%"
        self.progressBar.setProgress(Float(0), animated: false)
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
        bgView.layer.shadowPath = UIBezierPath(roundedRect: bgView.bounds,
                                               cornerRadius: bgView.layer.cornerRadius).cgPath
    }
}
