//
//  RKCFormTextAnswerView.swift
//  Longevity
//
//  Created by vivek on 18/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

protocol RKCFormTextAnswerViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView)
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    func textViewDidChange(_ textView: UITextView)
    func textViewDidEndEditing(_ textView: UITextView)
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool
}
/// Default implementation of optional methods
extension RKCFormTextAnswerViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {}
}

class RKCFormTextAnswerView: UICollectionViewCell {
    var itemIdentifier:String?
    var delegate: RKCFormTextAnswerViewDelegate?
    
    lazy var questionLabel: UILabel  = {
        let label = UILabel()
        label.textColor = .sectionHeaderColor
        label.font = UIFont(name: AppFontName.medium, size: 18)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var keyboardToolbar:UIToolbar = {
        let toolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        let doneBarButton = UIBarButtonItem(title: "done", style: .plain, target: self,
                                            action: #selector(handleKeyboardDoneBarButtonTapped(_:)))
        toolbar.items = [doneBarButton]
        toolbar.sizeToFit()
        return toolbar
    }()
    
    lazy var answerTextView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        var idenitifier: String?
        textView.layer.cornerRadius = 16.5
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.inputAccessoryView = self.keyboardToolbar
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.borderColor.cgColor
        return textView
    }()

    lazy var clearButton: UIButton = {
        let button = UIButton(title: "Clear", target: self, action: #selector(handleClear(_:)))
        button.isHidden = true
        button.setTitleColor(.themeColor, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func createLayout(identifier:String, question:String, lastResponseAnswer:String?) {
        self.itemIdentifier = identifier
        self.addSubview(questionLabel)
        self.addSubview(answerTextView)
        self.addSubview(clearButton)
        
        questionLabel.text = question
        if let lastResponseAnswer = lastResponseAnswer {
            answerTextView.text = lastResponseAnswer
            answerTextView.layer.borderColor = UIColor.themeColor.cgColor
            clearButton.isHidden = false
        }

        if let localSavedAnswer = SurveyTaskUtility.shared.getCurrentSurveyLocalAnswer(questionIdentifier: identifier){
            answerTextView.text = localSavedAnswer
            answerTextView.layer.borderColor = UIColor.themeColor.cgColor
            clearButton.isHidden = false
        }
        
        NSLayoutConstraint.activate([
            questionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            questionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            questionLabel.topAnchor.constraint(equalTo: self.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            answerTextView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            answerTextView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            answerTextView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor),
//            answerTextView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            answerTextView.heightAnchor.constraint(equalToConstant: 100)
        ])

        clearButton.anchor(top: answerTextView.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 8, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 24))
    }

    @objc func handleKeyboardDoneBarButtonTapped(_ sender: Any) {
        self.answerTextView.resignFirstResponder()
    }

    @objc func handleClear(_ sender: Any) {
        self.answerTextView.text = ""
        self.answerTextView.layer.borderColor = UIColor.borderColor.cgColor
        guard let identifier = self.itemIdentifier else { return }
        SurveyTaskUtility.shared.setCurrentSurveyLocalAnswer(questionIdentifier: identifier, answer: "")
    }
}

extension RKCFormTextAnswerView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.themeColor.cgColor
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.hasText {
            textView.layer.borderColor = UIColor.themeColor.cgColor
        } else {
            textView.layer.borderColor = UIColor.borderColor.cgColor
        }
        delegate?.textViewDidEndEditing(textView)
    }

    func textViewDidChange(_ textView: UITextView) {
        delegate?.textViewDidChange(textView)

        if textView.hasText {
            clearButton.isHidden = false
        }else {
            clearButton.isHidden = true
        }

        guard let identifier = self.itemIdentifier else { return }
        SurveyTaskUtility.shared.setCurrentSurveyLocalAnswer(questionIdentifier: identifier, answer: textView.text)

    }
    func textViewDidChangeSelection(_ textView: UITextView) {
        print("changed selection")
        
    }



    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        delegate?.textViewShouldBeginEditing(textView)
        return true
    }


    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        delegate?.textView(textView, shouldChangeTextIn: range, replacementText: text)
        return true
    }

}
