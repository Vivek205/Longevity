//
//  TextChoiceAnswerVC.swift
//  Longevity
//
//  Created by vivek on 23/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

class TextChoiceAnswerVC: ORKStepViewController {
    var chosenCells: [TextChoiceAnswerViewCell]?

    lazy var questionAnswerCollection: UICollectionView = {
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .clear
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

    var choiceViews: [RKCTextChoiceAnswerView] = [RKCTextChoiceAnswerView]()

    override func viewDidLoad() {
        super.viewDidLoad()
        presentViews()

        questionAnswerCollection.register(RKCQuestionView.self, forCellWithReuseIdentifier: "question")
    }

    func presentViews() {
        if let step = self.step as? ORKQuestionStep{
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

            footerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            footerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            footerView.heightAnchor.constraint(equalToConstant: footerViewHeight).isActive = true

            continueButton.leftAnchor.constraint(equalTo: footerView.leftAnchor, constant: 15).isActive = true
            continueButton.rightAnchor.constraint(equalTo: footerView.rightAnchor, constant: -15).isActive = true
            continueButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 24).isActive = true
            continueButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
            continueButton.isEnabled = false
            continueButton.addTarget(self, action: #selector(handleContinue(sender:)), for: .touchUpInside)

            print("inside", step.answerFormat)

            guard let layout = questionAnswerCollection.collectionViewLayout as? UICollectionViewFlowLayout else {
                return
            }

            layout.sectionInset = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)
            layout.scrollDirection = .vertical
            layout.minimumInteritemSpacing = 20.0
        }
    }

    @objc func handleContinue(sender: UIButton) {
        self.goForward()
    }

    func addResult(value:String) {
        if let questionId = self.step?.identifier as? String {
            SurveyTaskUtility.currentSurveyResult[questionId] = value
        }
    }

}

extension TextChoiceAnswerVC: UICollectionViewDelegate,
UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let step = self.step as? ORKQuestionStep {
            if let answerFormat = step.answerFormat as? ORKTextChoiceAnswerFormat {
                print(answerFormat.textChoices.count)
                return answerFormat.textChoices.count + 1
            }
            return 2
        }
        return 2
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            if let step = self.step as? ORKQuestionStep {
                let questionSubheader = SurveyTaskUtility.surveyTagline
                let questionCell = collectionView.getCell(with: RKCQuestionView.self, at: indexPath)
                    as! RKCQuestionView
                questionCell.createLayout(header: step.title ?? "", subHeader: questionSubheader ?? "",
                                          question: step.question!, extraInfo: step.text)
                return questionCell
            }
        }

        if let step = self.step as? ORKQuestionStep {
            if let answerFormat = step.answerFormat as? ORKTextChoiceAnswerFormat {
                let currentAnswerValue: String? = SurveyTaskUtility.currentSurveyResult[step.identifier]

                let choice = answerFormat.textChoices[indexPath.item - 1]
                let answerViewCell = collectionView.getCell(with: TextChoiceAnswerViewCell.self, at: indexPath)
                    as! TextChoiceAnswerViewCell
                answerViewCell.delegate = self
                answerViewCell.createLayout(text: choice.text, extraInfo: choice.detailText)
                answerViewCell.value = indexPath.item - 1
                if Int(currentAnswerValue ?? "") == answerViewCell.value {
                    answerViewCell.toggleIsChosenOption()
                    continueButton.isEnabled = true
                    if chosenCells == nil {
                        chosenCells = [answerViewCell]
                    }else {
                        chosenCells! += [answerViewCell]
                    }
                }

                return answerViewCell
            }
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height = CGFloat(100.0)
        let width = self.view.bounds.width
        if indexPath.item == 0 {
            if let step = self.step as? ORKQuestionStep {
                let questionCell = RKCQuestionView()
                height = step.title!.height(withConstrainedWidth: width, font: questionCell.headerLabel.font)

                let questionSubheader = SurveyTaskUtility.surveyTagline ?? ""
                height += questionSubheader.height(withConstrainedWidth: width , font: questionCell.subHeaderLabel.font)
                height += step.question!.height(withConstrainedWidth: width, font: questionCell.questionLabel.font)
                if step.text != nil {
                    height += step.text!.height(withConstrainedWidth: width, font: questionCell.extraInfoLabel.font)
                }
                // INSETS
                height += 60.0
            }
            return CGSize(width: width, height: height)
        }

        if let step = self.step as? ORKQuestionStep {
            if let answerFormat = step.answerFormat as? ORKTextChoiceAnswerFormat {
                let choice = answerFormat.textChoices[indexPath.item - 1]
                let answerCell = TextChoiceAnswerViewCell()
                height = choice.text.height(withConstrainedWidth: width - 80.0, font: answerCell.titleLabel.font)
                if choice.detailText != nil {
                    height += choice.detailText!
                        .height(withConstrainedWidth: width - 80.0, font: answerCell.extraInfoLabel.font)
                }

                height += 50
            }
        }


        return CGSize(width: width - CGFloat(40), height: height)
    }
    
}

extension TextChoiceAnswerVC: TextChoiceAnswerViewChangedDelegate {
    func checkboxButton(wasPressedOnCell cell: TextChoiceAnswerViewCell) {
        if chosenCells != nil {
            if let step = self.step as? ORKQuestionStep {
                if let answerFormat = step.answerFormat as? ORKTextChoiceAnswerFormat {
                    if answerFormat.style == .singleChoice {
                        chosenCells?.forEach {$0.toggleIsChosenOption()}
                        chosenCells = nil
                    }
                }
            }
        }

        if chosenCells == nil {
            chosenCells = [cell]
        }else {
            chosenCells! += [cell]
        }
        self.addResult(value: "\(cell.value!)")
        continueButton.isEnabled = true
    }
}
