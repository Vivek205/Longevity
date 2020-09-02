//
//  SurveyTask.swift
//  Longevity
//
//  Created by vivek on 18/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import ResearchKit

fileprivate let defaultModuleIconName:String = "icon : GI"

fileprivate let appSyncmanager:AppSyncManager = AppSyncManager.instance

final class SurveyTaskUtility: NSObject {
    private override init() {}
    static let shared = SurveyTaskUtility()
    private var surveyList:[SurveyListItem]?
    var repetitiveSurveyList:[SurveyListItem] = [SurveyListItem]()
    var oneTimeSurveyList:[SurveyListItem] = [SurveyListItem]()
    var currentSurveyId: String? {
        didSet {
            guard let surveyId = self.currentSurveyId else { return }
            self.surveyName = self.surveyDetails[surveyId]??.name
        }
    }
    private var surveyDetails: [String:SurveyDetails?] = [String:SurveyDetails?]()
    private var currentTask: ORKOrderedTask?
    var surveyName: String?
    private var iconNameForModuleName: [String: String?] = [String:String?]()
    private var lastSubmission: String?
    private var lastSubmissionId: String?
    private var lastResponse: [SurveyLastResponseData]?
    private var localSavedAnswers:[String:[String:String]] = [String:[String:String]]()//[SurveyId:[QuestionId:Answer]]
    private var serverSubmittedAnswers:[String:[SurveyLastResponseData]] = [String:[SurveyLastResponseData]]()

    var surveyTagline: String? {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E.MMM.d"
        let date = dateFormatter.string(from: today)

        guard let userName = appSyncmanager.userProfile.value?.email else { return nil }
        return "\(date) for \(userName)"
    }

