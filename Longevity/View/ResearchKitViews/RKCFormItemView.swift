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
        label.textColor = .sectionHeaderColor
        label.font = UIFont(name: AppFontName.medium, size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
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
            if let serverAnswerToPreselect = lastResponseAnswer,
               let serverAnswerInt = Int(serverAnswerToPreselect) {
                booleanAnswerView.preSelectOption(answer: serverAnswerInt)
                if SurveyTaskUtility.shared.getCurrentSurveyLocalAnswer(questionIdentifier: identifier) == nil {
                    SurveyTaskUtility.shared.setCurrentSurveyLocalAnswer(questionIdentifier: identifier, answer: serverAnswerToPreselect)
                }
            }
            if let localAnswer = SurveyTaskUtility.shared.getCurrentSurveyLocalAnswer(questionIdentifier: identifier),
               let localAnswerInt = Int(localAnswer){
                booleanAnswerView.preSelectOption(answer: localAnswerInt)
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
                                            verticalLine.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 23.0),
                                            verticalLine.topAnchor.constraint(equalTo: self.topAnchor),
                                            verticalLine.bottomAnchor.constraint(equalTo: self.bottomAnchor)])
        } else {
            self.verticalLine.removeFromSuperview()
        }
    }
}

extension RKCFormItemView: RKCFormBooleanAnswerViewDelegate {
    func segmentedControl(wasChangedOnCell cell: RKCFormBooleanAnswerView) {
        if let identifier = self.itemIdentifier{
            let answer = cell.segmentedControl.selectedSegmentIndex == 0 ? "1" : "0"
            SurveyTaskUtility.shared.setCurrentSurveyLocalAnswer(questionIdentifier: identifier,
                                                          answer: answer)
        }
    }
}
