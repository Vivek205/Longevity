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
        guard let questionStep = self.step as? ORKQuestionStep,
              let question = questionStep.question else { return questionView }
        questionView.createLayout(question: question)
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

        if let step = self.step as? ORKQuestionStep,
           let surveyName = SurveyTaskUtility.shared.getCurrentSurveyName(),
           let question = step.question {
            questionView.createLayout(question: question)
            questionViewHeight += "\n\n\n\(surveyName)".height(withConstrainedWidth: self.view.bounds.width, font: questionView.headerLabel.font)
            questionViewHeight += "\n\(question)".height(withConstrainedWidth: self.view.bounds.width, font: UIFont(name: AppFontName.regular, size: 24.0) ?? .init())
        }
        
        if let step = self.step as? ORKFormStep {
            let questionCell = RKCQuestionView()
            
            let surveyName = SurveyTaskUtility.shared.getCurrentSurveyName() ?? ""
            let textColor = UIColor(hexString: "#4E4E4E")
            
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-SemiBold", size: 24.0), .foregroundColor: textColor]
            let attributedoptionData = NSMutableAttributedString(string: surveyName, attributes: attributes)
            
            let extraInfoAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Light", size: 14.0), .foregroundColor: textColor]
            
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "EEE.MMM.dd"
            let surveyDate = dateformatter.string(from: Date())
            
            let extraInfoAttributedText = NSMutableAttributedString(string: "\n\(surveyDate)", attributes: extraInfoAttributes)
            
            attributedoptionData.append(extraInfoAttributedText)
            
            let questionAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Regular", size: 24.0), .foregroundColor: textColor]
            let attributedquestionText = NSMutableAttributedString(string: self.step?.title ?? "", attributes: questionAttributes)
            
            attributedoptionData.append(attributedquestionText)
            attributedoptionData.addAttribute(NSAttributedString.Key.kern, value: CGFloat(0.4), range: NSRange(location: 0, length: attributedoptionData.length))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 1.8
            attributedoptionData.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedoptionData.length))
            
            
            let containerWidth = self.view.bounds.width - 40
            questionViewHeight = attributedoptionData.height(containerWidth: containerWidth) + 30.0
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
