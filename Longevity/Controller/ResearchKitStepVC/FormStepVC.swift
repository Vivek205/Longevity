//
//  FormStepVC.swift
//  Longevity
//
//  Created by vivek on 11/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

class FormStepVC: BaseStepViewController {
    
    var keyboardHeight: CGFloat?
    var initialYOrigin: CGFloat = CGFloat(0)
    var textViewHeight: CGFloat = 101
    var rollbackYOrigin: CGFloat?
    
    lazy var formItemsCollection: UICollectionView = {
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.backgroundColor = UIColor.clear //UIColor(red: 229.0/255, green: 229.0/255, blue: 234.0/255, alpha: 1)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.delegate = self
        collection.dataSource = self
        collection.alwaysBounceVertical = true
        return collection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.continueButton.isEnabled = true
        self.navigationController?.navigationBar.barTintColor = .white
        self.rollbackYOrigin = self.view.frame.origin.y
        
        presentViews()
        addKeyboardObservers()
        print("did load", self.view.frame.origin.y )
        self.initialYOrigin = self.view.frame.origin.y
        if SurveyTaskUtility.shared.isSymptomsSkipped {
            self.goBackward()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.rollbackYOrigin = self.view.frame.origin.y
    }

    deinit {
        removeKeyboardObservers()
    }

    func prefillForm(questionId: String) -> String? {
        let feelingTodayQuestionId = SurveyTaskUtility.shared.feelingTodayQuestionId
        guard let feelingTodayAnswer =
            SurveyTaskUtility.shared.getCurrentSurveyLocalAnswer(questionIdentifier: feelingTodayQuestionId) else {return nil}
        let prefillSymptomsOption = "2"
        if feelingTodayAnswer == prefillSymptomsOption {
            guard let lastResponse =
                SurveyTaskUtility.shared.getCurrentSurveyServerAnswer(questionIdentifier: questionId)else {return nil}
            return lastResponse
        }
        return nil
    }

    func presentViews() {
        self.view.addSubview(formItemsCollection)
        
        NSLayoutConstraint.activate([
            formItemsCollection.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            formItemsCollection.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            formItemsCollection.topAnchor.constraint(equalTo: self.view.topAnchor),
            formItemsCollection.bottomAnchor.constraint(equalTo: footerView.topAnchor)
        ])

        guard let layout = formItemsCollection.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        layout.sectionInset = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.invalidateLayout()
    }
}

extension FormStepVC: UICollectionViewDelegate,
                      UICollectionViewDataSource,
                      UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let formStep = self.step as? ORKFormStep else {
            return 0
        }
        if formStep.formItems != nil {
            return formStep.formItems!.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let defaultCell = collectionView.getCell(with: UICollectionViewCell.self, at: indexPath)
        guard let formStep = self.step as? ORKFormStep else {
            return defaultCell
        }
        guard let formItems = formStep.formItems else {
            return defaultCell
        }

        let item = formItems[indexPath.item]
        let prefillAnswer = prefillForm(questionId: item.identifier)
        let cellPosition = self.getCellPostion(formItems: formItems, index: indexPath.item)


        if (formStep.formItems?.count ?? 0) - 1 == indexPath.item && item.answerFormat?.questionType == .text {
            let itemCell = collectionView.getCell(with: RKCFormTextAnswerView.self,
                                                  at: indexPath) as! RKCFormTextAnswerView
            itemCell.createLayout(identifier:item.identifier, question: item.text!, lastResponseAnswer: prefillAnswer)
            itemCell.delegate = self
            return itemCell
        }

        if item.identifier == "" {
            let sectionItemCell = collectionView.getCell(with: RKCFormSectionItemView.self,
                                                         at: indexPath) as! RKCFormSectionItemView
            sectionItemCell.createLayout(heading: item.text!, iconName: item.placeholder, cellPosition: cellPosition)
            return sectionItemCell
        }

        switch item.answerFormat?.questionType {
        case .text:
            let itemCell = collectionView.getCell(with: RKCFormInlineTextAnswerView.self,
                                                  at: indexPath) as! RKCFormInlineTextAnswerView
            itemCell.createLayout(identifier:item.identifier, question: item.text!, lastResponseAnswer: prefillAnswer)
            itemCell.delegate = self
            return itemCell
        case .location:
            guard let locationCell = collectionView.getCell(with: RKCFormLocationView.self, at: indexPath) as? RKCFormLocationView else { preconditionFailure("Invalid cell")}
            locationCell.setupCell(identifier: item.identifier, question: item.text ?? "", lastResponseAnswer: prefillAnswer)
            return locationCell
        default:
            let itemCell = collectionView.getCell(with: RKCFormItemView.self, at: indexPath) as! RKCFormItemView
            itemCell.createLayout(identifier:item.identifier, question: item.text!,
                                  answerFormat: item.answerFormat!,
                                  lastResponseAnswer: prefillAnswer, cellPosition: cellPosition)
            return itemCell
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height = CGFloat(55.0)
        let width = self.view.bounds.width

        guard let formStep = self.step as? ORKFormStep else {
            return CGSize(width: width - CGFloat(30), height: height)
        }
        guard formStep.formItems != nil else {
            return CGSize(width: width - CGFloat(30), height: height)
        }
        let item = formStep.formItems![indexPath.item] as ORKFormItem

        if item.identifier == "" {
            return CGSize(width: width - CGFloat(30), height: height)
        }

        if (formStep.formItems?.count ?? 0) - 1 == indexPath.item
            && item.answerFormat?.questionType == .text {
            let answerCell = RKCFormTextAnswerView()
            let questionText = item.text ?? ""
            height = questionText.height(withConstrainedWidth: width - 30.0, font: answerCell.questionLabel.font)
             // height for textView & clear button
            return CGSize(width: width, height: height + 130)
        }

        return CGSize(width: width - CGFloat(30), height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.getSupplementaryView(with: RKCQuestionView.self,
                                                                   viewForSupplementaryElementOfKind: kind,
                                                                   at: indexPath) as? RKCQuestionView else {
            preconditionFailure("Invalid cell type")
        }
        
        if let formStep = self.step as? ORKFormStep, let question = formStep.text {
            headerView.createLayout(question: question)
        }
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        var height = CGFloat(38)
        let width = collectionView.bounds.width
        
            if let step = self.step as? ORKFormStep {
                let surveyName = SurveyTaskUtility.shared.getCurrentSurveyName() ?? ""
                let textColor = UIColor(hexString: "#4E4E4E")
                
                let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.semibold, size: 24.0), .foregroundColor: textColor]
                let attributedoptionData = NSMutableAttributedString(string: surveyName, attributes: attributes)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 1.8
                attributedoptionData.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedoptionData.length))

