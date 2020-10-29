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
//        let subheader = SurveyTaskUtility.shared.surveyTagline
        let questionStep = self.step as? ORKQuestionStep
        let question = questionStep?.question
        questionView.createLayout(header: "", question: question ?? "", extraInfo: nil)
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
        buttonView.setTitle("Continue", for: .normal)
        return buttonView
    }()

    lazy var answerTextView: UITextView  = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.layer.cornerRadius = 16.5
        textView.layer.borderColor = UIColor.borderColor.cgColor
        textView.layer.borderWidth = 1
        textView.text = "Type here"
        textView.textColor = .placeHolder
        textView.font = UIFont(name: AppFontName.regular, size: 18)
        let toolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "done", style: .plain, target: self, action: #selector(handleTextViewDone(sender:)))
        ]
        toolbar.sizeToFit()
        textView.inputAccessoryView = toolbar
        return textView
    }()

    lazy var clearButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Clear", for: .normal)
        button.layer.borderColor = UIColor.clear.cgColor
        button.addTarget(self, action: #selector(handleClear(sender:)), for: .touchUpInside)
        button.setTitleColor(.themeColor, for: .normal)
        button.titleLabel?.font = UIFont(name: AppFontName.regular, size: 20)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setKeyboardTypeOfTextView()
        self.presentViews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.answerTextView.contentInset = .init(top: 0, left: 14, bottom: 0, right: 14)
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
//            let questionSubheader = SurveyTaskUtility.shared.surveyTagline ?? ""
//            questionViewHeight += questionSubheader.height(withConstrainedWidth: self.view.bounds.width - 40 ,
//                                                           font: questionView.subHeaderLabel.font)
            questionViewHeight += step.question!.height(withConstrainedWidth: self.view.bounds.width - 40,
                                                        font: questionView.questionLabel.font)
            if let extraInfo = step.text {
                questionViewHeight += extraInfo.height(withConstrainedWidth: self.view.bounds.width - 40,
                                                       font: questionView.extraInfoLabel.font)
            }
            // INSETS
            questionViewHeight += 30.0
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


        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        self.view.addGestureRecognizer(tapGesture)
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

    @objc func closeKeyboard() {
        answerTextView.resignFirstResponder()
    }

    @objc func handleTextViewDone(sender: Any) {
        print("textView done")
        closeKeyboard()
        guard let identifier = step?.identifier else {return}
        SurveyTaskUtility.shared.saveCurrentSurveyAnswerLocally(questionIdentifier: identifier,
                                                                answer: answerTextView.text)
        continueButton.isEnabled = true
    }

    @objc func handleClear(sender: Any) {
        continueButton.isEnabled = false
        answerTextView.text = "Type here"
        answerTextView.textColor = .placeHolder
        answerTextView.layer.borderColor = UIColor.borderColor.cgColor
    }

}

extension TextAnswerVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeHolder {
            textView.text = nil
            textView.textColor = .black
            textView.layer.borderColor = UIColor.themeColor.cgColor
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Type here"
            textView.textColor = .placeHolder
            textView.layer.borderColor = UIColor.borderColor.cgColor
        }
    }
}
