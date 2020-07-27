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

    let choiceViewTwo: UIView = {
        let uiView = UIView()
        uiView.backgroundColor = .orange
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.layer.borderColor = UIColor.black.cgColor
        uiView.layer.borderWidth = 2
        return uiView
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
    }

    func presentViews() {
        if let step = self.step as? ORKQuestionStep{
            // FIXME: ScrollView not working
//            let scrollView = UIScrollView()
//            scrollView.translatesAutoresizingMaskIntoConstraints = false
//            scrollView.isDirectionalLockEnabled = true
//            scrollView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 3000)
//            self.view.addSubview(scrollView)
//
//            let contentView = UIView()
//            contentView.translatesAutoresizingMaskIntoConstraints = false
//            contentView.frame.size.height = view.bounds.size.height + 300
//            scrollView.addSubview(contentView)

            let questionView = RKCQuestionView(header: step.title ?? "", subHeader:"Wed.Jun.10 for {patient name}", question: step.question, extraInfo: step.text )
            questionView.header = "Covid Questions"
            self.view.addSubview(questionView)

            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.distribution = .fillEqually
            stackView.alignment = .fill
            stackView.spacing = 20.0
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.clipsToBounds = true
            self.view.addSubview(stackView)

            self.view.addSubview(footerView)
            footerView.addSubview(continueButton)

            // MARK: Constraints
            // FIXME: ScrollView not working
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//            scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//            scrollView.bottomAnchor.constraint(equalTo: footerView.topAnchor).isActive = true

//            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
//            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
//            contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
//            contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true

            let questionViewHeight = step.text == nil ? CGFloat(150) : CGFloat(250) 
            questionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
            questionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
            questionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
            questionView.heightAnchor.constraint(equalToConstant: questionViewHeight).isActive = true

            stackView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
            stackView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20).isActive = true
            stackView.topAnchor.constraint(equalTo: questionView.bottomAnchor, constant: 20).isActive = true


            footerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            footerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            footerView.heightAnchor.constraint(equalToConstant: 130).isActive = true



            continueButton.leftAnchor.constraint(equalTo: footerView.leftAnchor, constant: 15).isActive = true
            continueButton.rightAnchor.constraint(equalTo: footerView.rightAnchor, constant: -15).isActive = true
            continueButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 24).isActive = true
            continueButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
            continueButton.addTarget(self, action: #selector(handleContinue(sender:)), for: .touchUpInside)

            print("inside", step.answerFormat)
            if let answerFormat = step.answerFormat as? ORKTextChoiceAnswerFormat{
                for index in 0...answerFormat.textChoices.count-1 {
                    let choice = answerFormat.textChoices[index]

                    var choiceView = RKCTextChoiceAnswerView(answer: choice.text, info: "Additional info aaldfjaj fadfjdfjf This method automatically adds the provided view as a subview of the stack view, if it is not already. If the view is already a subview, this operation does not alter the subview ")

                    choiceView.translatesAutoresizingMaskIntoConstraints = false
                    choiceView.checkbox.addTarget(self, action: #selector(handleChoiceChange(sender:)), for: .touchUpInside)
                    choiceView.tag = index
                    choiceView.checkbox.tag = index
                    if choiceViews.count <= index {
                        choiceViews.append(choiceView)
                    }else{
                        choiceViews[index] = choiceView
                    }

                    stackView.addArrangedSubview(choiceView)
                }

                print("choices", answerFormat.textChoices.map{$0.value})
                print("choices", answerFormat.textChoices.map{$0.text})
                print("choices", answerFormat.textChoices.map{$0.detailText})
            }
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
            choiceView.setSelected(true)
            choiceView.checkbox.isSelected = false
        }
        sender.isSelected = true
    }

}
