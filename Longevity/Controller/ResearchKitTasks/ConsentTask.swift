//
//  ConsentTask.swift
//  Longevity
//
//  Created by vivek on 18/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import ResearchKit


public var consentTask: ORKOrderedTask {
    var steps = [ORKStep]()

    var consentDocument = ORKConsentDocument()
    consentDocument.title = "Example Consent"
    consentDocument.signaturePageTitle = "Consent Signature"
    consentDocument.signaturePageContent = "I agree to participate in the research study"

    let consentSectionTypes: [ORKConsentSectionType] = [
    .overview,
    .dataGathering,
    .privacy,
    .dataUse,
    .timeCommitment,
    .studySurvey,
    .studyTasks,
    .withdrawing
    ]

    var consentSections: [ORKConsentSection] = consentSectionTypes.map { (consentSectionType) -> ORKConsentSection in
        let consentSection = ORKConsentSection(type: consentSectionType)
        consentSection.summary = "If you wish to complete this study..."
        consentSection.content = "In this study you will be asked five (wait, no, three!) questions. You will also have your voice recorded for ten seconds."
        return consentSection
    }

    consentDocument.sections = consentSections

    let visualConsentStep = ORKVisualConsentStep(identifier: "VisualConsentStep", document: consentDocument)
    steps += [visualConsentStep]

//    let signature = consentDocument.signatures!.first! as! ORKConsentSignature
    let signature = ORKConsentSignature(forPersonWithTitle: "Paticipant", dateFormatString: nil, identifier: "ParicipantSignature")
    consentDocument.addSignature(signature)
//    let signature = (consentDocument.signatures?.first)! as ORKConsentSignature
    let consentReviewStep = ORKConsentReviewStep(identifier: "ConsentReviewStep", signature: signature, in: consentDocument)
    consentReviewStep.text = "Review Consent !"
    consentReviewStep.reasonForConsent = "Consent to Join the Study"
    steps += [consentReviewStep]

    return ORKOrderedTask(identifier: "ConsentTask", steps: steps)
}
