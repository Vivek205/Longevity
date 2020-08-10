//
//  SurveyTask.swift
//  Longevity
//
//  Created by vivek on 18/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import ResearchKit

func createSurvey(surveyId: String, completion: @escaping (_ task: ORKOrderedTask?) -> Void,
                  onFailure: @escaping (_ error: Error) -> Void) {
    print(surveyId)
    func onGetQuestionCompletion(_ surveyDetails: SurveyDetails?) -> Void {
        guard surveyDetails != nil else {
            completion(nil)
            return
        }

        var steps = [ORKStep]()

        let instructionStep = ORKInstructionStep(identifier: "IntroStep")
        instructionStep.title = "Intro: \(surveyDetails!.name) Survey"
        instructionStep.text = "Who would cross the Bridge of Death must answer me these questions three, ere the other side they see."
        steps += [instructionStep]

        let categories = surveyDetails!.displaySettings.categories

        for category in categories {
            print(type(of: category) ,category)
            for (categoryName, categoryValue) in category {
                print(categoryName, categoryValue)

                if(categoryValue.view == SurveyCategoryViewTypes.oneCategoryPerPage) {
                    print(SurveyCategoryViewTypes.oneCategoryPerPage)
                    let step = ORKFormStep(identifier: "\(categoryValue.id)", title: categoryName, text: "description text")
                    var items = [ORKFormItem]()

                    for module in categoryValue.modules {
                        for (moduleName, moduleValue) in module {
                            if  let filteredQuestions = surveyDetails?.questions
                                .filter({ $0.categoryId == categoryValue.id && $0.moduleId == moduleValue.id}) {
                                for filteredQuestion in filteredQuestions {
                                    let answerFormat = ORKBooleanAnswerFormat(yesString: "Yes", noString: "No")
                                    let item = ORKFormItem(identifier: "\(filteredQuestion.quesId)",
                                        text: "\(filteredQuestion.text)", answerFormat: answerFormat)
                                    items += [item]
                                }
                            }
                        }
                    }


                    let finalAnswerFormat = ORKTextAnswerFormat(maximumLength: 200)
                    let finalitem = ORKFormItem(identifier:"\(categoryName)-finalItem", text: "Any other symptoms",
                                                answerFormat: finalAnswerFormat )
                    items += [finalitem]

                    step.formItems = items
                    steps += [step]
                } else {
                    for module in categoryValue.modules {
                        print(module)
                        for (moduleName, moduleValue) in module {
                            print(moduleName, moduleValue)
                            if  let filteredQuestions = surveyDetails?.questions.filter
                                { $0.categoryId == categoryValue.id && $0.moduleId == moduleValue.id} as? [Question] {
                                for filteredQuestion in filteredQuestions {
                                    let step = createSingleChoiceQuestionStep(
                                        identifier: filteredQuestion.quesId,
                                        title: surveyDetails?.name ?? "Survey",
                                        question: filteredQuestion.text,
                                        additionalText: nil,
                                        choices: filteredQuestion.options.map {
                                            ORKTextChoice(text:$0.text,detailText:$0.description ,
                                                          value:NSString(string:  $0.value), exclusive: false)
                                        }
                                    )
                                    steps += [step]
                                }
                            }

                        }
                    }
                }
            }
        }

        let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
        summaryStep.title = "SummaryRight. Off you go!"
        summaryStep.text = "That was easy!"
        steps += [summaryStep]

        guard steps.count > 2 else {
            completion(nil)
            return
        }
        let task = BranchingOrderedTask(identifier: surveyId, steps: steps)
        completion(task)
    }
    func onGetQuestionFailure(_ error: Error) {
        onFailure(error)
    }

    getSurveyDetails(surveyId: surveyId, completion: onGetQuestionCompletion(_:), onFailure: onGetQuestionFailure(_:))
}

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


func createSingleChoiceQuestionStep(identifier: String,title:String, question: String,additionalText:String?, choices:[ORKTextChoice]) -> ORKQuestionStep {
    let questionStepTitle = title
    let questionStepQuestion = question
    let textChoices = choices
    let questionAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: textChoices)

    let questionStep = ORKQuestionStep(identifier: identifier, title: questionStepTitle, question: questionStepQuestion, answer: questionAnswerFormat)

    questionStep.text = additionalText
    return questionStep
}
