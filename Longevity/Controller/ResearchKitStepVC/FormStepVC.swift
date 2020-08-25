//
//  FormStepVC.swift
//  Longevity
//
//  Created by vivek on 11/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

class FormStepVC: ORKStepViewController {
    var keyboardHeight: CGFloat?
    var initialYOrigin: CGFloat = CGFloat(0)
    
    lazy var formItemsCollection: UICollectionView = {
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.backgroundColor = UIColor(red: 229.0/255, green: 229.0/255, blue: 234.0/255, alpha: 1)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.delegate = self
        collection.dataSource = self
        collection.alwaysBounceVertical = true
        return collection
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

    override func viewDidLoad() {
        super.viewDidLoad()
        presentViews()
        addKeyboardObservers()
        print("did load", self.view.frame.origin.y )
        self.initialYOrigin = self.view.frame.origin.y
    }

    deinit {
        removeKeyboardObservers()
    }

    func prefillForm(questionId: String) -> String? {
        let feelingTodayQuestionId = "036122cab53e4d70b1b6305328eeaf3w"
        guard let feelingTodayAnswer =
            SurveyTaskUtility.shared.getCurrentSurveyLocalAnswer(questionIdentifier: feelingTodayQuestionId) else {return nil}
        let prefillSymptomsOption = "2"
        if feelingTodayAnswer == prefillSymptomsOption {
            guard let lastResponse =
                SurveyTaskUtility.shared.getCurrentSurveyServerAnswer(questionIdentifier: questionId)else {return nil}
            return lastResponse

            return nil

        }
        return nil
    }

    func presentViews() {
        self.view.addSubview(formItemsCollection)
        self.view.addSubview(footerView)
        footerView.addSubview(continueButton)
        let footerViewHeight = CGFloat(130)

        NSLayoutConstraint.activate([
            formItemsCollection.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            formItemsCollection.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            formItemsCollection.topAnchor.constraint(equalTo: self.view.topAnchor),
            formItemsCollection.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,
                                                        constant: -footerViewHeight)
        ])

        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: footerViewHeight)
        ])

        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 15),
            continueButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -15),
            continueButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 24),
            continueButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        continueButton.isEnabled = true
        continueButton.addTarget(self, action: #selector(handleContinue(sender:)), for: .touchUpInside)

        guard let layout = formItemsCollection.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        layout.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 10.0, right: 0.0)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 20.0
    }

    @objc func handleContinue(sender: UIButton) {
        self.goForward()
    }

}

