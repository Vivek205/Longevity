//
//  TextAnswerVC.swift
//  Longevity
//
//  Created by vivek on 27/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

class TextAnswerVC: ORKStepViewController {

    lazy var questionView:RKCQuestionView = {
        let questionView = RKCQuestionView()
        questionView.translatesAutoresizingMaskIntoConstraints = false
        let subheader = SurveyTaskUtility.shared.surveyTagline
        let questionStep = self.step as? ORKQuestionStep
        let question = questionStep?.question
        questionView.createLayout(header: "", subHeader: subheader ?? "",
                                  question: question ?? "", extraInfo: nil)
        return questionView
    }()

    lazy var footerView:UIView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.backgroundColor = .white
        return uiView
    }()

    lazy var continueButton: CustomButtonFill = {
        let buttonView = CustomButtonFill()
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.setTitle("Next", for: .normal)
        return buttonView
    }()

    lazy var answerTextView: UITextView  = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.layer.cornerRadius = 16.5

        let toolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "done", style: .plain, target: self, action: #selector(handleTextViewDone(sender:)))
        ]
        toolbar.sizeToFit()
        textView.inputAccessoryView = toolbar
        return textView
    }()

    lazy var clearButton: CustomButtonOutlined = {
        let button = CustomButtonOutlined()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("clear", for: .normal)
        button.layer.borderColor = UIColor.clear.cgColor
        button.addTarget(self, action: #selector(handleClear(sender:)), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setKeyboardTypeOfTextView()
        self.presentViews()
    }

    func presentViews() {
        self.view.addSubview(questionView)
        self.view.addSubview(answerTextView)
        self.view.addSubview(clearButton)
        self.view.addSubview(footerView)
        footerView.addSubview(continueButton)
        let footerViewHeight = CGFloat(130)
        let answerTextViewHeight = CGFloat(200)
        var questionViewHeight = CGFloat(0)

        if let step = self.step as? ORKQuestionStep {
            if let title = step.title {
                questionViewHeight += title.height(withConstrainedWidth: self.view.bounds.width - 40, font: questionView.headerLabel.font)
            }
            let questionSubheader = SurveyTaskUtility.shared.surveyTagline ?? ""
            questionViewHeight += questionSubheader.height(withConstrainedWidth: self.view.bounds.width - 40 ,
                                                           font: questionView.subHeaderLabel.font)
            questionViewHeight += step.question!.height(withConstrainedWidth: self.view.bounds.width - 40,
                                                        font: questionView.questionLabel.font)
            if let extraInfo = step.text {
                questionViewHeight += extraInfo.height(withConstrainedWidth: self.view.bounds.width - 40,
                                                       font: questionView.extraInfoLabel.font)
            }
            // INSETS
            questionViewHeight += 60.0
        }

        NSLayoutConstraint.activate([
            questionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            questionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            questionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            questionView.heightAnchor.constraint(equalToConstant: questionViewHeight),

            answerTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            answerTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            answerTextView.topAnchor.constraint(equalTo: questionView.bottomAnchor, constant: 20),
            answerTextView.heightAnchor.constraint(equalToConstant: answerTextViewHeight),

            clearButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            clearButton.topAnchor.constraint(equalTo: answerTextView.bottomAnchor, constant: 20),
            clearButton.heightAnchor.constraint(equalToConstant: 38),

            footerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: footerViewHeight),

            continueButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 15),
            continueButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -15),
            continueButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 24),
            continueButton.heightAnchor.constraint(equalToConstant: 48)
        ])

        continueButton.isEnabled = false
        continueButton.addTarget(self, action: #selector(handleContinue(sender:)), for: .touchUpInside)
    }

    func setKeyboardTypeOfTextView(){
        guard let identifier = step?.identifier else {return}
        guard let questionDetails = SurveyTaskUtility.shared.getCurrentSurveyQuestionDetails(questionId: identifier)
            else {return}
        switch questionDetails.quesType {
        case .text:
            guard let otherDetails = questionDetails.otherDetails else {return}
            self.answerTextView.keyboardType = otherDetails.TEXT?.type.keyboardType ?? .alphabet
            return
        default:
            return
        }

    }


    @objc func handleContinue(sender: UIButton) {
        self.goForward()
    }

    @objc func handleTextViewDone(sender: Any) {
        print("textView done")
        answerTextView.resignFirstResponder()
        guard let identifier = step?.identifier else {return}
        SurveyTaskUtility.shared.saveCurrentSurveyAnswerLocally(questionIdentifier: identifier,
                                                                answer: answerTextView.text)
        continueButton.isEnabled = true
    }

    @objc func handleClear(sender: Any) {
        answerTextView.text = nil
        continueButton.isEnabled = false
    }

}

extension TextAnswerVC: UITextViewDelegate {

}
