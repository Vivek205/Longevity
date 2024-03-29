//
//  BranchingOrderedTask.swift
//  Longevity
//
//  Created by vivek on 24/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

class BranchingOrderedTask: ORKOrderedTask {
    public var visibilityPredicates = [String:[NSPredicate]]()

    override func step(after step: ORKStep?, with result: ORKTaskResult) -> ORKStep? {
        super.step(after: step, with: result)
        guard let currentStep = step else {
            if steps.isEmpty {
                return nil
            }
            if let lastTraversedQuestionId = SurveyTaskUtility.shared.resumeTaskWithLastQuestion() {
                return self.steps.first(where: { $0.identifier == lastTraversedQuestionId })
            }

            return steps[0]
        }

        if step is ORKInstructionStep {
            if step is ORKCompletionStep {
                return nil
            }
            return steps[1]
        }

        guard let currentStepIndex = Int(self.index(of: currentStep)) as? Int else { return nil }
        var nextStep = self.steps[currentStepIndex + 1]

        if nextStep is ORKCompletionStep {
            return nextStep
        }
        guard let identifier = step?.identifier else {return nextStep}
//        MARK :- START Skip Symptoms If user selects `No Symptoms`
        if identifier == SurveyTaskUtility.shared.feelingTodayQuestionId {
            guard let feelingTodayAnswer =
                SurveyTaskUtility.shared.getCurrentSurveyLocalAnswer(questionIdentifier: SurveyTaskUtility.shared.feelingTodayQuestionId) else {return nil}
                    if feelingTodayAnswer == "0" {
                        SurveyTaskUtility.shared.isSymptomsSkipped = true
                        return self.steps[currentStepIndex + 2]
                    } else {
                        SurveyTaskUtility.shared.isSymptomsSkipped = false
                    }
        }
//        MARK :- END Skip Symptoms If user selects `No Symptoms`
        let isDynamicQuestion = SurveyTaskUtility.shared.findIsQuestionDynamic(questionId: identifier)
        guard isDynamicQuestion else {
            return nextStep
        }

        let moduleId = step?.title
        let answer = SurveyTaskUtility.shared.getCurrentSurveyLocalAnswer(questionIdentifier: identifier)
        guard answer != nil, moduleId != nil else {
            return nextStep
        }
        
        if let nextStepIdentifier = SurveysAPI.instance.findNextQuestion(moduleId: Int(moduleId ?? ""),
                                                                         questionId: identifier,
                                                                         answerValue: answer!), !nextStepIdentifier.isEmpty {
            if let nextDynamicStep = self.steps.first(where: { $0.identifier == nextStepIdentifier }) {
                nextStep = nextDynamicStep
            }
        } else {
            nextStep = self.steps[self.steps.count - 1]
        }

        return nextStep
    }

    override func step(before step: ORKStep?, with result: ORKTaskResult) -> ORKStep? {
        super.step(before: step, with: result)
        guard let currentStep = step else {
            if steps.isEmpty { return nil }
            return steps[0]
        }
        
        let currentStepIndex: Int = Int(self.index(of: currentStep))

        if currentStep is ORKInstructionStep {
               return step
           }

        guard let locallyTraversedPrevStepIdentifier = SurveyTaskUtility.shared.findPrevQuestion(currentQuestionId: currentStep.identifier) else {
            return self.steps[currentStepIndex - 1]
        }
        return self.steps.first(where: { $0.identifier == locallyTraversedPrevStepIdentifier })
    }
}
