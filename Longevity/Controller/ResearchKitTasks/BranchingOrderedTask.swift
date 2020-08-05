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

        guard step != nil else {
            return self.steps[0]
        }

        if step is ORKInstructionStep || step is ORKCompletionStep {
            return super.step(after: step, with: result)
        }

        if let firstTestResult = result.stepResult(forStepIdentifier: step?.identifier ?? "") {

            guard step?.identifier == "abc111" else {
                return super.step(after: step, with: result)
            }

            guard let currentStepIndex: Int? = Int(self.index(of: step!)) else { return super.step(after: step, with: result) }

            // navigate to the very next step
            var nextStep = self.steps[currentStepIndex! + 1]

            if let choiceQuestionResults = firstTestResult.results as? [ORKChoiceQuestionResult] {

                if choiceQuestionResults.isEmpty {
                    return nextStep
                }
                let latestResult = choiceQuestionResults.last

                let latestAnswer = latestResult?.answer
                print("latest Answer", latestAnswer)
                let decoder = NSCoder()
                let answerValue = latestResult?.choiceAnswers?.first as! NSNumber

                    print(answerValue.intValue)

                print("answerValue", latestResult?.choiceAnswers, type(of: latestResult?.choiceAnswers?.first))
                let nextStepIdentifier = findNextQuestion(questionId: step?.identifier ?? "", answerValue: answerValue.intValue)

                print("nextStepIdentifier", nextStepIdentifier)

                    // navigate to appropriate step
                    nextStep = self.steps.first { $0.identifier == nextStepIdentifier}!
                    var nextStep = nextStep

            }
            return nextStep
        }
        return super.step(after: step, with: result)
    }



    func setVisibleStep(_ identifier: String, when predicates: [NSPredicate]) {
        visibilityPredicates[identifier] = predicates
    }

    private func visibleStep(after stepIdentifier: String, with result: ORKTaskResult, in steps: [ORKStep]) -> ORKStep? {
        var shouldFindNextVisibleStep = false
        for thisStep in steps {
            if thisStep.identifier == stepIdentifier {
                shouldFindNextVisibleStep = true
            } else {
                continue
            }
            if shouldFindNextVisibleStep && isVisibleStep(thisStep.identifier, with: result){
                return self.step(withIdentifier: thisStep.identifier)
            }
        }

        // Branching Ordered Task is invalid. Your first and last steps should always be visible
        // Recommend that your task always ends in an ORKCompletionStep. Your task could start
        // with an ORKInstructionStep
        return nil
    }

    private func isVisibleStep(_ stepIdentifer: String, with result: ORKTaskResult) -> Bool {
        // Logic is very similar to ORKStepNavigationRule.identifierForDestinationStepWithTaskResult(...)
        let allTaskResults = NSArray(objects: result)
        guard let predicates = visibilityPredicates[stepIdentifer] else {
            // if a step has no predicates then it is always visible
            return true
        }
        // step is visible if all predicates evaluate to true
        var allPredicatesMatched = true
        for predicate in predicates {
            if predicate.evaluate(with: allTaskResults) == false {
                allPredicatesMatched = false
                break
            }
        }
        return allPredicatesMatched
    }


}
