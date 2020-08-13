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
    lazy var formItemsCollection: UICollectionView = {
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.backgroundColor = UIColor(red: 229.0/255, green: 229.0/255, blue: 234.0/255, alpha: 1)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.delegate = self
        collection.dataSource = self
        collection.alwaysBounceVertical = true
        return collection
    }()

    let footerView:UIView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.backgroundColor = .white
        return uiView
    }()

    let continueButton: CustomButtonFill = {
        let buttonView = CustomButtonFill()
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.setTitle("Next", for: .normal)
        return buttonView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        presentViews()
    }

    func prefillForm(questionId: String) -> String? {
        let feelingTodayQuestionId = "036122cab53e4d70b1b6305328eeaf3w"
        let feelingTodayAnswer = SurveyTaskUtility.currentSurveyResult[feelingTodayQuestionId]
        let prefillSymptomsOption = "2"
        if feelingTodayAnswer == prefillSymptomsOption {
            let lastResponse = SurveyTaskUtility.lastResponse
            if lastResponse != nil {

                let lastResponsesForGivenQuestionId = lastResponse?.filter({ (response) -> Bool in
                    return response.quesId == questionId
                })
                
                if lastResponsesForGivenQuestionId != nil && !lastResponsesForGivenQuestionId!.isEmpty {
                     return lastResponsesForGivenQuestionId![0].answer
                }
                return nil
            }
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

        footerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        footerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        footerView.heightAnchor.constraint(equalToConstant: footerViewHeight).isActive = true

        continueButton.leftAnchor.constraint(equalTo: footerView.leftAnchor, constant: 15).isActive = true
        continueButton.rightAnchor.constraint(equalTo: footerView.rightAnchor, constant: -15).isActive = true
        continueButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 24).isActive = true
        continueButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
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
            let questionSubheader = SurveyTaskUtility.surveyTagline
            let questionCell = collectionView.getCell(with: RKCQuestionView.self, at: indexPath)
                as! RKCQuestionView
            questionCell.createLayout(header: formStep.title ?? "", subHeader: questionSubheader ?? "",
                                      question: formStep.text ?? "", extraInfo: nil)
            return questionCell

        }

        let item = formStep.formItems![indexPath.item - 1] as ORKFormItem

        if item.identifier == "" {
            let sectionItemCell = collectionView.getCell(with: RKCFormSectionItemView.self,
                                                         at: indexPath) as! RKCFormSectionItemView
            sectionItemCell.createLayout(heading: item.text!, iconName: item.placeholder)
            return sectionItemCell
        }

        let itemCell = collectionView.getCell(with: RKCFormItemView.self, at: indexPath) as! RKCFormItemView
        let prefillAnswer = prefillForm(questionId: item.identifier)
        itemCell.createLayout(identifier:item.identifier, question: item.text!, answerFormat: item.answerFormat!,
                              lastResponseAnswer: prefillAnswer)
        return itemCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height = CGFloat(38)
        let width = self.view.bounds.width

        if indexPath.item == 0 {
            if let step = self.step as? ORKFormStep {
                let questionCell = RKCQuestionView()
                height = step.title!.height(withConstrainedWidth: width, font: questionCell.headerLabel.font)

                let questionSubheader = SurveyTaskUtility.surveyTagline ?? ""
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


        return CGSize(width: width - CGFloat(40), height: height)
    }
}
