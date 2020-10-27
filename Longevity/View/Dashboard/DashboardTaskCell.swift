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
                }else {
                    self.setDefaultProgressBar()
                }
            }
            taskTitle.text = surveyDetails?.name
            taskDescription.text = surveyDetails?.description
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
        title.font = UIFont(name: "Montserrat-Medium", size: 20.0)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()

    lazy var taskDescription: UILabel = {
        let taskdesc = UILabel()
        taskdesc.font = UIFont(name: "Montserrat-Regular", size: 14.0)
        taskdesc.textColor = .checkinCompleted
        taskdesc.numberOfLines = 2
        taskdesc.lineBreakMode = .byTruncatingTail
        taskdesc.translatesAutoresizingMaskIntoConstraints = false
        return taskdesc
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
        bgView.addSubview(taskDescription)
        bgView.addSubview(progressLabel)
        bgView.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
            bgView.topAnchor.constraint(equalTo: topAnchor, constant: 10.0),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0),
            taskIcon.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 10.0),
            taskIcon.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 10.0),
            taskIcon.heightAnchor.constraint(equalToConstant: 52.0),
            taskIcon.widthAnchor.constraint(equalTo: taskIcon.heightAnchor),
            taskTitle.leadingAnchor.constraint(equalTo: taskIcon.trailingAnchor, constant: 10.0),
            taskTitle.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -10.0),
            taskTitle.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 10.0),
            taskDescription.leadingAnchor.constraint(equalTo: taskTitle.leadingAnchor),
            taskDescription.trailingAnchor.constraint(equalTo: taskTitle.trailingAnchor),
            taskDescription.topAnchor.constraint(equalTo: taskTitle.bottomAnchor, constant: 10.0),
            progressLabel.leadingAnchor.constraint(equalTo: taskIcon.leadingAnchor),
            progressLabel.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -10.0),
            progressLabel.trailingAnchor.constraint(equalTo: taskIcon.trailingAnchor),
            progressBar.leadingAnchor.constraint(equalTo: taskDescription.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: taskDescription.trailingAnchor),
            progressBar.centerYAnchor.constraint(equalTo: progressLabel.centerYAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 4.0),
            taskDescription.bottomAnchor.constraint(lessThanOrEqualTo: progressBar.topAnchor, constant: 10.0)
        ])
        self.setupCell()
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell() {
        self.taskIcon.image = UIImage(named: "task1")
        self.taskTitle.text = "Lvl 2 Survey Name"
        self.taskDescription.text = "Subtext explaining what/ why/ how this survey will help"
        self.setDefaultProgressBar()
    }

    func setDefaultProgressBar() {
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