                let extraInfoAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.regular, size: 14.0)]

                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "EEE.MMM.dd"
                let surveyDate = dateformatter.string(from: Date())

                let extraInfoAttributedText = NSMutableAttributedString(string: "\n\(surveyDate)", attributes: extraInfoAttributes)

                attributedoptionData.append(extraInfoAttributedText)

                let questionAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.regular, size: 24.0)]
                let attributedquestionText = NSMutableAttributedString(string: "\n\n\(step.text ?? "")", attributes: questionAttributes)

                let paragraphStyle2 = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 2.4
                attributedquestionText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedquestionText.length))


                attributedoptionData.append(attributedquestionText)
                attributedoptionData.addAttribute(NSAttributedString.Key.kern, value: CGFloat(0.4), range: NSRange(location: 0, length: attributedoptionData.length))
                
                
                let alignParagraphStyle = NSMutableParagraphStyle()
                alignParagraphStyle.alignment = .center
                
                attributedoptionData.addAttribute(NSAttributedString.Key.paragraphStyle, value: alignParagraphStyle, range: NSRange(location: 0, length: attributedoptionData.length))
                
                let containerWidth = width - 30.0
                height = attributedoptionData.height(containerWidth: containerWidth) + 30.0
            }
            return CGSize(width: width, height: height)
    }
    
    fileprivate func getCellPostion(formItems: [ORKFormItem], index: Int) -> CellPosition {
        let fItem = formItems.firstIndex { $0.identifier == "" }
        let lItem = formItems.lastIndex { $0.identifier == "" }
        
        guard let firstItem = fItem else {
            return .center
        }
        
        guard let lastItem = lItem else {
            return .center
        }
        
        if index == firstItem {
            return .topmost
        } else if index == lastItem {
            return .bottom
        } else if index > firstItem && index < lastItem {
            return .center
        } else {
            return .none
        }
    }
}


extension FormStepVC: RKCFormTextAnswerViewDelegate, RKCFormInlineTextAnswerViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {}

    func textViewDidEndEditing(_ textView: UITextView) {
        if let rollbackYOrigin = self.rollbackYOrigin, self.view.frame.origin.y != rollbackYOrigin {
            self.view.frame.origin.y = rollbackYOrigin
        }
    }

    func textViewDidChange(_ textView: UITextView) {
    }

    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        return true
    }

    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self,  name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWasShown(notification: NSNotification) {
        guard let info = notification.userInfo else {return}
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        guard let keyboardHeight = keyboardSize?.height ,
            let navbarHeight = self.navigationController?.navigationBar.frame.size.height
        else {return}
        let topPadding:CGFloat = 30.0
        let viewYPadding = navbarHeight + topPadding

        var visibleScreen : CGRect = self.view.frame
        visibleScreen.size.height -= (keyboardHeight + viewYPadding)
        self.view.frame.origin.y = -(keyboardHeight - textViewHeight - viewYPadding - 100)
    }

    @objc func keyboardWillBeHidden(notification: NSNotification){
        guard let rollbackYOrigin = self.rollbackYOrigin else {return}
        self.view.frame.origin.y = rollbackYOrigin
    }
}
