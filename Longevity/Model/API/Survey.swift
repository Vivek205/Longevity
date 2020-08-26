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

struct SurveyListItem: Decodable {
    let surveyId: String
    let name: String
    let description: String
    let imageUrl: String?
    let lastSubmission: String?
    let lastSubmissionId: String?
    let response: [SurveyLastResponseData]?
}

func getSurveys(completion:@escaping (_ surveys:[SurveyListItem]) -> Void,
                onFailure:@escaping (_ error:Error) -> Void) {
    func onGettingCredentials(_ credentials: Credentials) {
        let headers = ["token":credentials.idToken, "login_type":LoginType.PERSONAL]
        let request = RESTRequest(apiName: "surveyAPI", path: "/surveys", headers: headers, queryParameters: nil,
                                  body: nil)

        _ = Amplify.API.get(request: request, listener: { (result) in
            switch result{
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let value = try decoder.decode([SurveyListItem].self, from: data)
                    SurveyTaskUtility.shared.setSurveyList(list: value)
                    if !value.isEmpty {
                        value.forEach {
                            SurveyTaskUtility.shared.setServerSubmittedAnswers(for:$0.surveyId, answers: $0.response)
                        }
                    }
                    completion(value)
                } catch  {
                    onFailure(error)
                }
            case .failure(let error):
                onFailure(error)
            }
        })
    }

    func onFailureCredentials(_ error: Error?) {
        print(error)
    }
    getCredentials(completion: onGettingCredentials(_:), onFailure: onFailureCredentials(_:))
}

struct Question:Decodable {
    let categoryId: Int
    let moduleId: Int
    let quesId: String
    let text: String
    let quesType: String
    let options: [QuestionOption]
    let isDynamic: Bool? // FIXME: Make it non optional
    let nextQuestion: String?
    let validation: QuestionResponseValidation?
    let otherAttribute: OtherAttribute?
}

struct QuestionResponseValidation:Decodable {
    let regex: String?
}

struct OtherAttribute: Decodable {
    let scale: Scale?
}

struct Scale: Decodable {
    let min: String
    let max: String
}

struct QuestionOption: Decodable {
    let text: String?
    let description: String?
    let value: String?
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
    let description: String
    let displaySettings: DisplaySettings
    let questions: [Question]
    let lastSubmission: String?
    let lastSubmissionId: String?
}

func getSurveyDetails(surveyId: String,
                      completion: @escaping (_ surveyDetails: SurveyDetails?) -> Void,
                      onFailure: @escaping (_ error: Error) -> Void) {
    var response:SurveyDetails?
    func onGettingCredentials(_ credentials: Credentials) {
        let headers = ["token":credentials.idToken, "login_type":LoginType.PERSONAL]
        let request = RESTRequest(apiName: "surveyAPI", path: "/survey/\(surveyId)", headers: headers,
                                  queryParameters: nil, body: nil)
        _ = Amplify.API.get(request: request, listener: { (result) in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let value = try decoder.decode(SurveyDetails.self, from: data)
                    response = value
                    SurveyTaskUtility.shared.currentSurveyId = surveyId
                    SurveyTaskUtility.shared.setSurveyDetails(for:surveyId, details: value)
                    completion(value)
                } catch {
                    SurveyTaskUtility.shared.currentSurveyId = nil
                    SurveyTaskUtility.shared.setSurveyDetails(for:surveyId, details: nil)
                    print("json error", error)
                }

            case .failure(let apiError):
                print("getSurveyDetails error",apiError)
            }
        })
    }

    func onFailureCredentials(_ error: Error?) {
        print(error)
    }

    getCredentials(completion: onGettingCredentials(_:), onFailure: onFailureCredentials(_:))
}

func findNextQuestion(questionId: String, answerValue: Int) -> String {
    let request = RESTRequest(apiName: "mockQuestionsAPI", path: "/question/123/nextQuestion", headers: nil,
                              queryParameters: nil, body: nil)
    var nextQuestionIdentifier: String = ""
    _ = Amplify.API.post(request: request, listener: { (result) in
        switch result {
        case .success(let data):
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let value = try decoder.decode(Question.self, from: data)
                nextQuestionIdentifier = value.quesId
            } catch {
                print("json error", error)
            }

        case .failure(let apiError):
            print("findNextQuestion",apiError)
        }
    })
    return nextQuestionIdentifier
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

func saveSurveyAnswers(surveyId: String? ,answers: [SubmitAnswerPayload],
                       completion:@escaping () -> Void,
                       onFailure: @escaping (_ error: Error) -> Void) {
    enum SaveSurveyError: Error {
        case surveyIdNotFound
    }
    guard let surveyId = surveyId else { return onFailure(SaveSurveyError.surveyIdNotFound)}
    func onGettingCredentials(_ credentials: Credentials) {
        do {
            let headers = ["token":credentials.idToken, "login_type":LoginType.PERSONAL]
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let data = try encoder.encode(answers)
            print(String(data:data, encoding: .utf8)!)

            let request = RESTRequest(apiName: "surveyAPI", path: "/survey/\(surveyId)/save", headers: headers,
                                      queryParameters: nil, body: data)
            _ = Amplify.API.post(request: request, listener: { (result) in
                switch result {
                case .success(let data):
                    print("success", JSON(data))
                    completion()
                case .failure(let error):
                    onFailure(error)
                }
            })
        } catch  {
            print(error)
        }
    }
    func onFailureCredentials(_ error: Error?) {
        print(error)
    }

    getCredentials(completion: onGettingCredentials(_:), onFailure: onFailureCredentials(_:))
}

func submitSurvey(surveyId: String?, completion:@escaping () -> Void,
                  onFailure: @escaping (_ error: Error) -> Void) {
    enum SubmitSurveyError: Error {
        case surveyIdIsEmpty
    }
    guard let surveyId = surveyId else { return onFailure(SubmitSurveyError.surveyIdIsEmpty) }

    func onGettingCredentials(_ credentials: Credentials) {
        let headers = ["token":credentials.idToken, "login_type":LoginType.PERSONAL]
        let request = RESTRequest(apiName: "surveyAPI", path: "/survey/\(surveyId)/submit", headers: headers,
                                  queryParameters: nil, body: nil)
        _ = Amplify.API.post(request: request, listener: { (result) in
            switch result {
            case .success(let data):
                completion()
            case .failure(let error):
                onFailure(error)
            }
        })
    }
    func onFailureCredentials(_ error: Error?) {
        print(error)
    }
    getCredentials(completion: onGettingCredentials(_:), onFailure: onFailureCredentials(_:))
}


