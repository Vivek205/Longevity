//
//  RKCFormItemView.swift
//  Longevity
//
//  Created by vivek on 11/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

class RKCFormItemView: UICollectionViewCell {
    var itemIdentifier: String?

    lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    lazy var placeholderButton: CustomButtonFill = {
        let button = CustomButtonFill()
        button.setTitle("placeholder", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createLayout(identifier:String, question:String, answerFormat: ORKAnswerFormat) {
        self.itemIdentifier = identifier
        print("answer format ------- ", answerFormat)
        var answerView:UIView
        switch answerFormat.questionType {
        case .boolean:
            let booleanAnswerView = RKCFormBooleanAnswerView()
            booleanAnswerView.createLayout(yesText: "yes", noText: "No")
            booleanAnswerView.delegate = self
            answerView = booleanAnswerView
        default:
            answerView = UIView()
            answerView.backgroundColor = .green
        }
        answerView.translatesAutoresizingMaskIntoConstraints = false

        self.backgroundColor = .white
        self.addSubview(questionLabel)
        self.addSubview(answerView)

        questionLabel.text = question
        NSLayoutConstraint.activate([
            questionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            questionLabel.trailingAnchor.constraint(equalTo: answerView.leadingAnchor),
            questionLabel.topAnchor.constraint(equalTo: self.topAnchor),
            questionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            answerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            answerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            answerView.heightAnchor.constraint(equalToConstant: 32),
            answerView.widthAnchor.constraint(equalToConstant: 113)
        ])

    }
}

extension RKCFormItemView: RKCFormBooleanAnswerViewDelegate {
    func segmentedControl(wasChangedOnCell cell: RKCFormBooleanAnswerView) {
        if self.itemIdentifier != nil {
            SurveyTaskUtility.currentSurveyResult[self.itemIdentifier!] = "\(cell.segmentedControl.selectedSegmentIndex)"
        }
    }
}
