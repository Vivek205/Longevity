//
//  CovidCheckinVC.swift
//  Longevity
//
//  Created by vivek on 20/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

class CovidCheckinVC: ORKStepViewController {
    var count: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func skipForward() {
        
    }

    @IBAction func handleCheckboxPress(_ sender: Any) {
        print(taskViewController?.currentStepViewController?.step)
        if step?.identifier == "TextChoiceQuestionStep" {
            let currentStep: ORKQuestionStep = step as! ORKQuestionStep
            let question = currentStep.question
            let answerFormat = currentStep.answerFormat as! ORKTextChoiceAnswerFormat
            print(answerFormat.textChoices)
            for textChoice in answerFormat.textChoices {
                print(textChoice.text)
                print(textChoice.detailText)
                print(textChoice.value)
            }
            print(currentStep.question)
            print(currentStep.answerFormat)
            print(currentStep.questionType)
        }

        count += 1
        let questionResult: ORKChoiceQuestionResult = ORKChoiceQuestionResult()
        questionResult.identifier = "TextChoiceQuestionStep"
        questionResult.choiceAnswers = [NSNumber(value: self.count)]
        addResult(questionResult)
    }

    @IBAction func handleContinuePress(_ sender: Any) {
        goForward()
    }
}

extension CovidCheckinVC: ORKTaskResultSource {
    func stepResult(forStepIdentifier stepIdentifier: String) -> ORKStepResult? {
        switch stepIdentifier {
        case "TextChoiceQuestionStep":
            let result = ORKChoiceQuestionResult(identifier: "TextChoiceQuestionStep")
            let stepResult = ORKStepResult(stepIdentifier: "TextChoiceQuestionStep", results: [result])
            return stepResult
        default:
            return ORKStepResult()
        }
    }
}




