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

    lazy var questionAnswerCollection: UICollectionView = {
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.delegate = self
        collection.dataSource = self
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
            //            continueButton.addTarget(self, action: #selector(handleContinue(sender:)), for: .touchUpInside)

            print("inside", step.answerFormat)

            guard let layout = questionAnswerCollection.collectionViewLayout as? UICollectionViewFlowLayout else {
                return
            }

            layout.sectionInset = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
            layout.scrollDirection = .vertical
            layout.minimumInteritemSpacing = 10.0

            //            if let answerFormat = step.answerFormat as? ORKTextChoiceAnswerFormat{
            //                for index in 0...answerFormat.textChoices.count-1 {
            //                    let choice = answerFormat.textChoices[index]
            //
            //                    var choiceView = RKCTextChoiceAnswerView(answer: choice.text, info: choice.detailText)
            //
            //                    choiceView.translatesAutoresizingMaskIntoConstraints = false
            //                    choiceView.checkbox.addTarget(self, action: #selector(handleChoiceChange(sender:)),
            //                                                  for: .touchUpInside)
            //                    choiceView.tag = index
            //                    choiceView.checkbox.tag = index
            //                    if choiceViews.count <= index {
            //                        choiceViews.append(choiceView)
            //                    }else{
            //                        choiceViews[index] = choiceView
            //                    }
            //                    stackView.addArrangedSubview(choiceView)
            //                }
            //
            //                print("choices", answerFormat.textChoices.map{$0.value})
            //                print("choices", answerFormat.textChoices.map{$0.text})
            //                print("choices", answerFormat.textChoices.map{$0.detailText})
            //            }
        }
    }

    @objc func handleContinue(sender: UIButton) {
        self.goForward()
    }

    @objc func handleChoiceChange(sender: CheckboxButton) {
        let questionResult: ORKChoiceQuestionResult = ORKChoiceQuestionResult()
        questionResult.identifier = self.step?.identifier ?? ""
        questionResult.choiceAnswers = [NSNumber(value: sender.tag)]
        addResult(questionResult)

        for choiceView in choiceViews {
            choiceView.setSelected(false)
            choiceView.checkbox.isSelected = false
        }

        let selectedChoice = choiceViews.first{$0.tag == sender.tag}
        selectedChoice?.setSelected(true)
        sender.isSelected = true
        continueButton.isEnabled = true
    }

}

extension TextChoiceAnswerVC: UICollectionViewDelegate,
UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let step = self.step as? ORKQuestionStep {
            if let answerFormat = step.answerFormat as? ORKTextChoiceAnswerFormat{
                return answerFormat.textChoices.count + 6
            }
            return 5
        }
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let defaultCell = collectionView.getCell(with: RKCQuestionView.self, at: indexPath)
        defaultCell.backgroundColor = .blue

        if indexPath.row == 0 {
            if let step = self.step as? ORKQuestionStep {
                let questionSubheader = "Thu.Aug.6 for {patient name}"
                let questionCell = collectionView.getCell(with: RKCQuestionView.self, at: indexPath) as! RKCQuestionView
                questionCell.createLayout(header: step.title ?? "", subHeader: questionSubheader,
                                          question: step.question, extraInfo: step.text)
                return questionCell
            }
            return defaultCell
        }

        if let step = self.step as? ORKQuestionStep {
            if let answerFormat = step.answerFormat as? ORKTextChoiceAnswerFormat {
                let choice = answerFormat.textChoices[1]
                let answerViewCell = collectionView.getCell(with: TextChoiceAnswerViewCell.self, at: indexPath)
                return answerViewCell
            }
        }
        return defaultCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height
        let width = self.view.bounds.width - CGFloat(40)
        return CGSize(width: width, height: 200.0)
    }
}