    func createSurvey(surveyId: String?, completion: @escaping (_ task: ORKOrderedTask?) -> Void,
                      onFailure: @escaping (_ error: Error) -> Void) {
        enum CreateSurveyError: Error {
            case surveyIdNotFound
        }
        guard let surveyId = surveyId else {return onFailure(CreateSurveyError.surveyIdNotFound)}
        func onGetQuestionCompletion(_ surveyDetails: SurveyDetails?) -> Void {
            guard surveyDetails != nil else { return completion(nil) }
            var steps = [ORKStep]()
            let instructionStep = ORKInstructionStep(identifier: "IntroStep")
            instructionStep.title = "Intro: \(surveyDetails!.name) Survey"
            instructionStep.text = surveyDetails?.description
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
                                SurveyTaskUtility.shared.setIconName(for: moduleName, iconName: moduleValue.iconName)
                                //                                SurveyTaskUtility.iconNameForModuleName[moduleName] = moduleValue.iconName
                                sectionItem.placeholder = moduleValue.iconName
                                items += [sectionItem]

                                if  let filteredQuestions = surveyDetails?.questions
                                    .filter({ $0.categoryId == categoryValue.id && $0.moduleId == moduleValue.id}) {
                                    for filteredQuestion in filteredQuestions {

                                        var answerFormat: ORKAnswerFormat = ORKBooleanAnswerFormat(yesString: "Yes", noString: "No")

                                        if filteredQuestion.quesType == .text {
                                            answerFormat = ORKTextAnswerFormat()
                                        }

                                        let item = ORKFormItem(identifier: "\(filteredQuestion.quesId)",
                                            text: "\(filteredQuestion.text)", answerFormat: answerFormat)

                                        items += [item]
                                    }
                                }
                            }
                        }
                        step.formItems = items
                        steps += [step]
                    } else {
                        for module in categoryValue.modules {
                            for (moduleName, moduleValue) in module {
                                if let filteredQuestions = surveyDetails?.questions.filter
                                    { $0.categoryId == categoryValue.id && $0.moduleId == moduleValue.id} as? [Question] {
                                    for filteredQuestion in filteredQuestions {

                                        if filteredQuestion.quesType == .continuousScale {
                                            let answerFormat = ORKAnswerFormat.continuousScale(
                                                withMaximumValue: 150,minimumValue: 60, defaultValue: 98,
                                                maximumFractionDigits: 1, vertical: true,
                                                maximumValueDescription: (NSString(format:"120%@", "\u{00B0}") as String),
                                                minimumValueDescription: (NSString(format:"80%@", "\u{00B0}") as String))
                                            let questionStep = ORKQuestionStep(identifier: filteredQuestion.quesId,
                                                                               title: "\(moduleValue.id)",
                                                                               question: filteredQuestion.text,
                                                                               answer: answerFormat)
                                            steps += [questionStep]
                                            continue
                                        }

                                        if filteredQuestion.quesType == .text {
                                            let answerFormat = ORKAnswerFormat.textAnswerFormat()
                                            let questionStep = ORKQuestionStep(identifier: filteredQuestion.quesId, title: "\(moduleValue.id)", question: filteredQuestion.text, answer: answerFormat)
                                            steps += [questionStep]
                                            continue
                                        }

                                        let step = createSingleChoiceQuestionStep(
                                            identifier: filteredQuestion.quesId,
                                            title: "\(moduleValue.id)",
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

    func completeSurvey(completion: @escaping () -> Void, onFailure: @escaping (_ error: Error) -> Void) {
        func getSurveysCompletion(_ surveys:[SurveyListItem]) {
            completion()
        }
        func onGetSurveysFailure(_ error:Error) {
            onFailure(error)
        }
        func onSubmitCompletion() {
            print("survey submitted successfully")
            getSurveys(completion: getSurveysCompletion(_:), onFailure: onGetSurveysFailure(_:))
            self.clearSurvey()
        }
        func onSubmitFailure(_ error: Error) {
            print("submit survey error", error)
            onFailure(error)
        }
        func onSaveCompletion() {
            print("survey saved successfully")
            submitSurvey(surveyId: SurveyTaskUtility.shared.currentSurveyId,
                         completion: onSubmitCompletion, onFailure: onSubmitFailure(_:))
        }
        func onSaveFailure(_ error: Error) {
            print("save survey error", error)
            onFailure(error)
        }
        self.saveCurrentSurvey(completion: onSaveCompletion, onFailure: onSaveFailure(_:))
    }

    func clearSurvey() {
        self.currentSurveyId = nil
        self.currentTask = nil
        self.localSavedAnswers = [String:[String:String]]()
        self.iconNameForModuleName = [String:String]()
        print("survey data cleared successfully")
    }

    func saveCurrentSurvey(completion:@escaping () -> Void, onFailure:@escaping (_ error:Error)->Void) {
        guard let currentSurveyId = self.currentSurveyId else {return}
        guard let localSavedAnswers = self.localSavedAnswers[currentSurveyId] else {return}
        let payload = localSavedAnswers.map { (result) -> SubmitAnswerPayload  in
            let (questionId, answer) = result
            let questionDetails = SurveyTaskUtility.shared.getCurrentSurveyDetails()?.questions.first {$0.quesId == questionId}

            return SubmitAnswerPayload(categoryId: questionDetails!.categoryId,
                                       moduleId: questionDetails!.moduleId,
                                       answer: answer,
                                       quesId: questionId)
        }
        saveSurveyAnswers(surveyId: SurveyTaskUtility.shared.currentSurveyId, answers: payload,
                          completion: completion, onFailure: onFailure)
    }

    func getCurrentSurveyLocalAnswer(questionIdentifier:String) -> String? {
        guard let currentSurveyId = self.currentSurveyId else {return nil}
        return self.localSavedAnswers[currentSurveyId]?[questionIdentifier]
    }

    func setCurrentSurveyLocalAnswer(questionIdentifier:String, answer:String) {
        guard let currentSurveyId = self.currentSurveyId else {
            print("current survey id not found", self.currentSurveyId)
            return
        }
        print("current survey id", currentSurveyId)
        if self.localSavedAnswers[currentSurveyId] == nil {
            return self.localSavedAnswers[currentSurveyId] = [questionIdentifier: answer]
        }
        self.localSavedAnswers[currentSurveyId]![questionIdentifier] = answer
    }

    func getCurrentSurveyServerAnswer(questionIdentifier:String) -> String? {
        guard let currentSurveyId = self.currentSurveyId else {return nil}
        guard let currentSurveyServerAnswers = self.serverSubmittedAnswers[currentSurveyId] else {return nil}
        let serverAnswer = currentSurveyServerAnswers.first {$0.quesId == questionIdentifier}
        return serverAnswer?.answer
    }

    func getCurrentSurveyAnswerConsolidated(questionIdentifier:String) -> String? {
        guard let currentSurveyId = self.currentSurveyId else {return nil}
        if let localAnswer = self.localSavedAnswers[currentSurveyId]?[questionIdentifier] {
            return localAnswer
        }
        guard let currentSurveyServerAnswers = self.serverSubmittedAnswers[currentSurveyId] else {return nil}
        let serverAnswer = currentSurveyServerAnswers.first {$0.quesId == questionIdentifier}
        return serverAnswer?.answer
    }

    func saveCurrentSurveyAnswerLocally(questionIdentifier: String, answer: String) {
        guard let currentSurveyId = self.currentSurveyId else {return}
        self.localSavedAnswers[currentSurveyId]?[questionIdentifier] = answer
    }

    func getIconName(for moduleName: String) -> String {
        guard let iconName = self.iconNameForModuleName[moduleName] as? String else {return defaultModuleIconName}
        return iconName
    }

    func setIconName(for moduleName: String, iconName: String?) {
        self.iconNameForModuleName[moduleName] = iconName
    }

    func getCurrentSurveyName() -> String? {
        guard let currentSurveyDetails = self.getCurrentSurveyDetails() else {return nil}
        return currentSurveyDetails.name
    }

    func setSurveyList(list:[SurveyListItem]) {
        self.repetitiveSurveyList = [SurveyListItem]()
        self.oneTimeSurveyList = [SurveyListItem]()

        list.forEach { (survey) in
            if survey.isRepetitive == true {
                self.repetitiveSurveyList.append(survey)
            } else if survey.lastSubmission == nil{
                self.oneTimeSurveyList.append(survey)
            }
        }

    }

    func setServerSubmittedAnswers(for surveyId: String, answers:[SurveyLastResponseData]?) {
        guard (answers) != nil else {return}
        self.serverSubmittedAnswers[surveyId] = answers
    }

    func getCurrentSurveyDetails() -> SurveyDetails? {
        guard let currentSurveyId = self.currentSurveyId else {return nil}
        guard let currentSurveyDetails = self.surveyDetails[currentSurveyId] else {return nil}
        return currentSurveyDetails
    }

    func setSurveyDetails(for surveyId: String, details:SurveyDetails?) {
        self.surveyDetails[surveyId] = details
    }

    func getCurrentSurveyQuestionDetails(questionId: String) -> Question? {
        guard let surveyDetails = self.getCurrentSurveyDetails() else { return nil}
        guard let question = surveyDetails.questions.first(where: { (question) -> Bool in
            question.quesId == questionId
        }) else { return nil }
        return question
    }

    func findIsQuestionDynamic(questionId: String) -> Bool {
        guard let surveyDetails = self.getCurrentSurveyDetails() else { return false}
        guard let question = surveyDetails.questions.first(where: { (question) -> Bool in
            question.quesId == questionId
        }) else { return false }
        return question.action == QuestionAction.dynamic
    }

    func createSingleChoiceQuestionStep(identifier: String,title:String,
                                        question: String,additionalText:String?,
                                        choices:[ORKTextChoice]) -> ORKQuestionStep {
        if choices.isEmpty {
            print("empty choice")
        }
        let questionStepTitle = title
        let questionStepQuestion = question
        let textChoices = choices
        let questionAnswerFormat: ORKTextChoiceAnswerFormat =
            ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice,
                                               textChoices: textChoices)
        let questionStep = ORKQuestionStep(identifier: identifier, title: questionStepTitle,
                                           question: questionStepQuestion, answer: questionAnswerFormat)

        questionStep.text = additionalText
        return questionStep
    }
}
