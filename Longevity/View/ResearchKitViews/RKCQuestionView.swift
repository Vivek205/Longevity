//
//  RKCQuestionView.swift
//  Longevity
//
//  Created by vivek on 23/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation

class RKCQuestionView: UIView {
    var header: String?
    var subHeader: String?
    var question: String?
    var extraInfo: String?

    private let headerLabel: UILabel = {
        let labelView = QuestionHeaderLabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.textAlignment = .center
        return labelView
    }()

    private let subHeaderLabel: UILabel = {
        let labelView = QuestionSubheaderLabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.textAlignment = .center
        return labelView
    }()

    private let questionLabel: UILabel = {
        let labelView = QuestionQuestionLabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.textAlignment = .center
        labelView.numberOfLines = 2
        return labelView
    }()

    private let extraInfoLabel: UILabel = {
        let labelView = QuestionExtraInfoLabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.textAlignment = .center
        labelView.numberOfLines = 2
        return labelView
    }()

    init(header: String, subHeader: String, question:String?, extraInfo: String?) {
        self.header = header
        self.subHeader = subHeader
        self.question = question
        self.extraInfo = extraInfo
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
        self.createLayout()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        createLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createLayout()
    }

    func createLayout() {
        print("self.header", self.header)
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 20.0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(stackView)




        if header != nil && subHeader != nil {
            let headerView = UIView()
            headerView.translatesAutoresizingMaskIntoConstraints = false

            headerLabel.text = header
            headerView.addSubview(headerLabel)

            headerLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor).isActive = true
            headerLabel.rightAnchor.constraint(equalTo: headerView.rightAnchor).isActive = true
            headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
            if let headerHeight = header?.height(
                withConstrainedWidth: headerView.bounds.width,
                font: headerLabel.font) {
                headerLabel.heightAnchor.constraint(equalToConstant: headerHeight).isActive = true
            }

            subHeaderLabel.text = subHeader
            headerView.addSubview(subHeaderLabel)

            subHeaderLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor).isActive = true
            subHeaderLabel.rightAnchor.constraint(equalTo: headerView.rightAnchor).isActive = true
            subHeaderLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor).isActive = true
            if let subheaderHeight = subHeader?.height(
                withConstrainedWidth: headerView.bounds.width,
                font: subHeaderLabel.font) {
                subHeaderLabel.heightAnchor.constraint(equalToConstant: subheaderHeight).isActive = true
            }

            stackView.addArrangedSubview(headerView)
        }

        if question != nil {
            questionLabel.text = question
            stackView.addArrangedSubview(questionLabel)
            if let questionLabelHeight = question?.height(
                withConstrainedWidth: stackView.bounds.width,
                font: questionLabel.font) {
                questionLabel.heightAnchor.constraint(equalToConstant: questionLabelHeight)
            }

        }
        if extraInfo != nil {
            extraInfoLabel.text = extraInfo
            stackView.addArrangedSubview(extraInfoLabel)
        }

        stackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

    }


    
}
