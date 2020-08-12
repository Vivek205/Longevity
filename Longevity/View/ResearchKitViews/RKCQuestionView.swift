//
//  RKCQuestionView.swift
//  Longevity
//
//  Created by vivek on 23/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation

class RKCQuestionView: UICollectionViewCell {

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
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }


    func createLayout(header: String, subHeader: String, question:String, extraInfo: String?) {
        self.addBottomRoundedEdge(desiredCurve: 0.5)
        backgroundColor = .white

        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: self.topAnchor),
        ])

        headerLabel.text = header
        headerView.addSubview(headerLabel)

        NSLayoutConstraint.activate([
            headerLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor),
            headerLabel.rightAnchor.constraint(equalTo: headerView.rightAnchor),
            headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
        ])


        subHeaderLabel.text = subHeader
        headerView.addSubview(subHeaderLabel)

        NSLayoutConstraint.activate([
            subHeaderLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor),
            subHeaderLabel.rightAnchor.constraint(equalTo: headerView.rightAnchor),
            subHeaderLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor),
            subHeaderLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])

        questionLabel.text = question
        self.addSubview(questionLabel)

        NSLayoutConstraint.activate([
            questionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            questionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            questionLabel.topAnchor.constraint(equalTo:headerView.bottomAnchor)
        ])

        let bottomAnchorQuestionLabel = questionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30)

        if extraInfo != nil {
            extraInfoLabel.text = extraInfo
            self.addSubview(extraInfoLabel)
            NSLayoutConstraint.activate([
                extraInfoLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                extraInfoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                extraInfoLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor),
                extraInfoLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30)
            ])
        } else {
            bottomAnchorQuestionLabel.isActive = true
        }

    }
}
