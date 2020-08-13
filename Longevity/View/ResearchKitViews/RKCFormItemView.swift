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
        label.textColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createLayout(identifier:String, question:String, answerFormat: ORKAnswerFormat, lastResponseAnswer: String?) {
        self.itemIdentifier = identifier
        print("answer format ------- ", answerFormat)
        var answerView:UIView
        switch answerFormat.questionType {
        case .boolean:
            let booleanAnswerView = RKCFormBooleanAnswerView()
            booleanAnswerView.createLayout(yesText: "yes", noText: "No")
            booleanAnswerView.delegate = self

            if lastResponseAnswer != nil {
                booleanAnswerView.preSelectOption(index: Int(lastResponseAnswer!)!)
            }

            if self.itemIdentifier != nil && SurveyTaskUtility.currentSurveyResult[self.itemIdentifier!] != nil{
                let currentResultSelectedSegmentIndex =
                    Int(SurveyTaskUtility.currentSurveyResult[self.itemIdentifier!]!)
                booleanAnswerView.preSelectOption(index: currentResultSelectedSegmentIndex!)
            }
            answerView = booleanAnswerView
        default:
            answerView = UIView()
            answerView.backgroundColor = .green
        }
        answerView.translatesAutoresizingMaskIntoConstraints = false

        self.backgroundColor = .clear
        self.addSubview(questionLabel)
        self.addSubview(answerView)

        questionLabel.text = question
        NSLayoutConstraint.activate([
            questionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 60),
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
