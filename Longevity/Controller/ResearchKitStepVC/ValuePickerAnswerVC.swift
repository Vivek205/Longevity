//
//  ValuePickerAnswerVC.swift
//  Longevity
//
//  Created by vivek on 12/11/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

class ValuePickerAnswerVC: ORKStepViewController {
    lazy var questionAnswerCollection: UICollectionView = {
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .clear
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
        buttonView.setTitle("Continue", for: .normal)
        return buttonView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(questionAnswerCollection)
        self.view.addSubview(footerView)
        footerView.addSubview(continueButton)
        let footerViewHeight = CGFloat(130)

        NSLayoutConstraint.activate([
            questionAnswerCollection.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            questionAnswerCollection.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            questionAnswerCollection.topAnchor.constraint(equalTo: self.view.topAnchor),
            questionAnswerCollection.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,
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

        continueButton.isEnabled = false
        continueButton.addTarget(self, action: #selector(handleContinue(sender:)), for: .touchUpInside)

        guard let layout = questionAnswerCollection.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        layout.sectionInset = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 20.0
    }

    @objc func handleContinue(sender: UIButton) {
        self.goForward()
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
//        if let step = self.step as? ORKQuestionStep {
//            if let answerFormat = step.answerFormat as? ORKValuePickerAnswerFormat {
//                return answerFormat.textChoices.count
//            }
//            return 2
//        }
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

        headerView.createLayout(header: step.title ?? "", question: step.question!, extraInfo: step.text)
        return headerView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let height = CGFloat(100.0)
        let width = collectionView.bounds.width
        return CGSize(width: width, height: height)
    }
}

extension ValuePickerAnswerVC:ValuePickerAnswerViewCellDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.continueButton.isEnabled = true
    }
}
