//
//  RKCFormTextAnswerView.swift
//  Longevity
//
//  Created by vivek on 18/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class RKCFormTextAnswerView: UICollectionViewCell {
    var itemIdentifier:String?
    
    lazy var questionLabel: UILabel  = {
        let label = UILabel()
        label.font = UIFont(name: "Montserrat-Regular", size: 18)
        label.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 1)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var keyboardToolbar:UIToolbar = {
        let toolbar = UIToolbar()
        let doneBarButton = UIBarButtonItem(title: "done", style: .plain, target: self,
                                            action: #selector(handleKeyboardDoneBarButtonTapped(_:)))
        toolbar.items = [doneBarButton]
        return toolbar
    }()
    
    lazy var answerTextView: UITextView = {
        let textView = UITextView()
        textView.layer.cornerRadius = 16.5
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.inputAccessoryView = self.keyboardToolbar
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        answerTextView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createLayout(identifier:String, question:String, lastResponseAnswer:String?) {
        self.itemIdentifier = identifier
        self.addSubview(questionLabel)
        self.addSubview(answerTextView)
        
        questionLabel.text = question
        answerTextView.text = lastResponseAnswer ?? ""
        
        NSLayoutConstraint.activate([
            questionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            questionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            questionLabel.topAnchor.constraint(equalTo: self.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            answerTextView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            answerTextView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            answerTextView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 0),
            answerTextView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    @objc func handleKeyboardDoneBarButtonTapped(_ sender: Any) {
        self.answerTextView.resignFirstResponder()
    }
}

extension RKCFormTextAnswerView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let identifier = self.itemIdentifier as? String else { return }
        SurveyTaskUtility.currentSurveyResult[identifier] = textView.text
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
//        self.answerTextView.resignFirstResponder()
    }
}
