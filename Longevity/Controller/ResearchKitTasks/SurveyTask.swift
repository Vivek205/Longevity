//
//  SurveyTask.swift
//  Longevity
//
//  Created by vivek on 18/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import ResearchKit

public var surveyTask: ORKOrderedTask {
    var steps = [ORKStep]()

    let instructionStep = ORKInstructionStep(identifier: "IntroStep")
    instructionStep.title = "The Questions Three"
    instructionStep.text = "Who would cross the Bridge of Death must answer me these questions three, ere the other side they see."
    steps += [instructionStep]

    let nameAnswerFormat = ORKTextAnswerFormat(maximumLength: 20)
    nameAnswerFormat.multipleLines = false
    let nameQuestionStepTitle = "What is your name?"
    let nameQuestion = "Detailed question: what is your name"
    let nameQuestionStep = ORKQuestionStep(identifier: "QuestionStep", title: nameQuestionStepTitle, question: nameQuestion, answer: nameAnswerFormat)
    steps += [nameQuestionStep]

    let questionStepTitle = "What is your question"
    let questionStepQuestion = "Detailed question 2: Here goes the detailed question"
    let textChoices = [
        ORKTextChoice(text: "Create a ResearchKit App", value: 0 as NSNumber),
        ORKTextChoice(text: "Seek the Holy Grail", value: 1 as NSNumber),
        ORKTextChoice(text: "Find a shrubbery", value: 2 as NSNumber )
        ]
    let questionAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: textChoices)
    let questionStep = ORKQuestionStep(identifier: "TextChoiceQuestionStep", title: questionStepTitle, question: questionStepQuestion, answer: questionAnswerFormat)
    steps += [questionStep]

    let imageQuestionStepTitle = "Choose an image"
    let imageQuestionStepDetail =  "Detailed question 3: Here goes the detailed question"
    let imageTuples = [
    (#imageLiteral(resourceName: "Google logo"), "Google"),
    (#imageLiteral(resourceName: "user logo"), "Person"),
    (#imageLiteral(resourceName: "icon - medical"), "Doctor"),
    ]
    let imageChoices: [ORKImageChoice] = imageTuples.map {
      return ORKImageChoice(normalImage: $0.0, selectedImage: nil, text: $0.1, value: $0.1 as NSString)
    }
    let imageAnswerFormat: ORKImageChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: imageChoices, style: .singleChoice, vertical: true)
    let imageQuestionStep = ORKQuestionStep(identifier: "ImageChoiceQuestion", title: imageQuestionStepTitle, question: imageQuestionStepDetail, answer: imageAnswerFormat)
    steps += [imageQuestionStep]

    let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
    summaryStep.title = "Right. Off you go!"
    summaryStep.text = "That was easy!"
    steps += [summaryStep]

    return ORKOrderedTask(identifier: "SurveyTask", steps: steps)

}
