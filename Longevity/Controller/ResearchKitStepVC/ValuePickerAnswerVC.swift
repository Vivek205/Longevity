//
//  ValuePickerAnswerVC.swift
//  Longevity
//
//  Created by vivek on 12/11/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

class ValuePickerAnswerVC: BaseStepViewController {
    lazy var questionAnswerCollection: UICollectionView = {
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .clear
        collection.alwaysBounceVertical = true
        return collection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(questionAnswerCollection)

        NSLayoutConstraint.activate([
            questionAnswerCollection.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            questionAnswerCollection.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            questionAnswerCollection.topAnchor.constraint(equalTo: self.view.topAnchor),
            questionAnswerCollection.bottomAnchor.constraint(equalTo: self.footerView.topAnchor)
        ])

        guard let layout = questionAnswerCollection.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        layout.sectionInset = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 20.0
        layout.invalidateLayout()
    }

    func addResult(value:String) {
        if let questionId = self.step?.identifier as? String {
            SurveyTaskUtility.shared.setCurrentSurveyLocalAnswer(questionIdentifier: questionId, answer: value)
        }
    }
}

extension ValuePickerAnswerVC: UICollectionViewDelegate,
                               UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let step = self.step as? ORKQuestionStep,
              let answerFormat = step.answerFormat as? ORKValuePickerAnswerFormat,
              let valuePickerCell = collectionView.getCell(with: ValuePickerAnswerViewCell.self, at: indexPath) as? ValuePickerAnswerViewCell
        else {
            preconditionFailure("It is not a valid question step")
        }
        valuePickerCell.delegate = self
        valuePickerCell.textChoices = answerFormat.textChoices
        valuePickerCell.questionId = step.identifier
        return valuePickerCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = CGFloat(217.0)
        let width = collectionView.bounds.width - 30.0
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.getSupplementaryView(with: RKCQuestionView.self,         viewForSupplementaryElementOfKind: kind, at: indexPath) as? RKCQuestionView,
              let step = self.step as? ORKQuestionStep
        else {
            preconditionFailure("Invalid cell type")
        }

        headerView.createLayout(question: step.question ?? "")
        return headerView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var height = CGFloat(100.0)
        let width = collectionView.bounds.width
        
        if let step = self.step as? ORKQuestionStep {
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
            let attributedquestionText = NSMutableAttributedString(string: "\n\n\(step.question ?? "")", attributes: questionAttributes)

            let paragraphStyle2 = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2.4
            attributedquestionText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedquestionText.length))

            attributedoptionData.append(attributedquestionText)
            attributedoptionData.addAttribute(NSAttributedString.Key.kern, value: CGFloat(0.4), range: NSRange(location: 0, length: attributedoptionData.length))
            
            height = attributedoptionData.height(containerWidth: width - 30.0) + 20.0
        }
        
        return CGSize(width: width, height: height)
    }
}

extension ValuePickerAnswerVC:ValuePickerAnswerViewCellDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.continueButton.isEnabled = true
    }
}
