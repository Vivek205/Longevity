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

    lazy var verticalLine: UIView = {
        let verticalLine = UIView()
        verticalLine.backgroundColor = UIColor(hexString: "#D6D6D6")
        verticalLine.translatesAutoresizingMaskIntoConstraints = false
        return verticalLine
    }()
    
    lazy var booleanAnswerView: RKCFormBooleanAnswerView = {
        let booleanView = RKCFormBooleanAnswerView()
        booleanView.createLayout(yesText: "Yes", noText: "No")
        booleanView.delegate = self
        return booleanView
    }()

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

    func createLayout(identifier:String, question:String, answerFormat: ORKAnswerFormat, lastResponseAnswer: String?, cellPosition: CellPosition) {
        self.itemIdentifier = identifier
        var answerView:UIView
        switch answerFormat.questionType {
        case .boolean:
            if let serverAnswerToPreselect = lastResponseAnswer {
                if let localAnswer = SurveyTaskUtility.shared.getCurrentSurveyLocalAnswer(questionIdentifier: identifier) {
                    let currentResultSelectedSegmentIndex = Int(localAnswer)
                    booleanAnswerView.preSelectOption(index: currentResultSelectedSegmentIndex!)
                } else {
                    SurveyTaskUtility.shared.setCurrentSurveyLocalAnswer(questionIdentifier: identifier, answer: serverAnswerToPreselect)
                    let currentResultSelectedSegmentIndex = Int(serverAnswerToPreselect)
                    booleanAnswerView.preSelectOption(index: currentResultSelectedSegmentIndex!)
                }
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
        
        if cellPosition != .none {
            self.addSubview(verticalLine)
            NSLayoutConstraint.activate([
                                            verticalLine.widthAnchor.constraint(equalToConstant: 1.5),
                                            verticalLine.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24.0),
                                            verticalLine.topAnchor.constraint(equalTo: self.topAnchor),
                                            verticalLine.bottomAnchor.constraint(equalTo: self.bottomAnchor)])
        }
    }
}

extension RKCFormItemView: RKCFormBooleanAnswerViewDelegate {
    func segmentedControl(wasChangedOnCell cell: RKCFormBooleanAnswerView) {
        if let identifier = self.itemIdentifier{
            SurveyTaskUtility.shared.setCurrentSurveyLocalAnswer(questionIdentifier: identifier,
                                                          answer: "\(cell.segmentedControl.selectedSegmentIndex)")
        }
    }
}
