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
    static let shared = SurveyTaskUtility()
    private var surveyList:[SurveyListItem]?
    var repetitiveSurveyList: DynamicValue<[SurveyListItem]>
    var oneTimeSurveyList: DynamicValue<[SurveyListItem]>
    var surveyInProgress: DynamicValue<[String: CheckInStatus]>
    var suppressAlert: Bool = false
    var openResultView: Bool = false
    let feelingTodayQuestionId = "3010"
    var coughTestFolderName: String = ""
    let symptomsCategory = "100"
    var isSymptomsSkipped: Bool = false {
        didSet {
            if self.isSymptomsSkipped {
                guard let currentSurveyId = self.currentSurveyId,
                      var savedAnswers = self.localSavedAnswers[currentSurveyId],
                      let symptomsQuestions = self.formQuestions[currentSurveyId]?[symptomsCategory]
                else {return}
                let filteredAnswers = savedAnswers.filter({ (quesId,answer) -> Bool in
                    return !symptomsQuestions.contains(quesId)
                })
                self.localSavedAnswers[currentSurveyId] = filteredAnswers
            }
        }
    }
    var formQuestions:[String:[String:[String]]] = [String:[String:[String]]]()
    
    private override init() {
        self.surveyInProgress = DynamicValue([String: CheckInStatus]())
        self.repetitiveSurveyList = DynamicValue([SurveyListItem]())
        self.oneTimeSurveyList = DynamicValue([SurveyListItem]())
    }
    
    var currentSurveyId: String? {
        didSet {
            guard let surveyId = self.currentSurveyId else { return }
            self.surveyName = self.surveyDetails[surveyId]??.name
        }
    }
    var surveyDetails: [String:SurveyDetails?] = [String:SurveyDetails?]()
    private var currentTask: ORKOrderedTask?
    var surveyName: String?
    private var iconNameForModuleName: [String: String?] = [String:String?]()
    private var lastSubmission: String?
    private var lastSubmissionId: String?
    private var lastResponse: [SurveyLastResponseData]?
    var localSavedAnswers:[String:[String:String]] = [String:[String:String]]()
    private var serverSubmittedAnswers:[String:[SurveyLastResponseData]] = [String:[SurveyLastResponseData]]()
    var traversedQuestions: [String:[String]] = [String:[String]]()

    private var fileNameForModuleName: [String: String?] = [String:String?]()
    private var recordingLengthForModuleName: [String: Int?] = [String:Int?]()
    
    
    func createSurvey(surveyId: String?, completion: @escaping (_ task: ORKOrderedTask?) -> Void,
                      onFailure: @escaping (_ error: Error) -> Void) {
        enum CreateSurveyError: Error {
            case surveyIdNotFound
        }
        
        var surveyid: String?
        
        if surveyId == nil && !(self.oneTimeSurveyList.value?.isEmpty ?? true) {
            surveyid = self.oneTimeSurveyList.value?[0].surveyId
        } else {
            surveyid = surveyId
        }
        
        guard let surveyId = surveyid else {return onFailure(CreateSurveyError.surveyIdNotFound)}
        func onGetQuestionCompletion(_ surveyDetails: SurveyDetails?) -> Void {
            guard surveyDetails != nil else { return completion(nil) }
            
            if surveyDetails!.surveyId.starts(with: Strings.coughTest) {
                SurveyTaskUtility.shared.coughTestFolderName = "COUGH_TEST_\(UUID().uuidString)"
            }
            
            var steps = [ORKStep]()
            
            let instructionStep = ORKInstructionStep(identifier: "IntroStep")
            instructionStep.title = surveyDetails?.name
            instructionStep.text = surveyDetails?.description.longDescription   
            steps += [instructionStep]

            let categories = surveyDetails!.displaySettings.categories
            self.formQuestions[surveyId] = [String:[String]]()
            for category in categories {

                for (categoryName, categoryValue) in category {
                    if(categoryValue.view == SurveyCategoryViewTypes.oneCategoryPerPage) {
                        let step = ORKFormStep(identifier: "\(categoryValue.id)",
                                               title:surveyDetails?.name ?? "Survey",
                                               text: categoryValue.description)
                        var items = [ORKFormItem]()
                        self.formQuestions[surveyId]?["\(categoryValue.id)"] = []
                        for module in categoryValue.modules {
                            for (moduleName, moduleValue) in module {
                                let sectionItem = ORKFormItem(sectionTitle: moduleName)
                                SurveyTaskUtility.shared.setIconName(for: moduleName, iconName: moduleValue.iconName)
                                
                                if moduleValue.iconName != nil {
                                    sectionItem.placeholder = moduleValue.iconName
                                    items += [sectionItem]
                                }

                                if  let filteredQuestions = surveyDetails?.questions
                                        .filter({ $0.categoryId == categoryValue.id && $0.moduleId == moduleValue.id}) {
                                    for filteredQuestion in filteredQuestions {
                                        self.formQuestions[surveyId]?["\(categoryValue.id)"]?.append(filteredQuestion.quesId)
                                        var answerFormat: ORKAnswerFormat = ORKBooleanAnswerFormat(yesString: "Yes", noString: "No")

                                        if filteredQuestion.quesType == .text {
                                            answerFormat = ORKTextAnswerFormat()
                                        } else if filteredQuestion.quesType == .location {
                                            answerFormat = ORKLocationAnswerFormat()
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
                                        if let questionStep = self.createQuestionStep(moduleId: "\(moduleValue.id)", question: filteredQuestion) {
                                            steps += [questionStep]
                                        }
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

        SurveysAPI.instance.get(surveyId: surveyId) { (surveyDetails) in
            guard let surveyDetails = surveyDetails else {
                return
            }
            onGetQuestionCompletion(surveyDetails)
        }
    }

    func createQuestionStep(moduleId: String, question:Question) -> ORKQuestionStep? {
        switch question.quesType {
        case .continuousScale, .temperatureScale:
            let answerFormat = ORKAnswerFormat.continuousScale(
                withMaximumValue: 150,minimumValue: 60, defaultValue: 98,
                maximumFractionDigits: 1, vertical: true,
                maximumValueDescription: "",
                minimumValueDescription: "")
            let questionStep = ORKQuestionStep(identifier: question.quesId,
                                               title: moduleId,
                                               question: question.text,
                                               answer: answerFormat)
            return questionStep
        case .text:
            let answerFormat = ORKAnswerFormat.textAnswerFormat()
            let questionStep = ORKQuestionStep(identifier: question.quesId, title: moduleId,
                                               question: question.text, answer: answerFormat)
            return questionStep
        case .valuePicker:
            let textChoices: [ORKTextChoice] = question.options.map{
                return ORKTextChoice(text: $0.text ?? "", value: NSString(string: $0.value ?? "") )
            }

            let answerFormat = ORKValuePickerAnswerFormat(textChoices: textChoices)
            let questionStep = ORKQuestionStep(identifier: question.quesId, title: moduleId, question: question.text, answer: answerFormat)
            return questionStep
        case .speechRecognition:
            let answerFormat = ORKLocationAnswerFormat()
            let speechQuestion = ORKQuestionStep(identifier: question.quesId, title: moduleId, question: question.text, answer: answerFormat)
            speechQuestion.text = question.otherDetails?.fileName
            speechQuestion.tagText = String(question.otherDetails?.recordingLength ?? 0.0)
            return speechQuestion
        default:
            let questionStep = createSingleChoiceQuestionStep(
                identifier: question.quesId,
                title: moduleId,
                question: question.text,
                additionalText: nil,
                choices: question.options.map {
                    ORKTextChoice(text:$0.text ?? "",detailText:$0.description ,
                                  value:NSString(string:  $0.value ?? ""), exclusive: false)
                }
            )
            return questionStep
        }
    }


    func completeSurvey(completion: @escaping () -> Void, onFailure: @escaping (_ error: Error) -> Void) {
        func onSubmitCompletion() {
            print("survey submitted successfully")
            AppSyncManager.instance.refreshActivites.value = true
            self.clearSurvey()
            AppSyncManager.instance.syncSurveyList()
            completion()
        }
        
        func onSubmitFailure(_ error: Error) {
            print("submit survey error", error)
            onFailure(error)
        }
        func onSaveCompletion() {
            print("survey saved successfully")
            SurveysAPI.instance.submitSurvey(surveyId: SurveyTaskUtility.shared.currentSurveyId,
                                             completion: onSubmitCompletion, onFailure: onSubmitFailure(_:))
        }
        func onSaveFailure(_ error: Error) {
            print("save survey error", error)
            onFailure(error)
        }
        self.saveCurrentSurvey(completion: onSaveCompletion, onFailure: onSaveFailure(_:))
    }

    func clearSurvey() {
        guard let currentSurveyId = self.currentSurveyId else {return}
        self.currentTask = nil
        self.localSavedAnswers[currentSurveyId] = [String:String]()
        self.iconNameForModuleName = [String:String]()
        self.traversedQuestions[currentSurveyId] = [String]()
        self.currentSurveyId = nil
        self.isSymptomsSkipped = false
        print("survey data cleared successfully")
    }

    func saveCurrentSurvey(completion:@escaping () -> Void, onFailure:@escaping (_ error:Error)->Void) {
        guard let currentSurveyId = self.currentSurveyId,
              let localSavedAnswers = self.localSavedAnswers[currentSurveyId] else {return}

        let payload = localSavedAnswers.map { (result) -> SubmitAnswerPayload  in
            let (questionId, answer) = result
            let questionDetails = SurveyTaskUtility.shared.getCurrentSurveyDetails()?.questions.first {$0.quesId == questionId}

            return SubmitAnswerPayload(categoryId: questionDetails!.categoryId,
                                       moduleId: questionDetails!.moduleId,
                                       answer: answer,
                                       quesId: questionId)
        }
        
        
        
        
        SurveysAPI.instance.saveSurveyAnswers(surveyId: SurveyTaskUtility.shared.currentSurveyId, answers: payload,
                                              completion: completion, onFailure: onFailure)
    }

    func getCurrentSurveyLocalAnswer(questionIdentifier:String) -> String? {
        guard let currentSurveyId = self.currentSurveyId else {return nil}
        let localAnswer = self.localSavedAnswers[currentSurveyId]?[questionIdentifier]
        return localAnswer
    }

    func setCurrentSurveyLocalAnswer(questionIdentifier:String, answer:String) {
        guard let currentSurveyId = self.currentSurveyId else {
            return
        }
        if self.localSavedAnswers[currentSurveyId] == nil {
            return self.localSavedAnswers[currentSurveyId] = [questionIdentifier: answer]
        }
        self.localSavedAnswers[currentSurveyId]?[questionIdentifier] = answer
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

    func isCurrentSurveyRepetitive() -> Bool? {
        guard let currentSurveyDetails = self.getCurrentSurveyDetails() else {return nil}
        return currentSurveyDetails.isRepetitive
    }

    func setSurveyList(list:[SurveyListItem]) {
        self.surveyList = list
        self.setSurveyStatus()
        self.repetitiveSurveyList.value = list.filter({ $0.isRepetitive == true })
        self.oneTimeSurveyList.value = list.filter({ $0.isRepetitive != true })
    }
    
    func isTaskCompletedToday(task: SurveyListItem) -> Bool {
        if let lastSubmission = task.lastSubmission, !lastSubmission.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // referring to the timezon of the date provided for comparision

            if let lastSubmissionDate = dateFormatter.date(from: lastSubmission){
                var calendar = Calendar.current
                calendar.timeZone = .current // referring to the local timezone to be checked against
                if calendar.isDateInToday(lastSubmissionDate) {
                    return true
                } else {
                    return false
                }
            }
        }
        return false
    }

    func setServerSubmittedAnswers(list: [SurveyListItem]) {
        self.serverSubmittedAnswers = list.filter({
            $0.response != nil
        }).reduce(into: [:], { (dict, listitem) in
            dict[listitem.surveyId] = listitem.response!
        })
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
        switch question.action {
        case .dynamic:
            return true
        default:
            return false
        }
        //        return question.action == QuestionAction.dynamic
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

    func addTraversedQuestion(questionId: String?) {
        guard let currentSurveyId = self.currentSurveyId,
              let questionId = questionId
        else { return }

        guard let currentSurveyTraversedQuestions = self.traversedQuestions[currentSurveyId] else {
            self.traversedQuestions[currentSurveyId] = [questionId]
            return
        }

        if !currentSurveyTraversedQuestions.contains(questionId) {
            self.traversedQuestions[currentSurveyId]?.append(questionId)
        } else {
            guard let currentQuestionIndex = currentSurveyTraversedQuestions.firstIndex(of: questionId),
                  currentQuestionIndex+1 >= self.traversedQuestions.count
            else {return}
            let slicedArray = Array(currentSurveyTraversedQuestions.prefix(upTo:(currentQuestionIndex+1)))
            print("slicedArray", slicedArray)
            self.traversedQuestions[currentSurveyId] = slicedArray
        }
        print("traversedQuestions", traversedQuestions)
    }
    
    func findPrevQuestion(currentQuestionId: String) -> String?{
        guard let currentSurveyId = self.currentSurveyId,
              let currentSurveyTraversedQuestions = self.traversedQuestions[currentSurveyId]
        else {return nil}
        if let currentQuestionIndex = currentSurveyTraversedQuestions.firstIndex(of: currentQuestionId),
           currentQuestionIndex != 0
        {
            return currentSurveyTraversedQuestions[currentQuestionIndex - 1]
        }
        return currentSurveyTraversedQuestions.last
    }

    func resumeTaskWithLastQuestion() -> String? {
        guard let currentSurveyId = self.currentSurveyId,
              let currentSurveyTraversedQuestions = self.traversedQuestions[currentSurveyId]
        else {return nil}
        return currentSurveyTraversedQuestions.last
    }

    func isFirstStep(stepId: String?) -> Bool {
        guard let stepId = stepId,
              !stepId.isEmpty,
              let surveyDetails = self.getCurrentSurveyDetails()
        else { return false }
        var firstStepId = ""
        let categories = surveyDetails.displaySettings.categories

        guard let firstCategory = categories.first else {return false}

        for (_, categoryValue) in firstCategory {
            if categoryValue.view == SurveyCategoryViewTypes.oneCategoryPerPage {
                firstStepId = "\(categoryValue.id)"
            } else {
                guard let firstModule = categoryValue.modules.first else {return false}
                for (_, moduleValue) in firstModule {
                    let filteredQuestions = surveyDetails.questions.filter({ $0.categoryId == categoryValue.id
                                                            && $0.moduleId == moduleValue.id})
                    if let firstQuestion = filteredQuestions.first {
                        firstStepId = firstQuestion.quesId
                    } else { return false }
                }
            }
        }
        return stepId == firstStepId
    }

    func getLastSubmissionID(for surveyId: String) -> String?  {
        guard let surveyItem = self.surveyList?.first(where: { (item) -> Bool in
            return item.surveyId == surveyId
        }) else {
            return nil
        }
        return surveyItem.lastSubmissionId
    }
}


extension SurveyTaskUtility {
    func containsInprogress() -> Bool {
        if let statuses = self.surveyInProgress.value {
            return statuses.contains(where: { $0.value == .pending })
        }
       return false
    }
    
    func setSurveyStatus() {
        if let list = self.surveyList, !list.isEmpty {
            list.forEach({ (survey) in
                if let status = self.surveyInProgress.value?[survey.surveyId],
                   status == .pending, survey.lastSurveyStatus != .pending {
                    if !self.suppressAlert {
                        DispatchQueue.main.async {
                            let viewResultsAction = UIAlertAction(title: "View Results", style: .default) { [unowned self] (action) in
                                guard let submissionID = survey.lastSubmissionId else { return }
                                self.doOpenResult(submissionID: submissionID)
                            }
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            Alert(title: "Risk Siginals Updated", message: "Your results are available and also saved in \"My Data\"", actions: viewResultsAction, okAction)
                        }
                    } else {
                        if survey.surveyId.starts(with: Strings.coughTest) && self.openResultView {
                            DispatchQueue.main.async {
                                guard let submissionID = survey.lastSubmissionId else { return }
                                let checkInResultViewController = CoughTestResultViewController(submissionID: submissionID)
                                checkInResultViewController.delegate = self
                                NavigationUtility.presentOverCurrentContext(destination: checkInResultViewController,
                                                                            style: .overCurrentContext)
                            }
                        }
                    }
                }
                self.surveyInProgress.value?[survey.surveyId] = survey.lastSurveyStatus
            })
        }
    }
    
    func setStatus(surveyId: String) {
        self.surveyInProgress.value?[surveyId] = .unknown
    }
    
    func setProcessedStatus(surveyId: String) {
        self.surveyInProgress.value?[surveyId] = .completed
    }
    
    func getLastSubmissionStatus(surveyId: String) -> CheckInStatus {
        guard let survey = self.surveyList?.first(where: { $0.surveyId == surveyId }) else { return .unknown }
        return survey.lastSurveyStatus
    }
    
    func doOpenResult(submissionID: String, isdelegated: Bool = false) {
        SurveyTaskUtility.shared.suppressAlert = true
        UserInsightsAPI.instance.getLog(submissionID: submissionID) { [unowned self] (checkinlog) in
            guard let loghistory = checkinlog?.details?.history else {
                SurveyTaskUtility.shared.suppressAlert = false
                DispatchQueue.main.async {
                    let okAction = UIAlertAction(title: "OK", style: .default) { [unowned self] (action) in
                        self.resultViewDismissed()
                    }
                    Alert(title: "Error", message: "Error occurred while fetching the result. Please check Results Data Log for updates later.", action: okAction)
                }
                return
            }
            guard let result = loghistory.first else { return }
            DispatchQueue.main.async {
                if result.surveyID?.starts(with: Strings.coughTest) ?? false {
                    let coughTestResultView = CoughTestResultViewController()
                    coughTestResultView.coughResult = result
                    if isdelegated {
                        coughTestResultView.delegate = self
                    }
                    NavigationUtility.presentOverCurrentContext(destination: coughTestResultView,
                                                                style: .overCurrentContext) {
                        SurveyTaskUtility.shared.suppressAlert = false
                    }
                } else {
                    let checkInResultViewController = CheckInResultViewController(checkinResult: result)
                    NavigationUtility.presentOverCurrentContext(destination: checkInResultViewController,
                                                                style: .overCurrentContext) {
                        SurveyTaskUtility.shared.suppressAlert = false
                    }
                }
            }
        }
    }
}

extension SurveyTaskUtility : CoughTestResultViewDelegate {
    func resultViewDismissed() {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentingViewController = topController.presentingViewController {
                topController = presentingViewController
            }
            topController.dismiss(animated: false, completion: nil)
        }
    }
}

extension Array {
    func copiedElements() -> Array<Element> {
        return self.map{
            let copiable = $0 as! NSCopying
            return copiable.copy() as! Element
        }
    }
}
