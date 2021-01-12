//
//  RKCFormInlineTextAnswerView.swift
//  Longevity
//
//  Created by vivek on 20/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

protocol RKCFormInlineTextAnswerViewDelegate: class {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    func textViewDidChange(_ textView: UITextView)
    func textViewDidEndEditing(_ textView: UITextView)
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool
}

class RKCFormInlineTextAnswerView: UICollectionViewCell {
    weak var delegate: RKCFormInlineTextAnswerViewDelegate?
    var itemIdentifier: String?

    lazy var keyboardToolbar:UIToolbar = {
           let toolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
           let doneBarButton = UIBarButtonItem(title: "done", style: .plain, target: self,
                                               action: #selector(handleKeyboardDoneBarButtonTapped(_:)))
           toolbar.items = [doneBarButton]
           toolbar.sizeToFit()
           return toolbar
       }()

    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        var idenitifier: String?
        textView.layer.cornerRadius = 6.93
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.inputAccessoryView = self.keyboardToolbar
        return textView
    }()

    lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .sectionHeaderColor
        label.font = UIFont(name: AppFontName.medium, size: 18)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createLayout(identifier:String, question:String, lastResponseAnswer: String?) {
        self.itemIdentifier = identifier
        self.addSubview(questionLabel)
        self.addSubview(textView)
        questionLabel.text = question

        textView.text = lastResponseAnswer ?? ""

        if let localSavedAnswer = SurveyTaskUtility.shared.getCurrentSurveyLocalAnswer(questionIdentifier: identifier) {
            textView.text = localSavedAnswer
        }

        NSLayoutConstraint.activate([
            questionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 60),
            questionLabel.trailingAnchor.constraint(equalTo: textView.leadingAnchor),
            questionLabel.topAnchor.constraint(equalTo: self.topAnchor),
            questionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            textView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            textView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            textView.heightAnchor.constraint(equalToConstant: 32),
            textView.widthAnchor.constraint(equalToConstant: 113)
        ])
    }

    @objc func handleKeyboardDoneBarButtonTapped(_ sender: Any) {
        self.textView.resignFirstResponder()
    }
}


extension RKCFormInlineTextAnswerView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        delegate?.textViewDidChange(textView)
        guard let identifier = self.itemIdentifier else { return }
        SurveyTaskUtility.shared.saveCurrentSurveyAnswerLocally(questionIdentifier: identifier, answer: textView.text)
    }
    func textViewDidChangeSelection(_ textView: UITextView) {
        print("changed selection")
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        delegate?.textViewShouldBeginEditing(textView)
        return true
    }


    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.textViewDidEndEditing(textView)
    }

    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        delegate?.textView(textView, shouldChangeTextIn: range, replacementText: text)
        return true
    }
}
