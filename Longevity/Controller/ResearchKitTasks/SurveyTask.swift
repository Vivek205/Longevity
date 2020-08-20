//
//  SurveyTask.swift
//  Longevity
//
//  Created by vivek on 18/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import ResearchKit


class SurveyTaskUtility {
    static var surveyId:String?
    static var currentSurveyDetails: SurveyDetails?
    static var currentTask: ORKOrderedTask?
    static var currentSurveyResult: [String:String] = [String:String]() // [QuestionId:Answer]
    static var surveyName: String? = {
        return SurveyTaskUtility.currentSurveyDetails?.name
    }()
    static var iconNameForModuleName: [String: String?] = [String:String?]()
    static var lastSubmission: String?
    static var lastSubmissionId: String?
    static var lastResponse: [SurveyLastResponseData]?

    static var surveyTagline: String? = {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E.MMM.d"
        let date = dateFormatter.string(from: today)

        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()
        guard let userName = defaults.value(forKey: keys.name) as? String else { return nil }
        
        return "\(date) for \(userName)"
    }()

    func createSurvey(surveyId: String, completion: @escaping (_ task: ORKOrderedTask?) -> Void,
                      onFailure: @escaping (_ error: Error) -> Void) {
        SurveyTaskUtility.surveyId = surveyId
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

                for (categoryName, categoryValue) in category {

                    if(categoryValue.view == SurveyCategoryViewTypes.oneCategoryPerPage) {
                        let step = ORKFormStep(identifier: "\(categoryValue.id)",
                            title:surveyDetails?.name ?? "Survey",
                            text: categoryValue.description)
                        var items = [ORKFormItem]()

                        for module in categoryValue.modules {
                            for (moduleName, moduleValue) in module {
                                let sectionItem = ORKFormItem(sectionTitle: moduleName)
                                SurveyTaskUtility.iconNameForModuleName[moduleName] = moduleValue.iconName
                                sectionItem.placeholder = moduleValue.iconName
                                items += [sectionItem]

                                if  let filteredQuestions = surveyDetails?.questions
                                    .filter({ $0.categoryId == categoryValue.id && $0.moduleId == moduleValue.id}) {
                                    for filteredQuestion in filteredQuestions {

                                        var answerFormat: ORKAnswerFormat = ORKBooleanAnswerFormat(yesString: "Yes", noString: "No")

                                        if filteredQuestion.quesType == "TEXT" {
                                            answerFormat = ORKTextAnswerFormat()
                                        }

                                        let item = ORKFormItem(identifier: "\(filteredQuestion.quesId)",
                                            text: "\(filteredQuestion.text)", answerFormat: answerFormat)

                                        items += [item]
                                    }
                                }
                            }
                        }

    //                    let finalAnswerFormat = ORKTextAnswerFormat(maximumLength: 200)
    //                    let finalitem = ORKFormItem(identifier:"\(categoryName)-finalItem", text: "Any other symptoms",
    //                                                answerFormat: finalAnswerFormat )
    //                    items += [finalitem]

                        step.formItems = items
                        steps += [step]
                    } else {
                        for module in categoryValue.modules {
                            for (moduleName, moduleValue) in module {
                                if let filteredQuestions = surveyDetails?.questions.filter
                                    { $0.categoryId == categoryValue.id && $0.moduleId == moduleValue.id} as? [Question] {
                                    for filteredQuestion in filteredQuestions {

                                        if filteredQuestion.quesType == "CONTINUOUS_SCALE" {
                                            let answerFormat = ORKAnswerFormat.continuousScale(
                                                withMaximumValue: 150,minimumValue: 60, defaultValue: 98,
                                                maximumFractionDigits: 1, vertical: true,
                                                maximumValueDescription: (NSString(format:"120%@", "\u{00B0}") as String),
                                                minimumValueDescription: (NSString(format:"80%@", "\u{00B0}") as String))
                                            let questionStep = ORKQuestionStep(identifier: filteredQuestion.quesId, title: surveyDetails?.name ?? "Survey", question: filteredQuestion.text, answer: answerFormat)
                                            steps += [questionStep]
                                            continue
                                        }

                                        let step = createSingleChoiceQuestionStep(
                                            identifier: filteredQuestion.quesId,
                                            title: surveyDetails?.name ?? "Survey",
                                            question: filteredQuestion.text,
                                            additionalText: nil,
                                            choices: filteredQuestion.options.map {
                                                ORKTextChoice(text:$0.text ?? "",detailText:$0.description ,
                                                              value:NSString(string:  $0.value ?? ""), exclusive: false)
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

        getSurveyDetails(surveyId: surveyId, completion: onGetQuestionCompletion(_:),
                         onFailure: onGetQuestionFailure(_:))
    }

    func completeSurvey(completion: @escaping ()-> Void, onFailure: @escaping (_ error: Error) -> Void) {

        func getSurveysCompletion(_ surveys:[SurveyResponse]) {
            completion()
        }

        func onGetSurveysFailure(_ error:Error) {
            onFailure(error)
        }

        func onSubmitCompletion() {
            print("survey submitted successfully")
            getSurveys(completion: getSurveysCompletion(_:), onFailure: onGetSurveysFailure(_:))

        }
        func onSubmitFailure(_ error: Error) {
            print("submit survey error", error)
            onFailure(error)
        }
        func onSaveCompletion() {
            print("survey saved successfully")
            submitSurvey(surveyId: SurveyTaskUtility.surveyId!,
                         completion: onSubmitCompletion, onFailure: onSubmitFailure(_:))
        }
        func onSaveFailure(_ error: Error) {
            print("save survey error", error)
            onFailure(error)
        }

        self.saveCurrentSurvey(completion: onSaveCompletion, onFailure: onSaveFailure(_:))
    }

    func clearSurvey() {
        SurveyTaskUtility.surveyId = nil
        SurveyTaskUtility.currentSurveyDetails = nil
        SurveyTaskUtility.currentTask = nil
        SurveyTaskUtility.currentSurveyResult = [String:String]()
        SurveyTaskUtility.surveyName = nil
        SurveyTaskUtility.iconNameForModuleName = [String:String]()
        print("survey data cleared successfully")
    }

    func saveCurrentSurvey(completion:@escaping ()->Void, onFailure:@escaping (_ error:Error)->Void) {
        let payload = SurveyTaskUtility.currentSurveyResult.map { (result) -> SubmitAnswerPayload  in
            let (questionId, answer) = result
            let questionDetails = SurveyTaskUtility.currentSurveyDetails?.questions.first {$0.quesId == questionId}

            return SubmitAnswerPayload(categoryId: questionDetails!.categoryId,
                                                      moduleId: questionDetails!.moduleId,
                                                      answer: answer,
                                                      quesId: questionId)
        }
        saveSurveyAnswers(surveyId: SurveyTaskUtility.surveyId!, answers: payload,
                          completion: completion, onFailure: onFailure)
    }

    func createSingleChoiceQuestionStep(identifier: String,title:String,
                                        question: String,additionalText:String?,
                                        choices:[ORKTextChoice]) -> ORKQuestionStep {
        let questionStepTitle = title
        let questionStepQuestion = question
        let textChoices = choices
        let questionAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: textChoices)

        let questionStep = ORKQuestionStep(identifier: identifier, title: questionStepTitle, question: questionStepQuestion, answer: questionAnswerFormat)

        questionStep.text = additionalText
        return questionStep
    }
}
