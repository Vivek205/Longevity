//
//  CovidCheckinSurvey.swift
//  Longevity
//
//  Created by vivek on 20/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import ResearchKit

func createCovidCheckinSurveyTask() -> ORKOrderedTask? {

    guard let questions = getQuestions() else { return nil}
    var steps = [ORKStep]()

    let instructionStep = ORKInstructionStep(identifier: "IntroStep")
    instructionStep.title = "Intro: The Questions Three"
    instructionStep.text = "Who would cross the Bridge of Death must answer me these questions three, ere the other side they see."
    steps += [instructionStep]

    for questionData in questions {
        let step = createSingleChoiceQuestionStep(
            identifier: questionData.quesId,
            title: questionData.heading,
            question: questionData.text,
            additionalText: questionData.otherDetails,
            choices: questionData.options.map{ORKTextChoice(text: $0.text, detailText: $0.description, value: NSNumber(value: $0.value), exclusive: false)}
        )
        steps += [step]
    }

    let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
    summaryStep.title = "SummaryRight. Off you go!"
    summaryStep.text = "That was easy!"
    steps += [summaryStep]

    let task = BranchingOrderedTask(identifier: "CovidCheckinSurveyTask", steps: steps)

    let predicateStep1 = ORKResultPredicate.predicateForChoiceQuestionResult(with: ORKResultSelector(taskIdentifier: "CovidCheckinSurveyTask", resultIdentifier: "TextChoiceQuestionStep"), expectedAnswerValue: "1" as NSCoding & NSCopying & NSObjectProtocol)

    task.setVisibleStep("TextChoiceQuestionStepTwo", when: [predicateStep1])
    return task
}


func createSingleChoiceQuestionStep(identifier: String,title:String, question: String,additionalText:String?, choices:[ORKTextChoice]) -> ORKQuestionStep {
    let questionStepTitle = title
    let questionStepQuestion = question
    let textChoices = choices
    let questionAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: textChoices)

    let questionStep = ORKQuestionStep(identifier: identifier, title: questionStepTitle, question: questionStepQuestion, answer: questionAnswerFormat)

    questionStep.text = additionalText
    return questionStep
}
