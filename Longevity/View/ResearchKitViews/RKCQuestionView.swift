//
//  RKCQuestionView.swift
//  Longevity
//
//  Created by vivek on 23/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation

class RKCQuestionView: UICollectionReusableView {

    let headerLabel: UILabel = {
        let labelView = QuestionHeaderLabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.textAlignment = .center
        labelView.numberOfLines = 0
        labelView.lineBreakMode = .byWordWrapping
        return labelView
    }()


    let questionLabel: UILabel = {
        let labelView = QuestionQuestionLabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.textAlignment = .center
        labelView.numberOfLines = 0
        labelView.lineBreakMode = .byWordWrapping
        return labelView
    }()

    let extraInfoLabel: UILabel = {
        let labelView = QuestionExtraInfoLabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.textAlignment = .center
        labelView.numberOfLines = 0
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
            headerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            headerLabel.topAnchor.constraint(equalTo: self.topAnchor)
        ])

        self.addSubview(questionLabel)

        NSLayoutConstraint.activate([
            questionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            questionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            questionLabel.topAnchor.constraint(equalTo:headerLabel.bottomAnchor)
        ])

        let bottomAnchorQuestionLabel = questionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30)

        self.addSubview(extraInfoLabel)
        NSLayoutConstraint.activate([
            extraInfoLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            extraInfoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            extraInfoLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor),
            extraInfoLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30)
        ])
    }


    func createLayout(header: String, question:String, extraInfo: String?) {

        headerLabel.text = SurveyTaskUtility.shared.getCurrentSurveyName()
        questionLabel.text = question

        print("self.bounds.size.width",self.bounds.size.width)
        print("self.bounds.size.width",self.frame.size.width)

        let headerLabelHeight: CGFloat = headerLabel.text?.height(withConstrainedWidth: self.bounds.size.width, font: headerLabel.font) ?? 0
        let questionLabelHeight: CGFloat = question.height(withConstrainedWidth: self.bounds.size.width, font: questionLabel.font) ?? 0

        headerLabel.anchor(.height(headerLabelHeight))
        questionLabel.anchor(.height(questionLabelHeight))

        if extraInfo != nil {
            extraInfoLabel.text = extraInfo
            extraInfoLabel.isHidden = false
        } else {
            extraInfoLabel.isHidden = true
        }

    }
}
