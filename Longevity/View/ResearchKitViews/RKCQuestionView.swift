//
//  RKCQuestionView.swift
//  Longevity
//
//  Created by vivek on 23/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation

class RKCQuestionView: UICollectionReusableView {

    var questionText: String = ""
    
    lazy var headerAttributedString: NSMutableAttributedString = {
        let surveyName = SurveyTaskUtility.shared.getCurrentSurveyName() ?? ""
        let textColor = UIColor(hexString: "#4E4E4E")
        
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.semibold, size: 24.0), .foregroundColor: textColor]
        let attributedoptionData = NSMutableAttributedString(string: surveyName, attributes: attributes)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.8
        attributedoptionData.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedoptionData.length))

        let extraInfoAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.regular, size: 14.0)]

        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "EEE.MMM.dd"
        let surveyDate = dateformatter.string(from: Date())

        let extraInfoAttributedText = NSMutableAttributedString(string: "\n\(surveyDate)", attributes: extraInfoAttributes)

        attributedoptionData.append(extraInfoAttributedText)

        let questionAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.regular, size: 24.0)]
        let attributedquestionText = NSMutableAttributedString(string: "\n\n\(questionText)", attributes: questionAttributes)

        let paragraphStyle2 = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2.4
        attributedquestionText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedquestionText.length))

        attributedoptionData.append(attributedquestionText)
        attributedoptionData.addAttribute(NSAttributedString.Key.kern, value: CGFloat(0.4), range: NSRange(location: 0, length: attributedoptionData.length))
        
        
        let alignParagraphStyle = NSMutableParagraphStyle()
        alignParagraphStyle.alignment = .center
        
        attributedoptionData.addAttribute(NSAttributedString.Key.paragraphStyle, value: alignParagraphStyle, range: NSRange(location: 0, length: attributedoptionData.length))
        return attributedoptionData
    }()
    
    lazy var headerLabel: UILabel = {
        let labelView = UILabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.textAlignment = .center
        labelView.numberOfLines = 0
        labelView.lineBreakMode = .byWordWrapping
        return labelView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initalizeLabels()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init() {
        super.init(frame: CGRect.zero)
        initalizeLabels()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.addBottomRoundedEdge(desiredCurve: 0.5)
    }


    func initalizeLabels() {
        backgroundColor = .white

        self.addSubview(headerLabel)

        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15.0),
            headerLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15.0),
            headerLabel.topAnchor.constraint(equalTo: self.topAnchor),
            headerLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20.0)
        ])
    }
    
    func createLayout(question:String) {
        self.questionText = question
        self.headerLabel.attributedText = self.headerAttributedString
    }
}
