//
//  Questions.swift
//  Longevity
//
//  Created by vivek on 27/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import Amplify
import SwiftyJSON

struct SurveyLastResponseData: Decodable {
    let quesId: String
    let answer: String
    let submissionId: String
}

struct SurveyDescription: Decodable {
    let shortDescription: String
    let longDescription: String
}

struct SurveyListItem: Decodable {
    let surveyId: String
    let name: String
    let description: SurveyDescription
    let imageUrl: String?
    let lastSubmission: String?
    let lastSubmissionId: String?
    let response: [SurveyLastResponseData]?
    let isRepetitive: Bool?
    let noOfTimesSurveyTaken: Int?
    var lastSurveyStatus: CheckInStatus
}

enum QuestionAction:String, Codable {
    case staticQuestion = "STATIC"
    case dynamic = "DYNAMIC"
}

enum QuestionTypes:String, Decodable {
    case text = "TEXT"
    case singleSelect = "SINGLE_SELECT"
    case continuousScale = "CONTINUOUS_SCALE"
    case temperatureScale = "TEMPERATURE_SCALE"
    case location = "LOCATION"
    case valuePicker = "VALUE_PICKER"
    case speechRecognition = "SPEECH_RECOGNITION"
}

struct Question:Decodable {
    let categoryId: Int
    let moduleId: Int
    let quesId: String
    let text: String
    let quesType: QuestionTypes
    let options: [QuestionOption]
    let nextQuestion: String?
    let validation: QuestionResponseValidation?
    let otherDetails: QuestionOtherDetails?
    let action: QuestionAction
}

struct QuestionResponseValidation:Decodable {
    let regex: String?
}

struct QuestionOtherDetails: Decodable {
    let scale: Scale?
    let TEXT: QuestionOtherDetailsText?
    let fileName: String?
    let recordingLength: Double?
}

enum QuestionOtherDetailsTextType:String,Decodable {
    case numeric = "NUMERIC"
    case alphanumeric = "ALPHANUMERIC"
}

extension QuestionOtherDetailsTextType {
    var keyboardType: UIKeyboardType {
        switch self {
        case .numeric:
            return .numberPad
        case .alphanumeric:
            return .alphabet
        }
    }
}

struct QuestionOtherDetailsText:Decodable {
    let type: QuestionOtherDetailsTextType
}

struct Scale: Decodable {
    let min: String
    let max: String
}

struct QuestionOption: Decodable {
    let text: String?
    let description: String?
    var value: String?
    
    private enum CodingKeys: String, CodingKey {
        case text, description, value
    }
    
    init(text: String? = nil, description: String? = nil, value: String? = nil) {
        self.text = text
        self.description = description
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try? container.decode(String.self, forKey: .text)
        description = try? container.decode(String.self, forKey: .description)
        value = try? String(container.decode(Int.self, forKey: .value))
        if value == nil {
            value = try? container.decode(String.self, forKey: .value)
            if value == nil {
                value = try? String(container.decode(Double.self, forKey: .value))
            }
        }
    }
}

enum ModuleViewType: String, Decodable {
    case oneModulePerPage, oneQuestionPerPage
}

enum CategoryViewType: String, Decodable {
    case moduleLevel, oneCategoryPerPage
}

struct Module: Decodable {
    let view: String?
    let id: Int
    let iconName: String?
}

struct Category: Decodable {
    let id: Int
    let view: String
    let modules: Array<[String: Module]>
    let description: String?
}

struct DisplaySettings: Decodable {
    let categories: [[String:Category]]
}

struct SurveyDetails: Decodable {
    let surveyId: String
    let name: String
    let description: SurveyDescription
    let displaySettings: DisplaySettings
    let questions: [Question]
    let lastSubmission: String?
    let lastSubmissionId: String?
    let isRepetitive: Bool?
}

struct SurveySubmissionDetailsResponseValue: Codable {
    let surveyID, surveyName: String

    enum CodingKeys: String, CodingKey {
        case surveyID = "survey_id"
        case surveyName = "survey_name"
    }
}

typealias SurveySubmissionDetailsResponse = [String: SurveySubmissionDetailsResponseValue]

struct FindNextQuestionPayload: Codable {
    let moduleId: Int
    let quesId: String
    let answer: String
}

struct NextQuestion: Decodable {
    let quesId: String
}
struct SubmitAnswerPayload: Codable {
    let categoryId: Int
    let moduleId: Int
    let answer: String
    let quesId: String
}

struct SurveyCategoryViewTypes {
    static let oneCategoryPerPage = "ONE_CATEGORY_PER_PAGE"
    static let moduleLevel = "MODULE_LEVEL"
}
