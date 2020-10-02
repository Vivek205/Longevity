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
        return labelView
    }()

    let subHeaderLabel: UILabel = {
        let labelView = QuestionSubheaderLabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.textAlignment = .center
        return labelView
    }()

    let questionLabel: UILabel = {
        let labelView = QuestionQuestionLabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.textAlignment = .center
        labelView.numberOfLines = 0
        return labelView
    }()

    let extraInfoLabel: UILabel = {
        let labelView = QuestionExtraInfoLabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.textAlignment = .center
        labelView.numberOfLines = 2
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

        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: self.topAnchor),
        ])

        //            headerLabel.text = header
        headerView.addSubview(headerLabel)

        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
        ])

        headerView.addSubview(subHeaderLabel)

        NSLayoutConstraint.activate([
            subHeaderLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            subHeaderLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            subHeaderLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor),
            subHeaderLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])

        self.addSubview(questionLabel)

        NSLayoutConstraint.activate([
            questionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            questionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            questionLabel.topAnchor.constraint(equalTo:headerView.bottomAnchor)
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


    func createLayout(header: String, subHeader: String, question:String, extraInfo: String?) {

        headerLabel.text = SurveyTaskUtility.shared.getCurrentSurveyName()

        subHeaderLabel.text = subHeader

        questionLabel.text = question

        if extraInfo != nil {
            extraInfoLabel.text = extraInfo
            extraInfoLabel.isHidden = false
        } else {
            extraInfoLabel.isHidden = true
        }

    }
}