extension FormStepVC: UICollectionViewDelegate,
UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let formStep = self.step as? ORKFormStep else {
            return 0
        }
        if formStep.formItems != nil {
            return formStep.formItems!.count + 1
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let defaultCell = collectionView.getCell(with: UICollectionViewCell.self, at: indexPath)
        guard let formStep = self.step as? ORKFormStep else {
            return defaultCell
        }
        guard formStep.formItems != nil else {
            return defaultCell
        }

        if indexPath.item == 0 {
            print(formStep.text)
            let questionSubheader = SurveyTaskUtility.shared.surveyTagline
            let questionCell = collectionView.getCell(with: RKCQuestionView.self, at: indexPath)
                as! RKCQuestionView
            questionCell.createLayout(header: formStep.title ?? "",
                                      subHeader: questionSubheader ?? "",
                                      question: formStep.text ?? "", extraInfo: nil)
            return questionCell

        }

        let item = formStep.formItems![indexPath.item - 1] as ORKFormItem
        let prefillAnswer = prefillForm(questionId: item.identifier)

        if item.identifier == "" {
            let sectionItemCell = collectionView.getCell(with: RKCFormSectionItemView.self,
                                                         at: indexPath) as! RKCFormSectionItemView
            sectionItemCell.createLayout(heading: item.text!, iconName: item.placeholder)
            return sectionItemCell
        }
        print("item.text", item.text)
        print("formStep.formItems?.count", formStep.formItems?.count)
        print("indexPath.item", indexPath.item)

        if formStep.formItems?.count == indexPath.item && item.answerFormat?.questionType == .text {
            let itemCell = collectionView.getCell(with: RKCFormTextAnswerView.self,
                                                  at: indexPath) as! RKCFormTextAnswerView
            itemCell.createLayout(identifier:item.identifier, question: item.text!, lastResponseAnswer: prefillAnswer)
            itemCell.delegate = self
            return itemCell
        }

        switch item.answerFormat?.questionType {
        case .text:
            let itemCell = collectionView.getCell(with: RKCFormInlineTextAnswerView.self,
                                                  at: indexPath) as! RKCFormInlineTextAnswerView
            itemCell.createLayout(identifier:item.identifier, question: item.text!, lastResponseAnswer: prefillAnswer)
            itemCell.delegate = self
            return itemCell
        default:
            let itemCell = collectionView.getCell(with: RKCFormItemView.self, at: indexPath) as! RKCFormItemView
            itemCell.createLayout(identifier:item.identifier, question: item.text!,
                                  answerFormat: item.answerFormat!,
                                  lastResponseAnswer: prefillAnswer)
            return itemCell
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height = CGFloat(38)
        let width = self.view.bounds.width

        if indexPath.item == 0 {
            if let step = self.step as? ORKFormStep {
                let questionCell = RKCQuestionView()
                height = step.title!.height(withConstrainedWidth: width, font: questionCell.headerLabel.font)

                let questionSubheader = SurveyTaskUtility.shared.surveyTagline ?? ""
                height += questionSubheader.height(withConstrainedWidth: width , font: questionCell.subHeaderLabel.font)
                if step.text != nil {
                    height += step.text!.height(withConstrainedWidth: width, font: questionCell.extraInfoLabel.font)
                }
                // INSETS
                height += 60.0
            }
            return CGSize(width: width, height: height)
        }

        guard let formStep = self.step as? ORKFormStep else {
            return CGSize(width: width - CGFloat(40), height: height)
        }
        guard formStep.formItems != nil else {
            return CGSize(width: width - CGFloat(40), height: height)
        }
        let item = formStep.formItems![indexPath.item - 1] as ORKFormItem

        if item.identifier == "" {
            return CGSize(width: width - CGFloat(40), height: height)
        }

        if formStep.formItems?.count == indexPath.item && item.answerFormat?.questionType == .text {
            let answerCell = RKCFormTextAnswerView()
            let questionText = item.text ?? ""
            height = questionText.height(withConstrainedWidth: width - 40.0, font: answerCell.questionLabel.font)
            height += 100 // height for textView
            return CGSize(width: width, height: height)
        }

        return CGSize(width: width - CGFloat(40), height: height)




    }
}


extension FormStepVC: RKCFormTextAnswerViewDelegate, RKCFormInlineTextAnswerViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        animateTextView(showKeyboard: true)
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        animateTextView(showKeyboard: true)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        animateTextView(showKeyboard: false)
    }

    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        if text == "\n" {
            animateTextView(showKeyboard: false)
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    func animateTextView(showKeyboard: Bool) {
        print("Y position", self.view.frame.origin.y, "initial", self.initialYOrigin)
        if self.view.frame.origin.y > CGFloat(0) {
            self.initialYOrigin = self.view.frame.origin.y
        }
        let movementDistance = self.keyboardHeight ?? CGFloat(0)
        let movement = showKeyboard ? -(movementDistance) : self.initialYOrigin
        self.view.frame.origin.y = movement
    }

    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self,  name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification,
                                                  object: nil)
    }

    @objc func keyboardWillChange(notification: Notification) {
        print("keyboard notification \(notification.name.rawValue)")
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.keyboardHeight = keyboardRectangle.height
            print("keyboard height", self.keyboardHeight)
        }
    }
}
