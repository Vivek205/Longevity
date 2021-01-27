//
//  TextChoiceAnswerVC.swift
//  Longevity
//
//  Created by vivek on 23/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

class TextChoiceAnswerVC: BaseStepViewController {
    var chosenCells: [TextChoiceAnswerViewCell]?

    lazy var questionAnswerCollection: UICollectionView = {
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .clear //UIColor(red: 229.0/255, green: 229.0/255, blue: 234.0/255, alpha: 1)
        collection.alwaysBounceVertical = true  
        return collection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        presentViews()
    }

    func presentViews() {
        self.view.addSubview(questionAnswerCollection)
        self.view.addSubview(footerView)
        footerView.addSubview(continueButton)
        
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
    }

    func addResult(value:String) {
        if let questionId = self.step?.identifier as? String {
            SurveyTaskUtility.shared.setCurrentSurveyLocalAnswer(questionIdentifier: questionId, answer: value)
        }
    }
}

extension TextChoiceAnswerVC: UICollectionViewDelegate,
UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let step = self.step as? ORKQuestionStep {
            if let answerFormat = step.answerFormat as? ORKTextChoiceAnswerFormat {
                return answerFormat.textChoices.count
            }
            return 2
        }
        return 2
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if let step = self.step as? ORKQuestionStep {
            if let answerFormat = step.answerFormat as? ORKTextChoiceAnswerFormat {
                let currentAnswerValue: String? =
                    SurveyTaskUtility.shared.getCurrentSurveyLocalAnswer(questionIdentifier: step.identifier)

                let choice = answerFormat.textChoices[indexPath.item]
                let answerViewCell = collectionView.getCell(with: TextChoiceAnswerViewCell.self, at: indexPath)
                    as! TextChoiceAnswerViewCell
                answerViewCell.delegate = self
                answerViewCell.createLayout(text: choice.text, extraInfo: choice.detailText)
                answerViewCell.value = Int(choice.value as? String ?? "0")
                answerViewCell.answerFormatStyle = answerFormat.style
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
        let width = collectionView.bounds.width - 30.0

        if let step = self.step as? ORKQuestionStep {
            if let answerFormat = step.answerFormat as? ORKTextChoiceAnswerFormat {
                let choice = answerFormat.textChoices[indexPath.item]
                
                let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Medium", size: 18),
                                                                 .foregroundColor: UIColor.black]
                let attributedoptionData = NSMutableAttributedString(string: choice.text, attributes: attributes)

                if let extraInfoText = choice.detailText, !extraInfoText.isEmpty {
                    let extraInfoAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.regular, size: 14.0),
                                                                              .foregroundColor: UIColor(hexString: "#666666")]
                    let extraInfoAttributedText = NSMutableAttributedString(string: "\n\(extraInfoText)",
                                                                            attributes: extraInfoAttributes)
                    attributedoptionData.append(extraInfoAttributedText)
                }
                
                attributedoptionData.addAttribute(NSAttributedString.Key.kern, value: CGFloat(0.4),
                                                  range: NSRange(location: 0, length: attributedoptionData.length))

                height = attributedoptionData.height(containerWidth: width - 64.0) + 30.0
            }
        }


        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.getSupplementaryView(with: RKCQuestionView.self,
                                                                   viewForSupplementaryElementOfKind: kind, at: indexPath) as? RKCQuestionView else {
            preconditionFailure("Invalid cell type")
        }
        
        if let step = self.step as? ORKQuestionStep, let question = step.question {
            headerView.createLayout(question: question)
        }
        
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TextChoiceAnswerViewCell
        else { return }
        print(cell.titleLabel.text)
        cell.toggleIsChosenOption()
        checkboxButton(wasPressedOnCell: cell)
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
        } else {
            chosenCells! += [cell]
        }
        self.addResult(value: "\(cell.value!)")
        continueButton.isEnabled = true
    }
}
