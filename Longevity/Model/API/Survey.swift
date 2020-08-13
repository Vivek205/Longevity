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
}

struct SurveyResponse: Decodable {
    let surveyId: String
    let name: String
    let description: String
    let imageUrl: String?
    let lastSubmission: String?
    let lastSubmissionId: String?
    let response: [SurveyLastResponseData]?
}

func getSurveys(completion:@escaping (_ surveys:[SurveyResponse]) -> Void,
                onFailure:@escaping (_ error:Error)-> Void) {
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
                    let value = try decoder.decode([SurveyResponse].self, from: data)
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
    let text: String
    let description: String?
    let value: String
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
                print(data)
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let value = try decoder.decode(SurveyDetails.self, from: data)
                    response = value
                    completion(value)
                    SurveyTaskUtility.currentSurveyDetails = value
                } catch {
                    SurveyTaskUtility.currentSurveyDetails = nil
                    print("json error", error)
                }

            case .failure(let apiError):
                print(apiError)
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

    let group = DispatchGroup()

    group.enter()
    DispatchQueue.global().async {
        _ = Amplify.API.post(request: request, listener: { (result) in
            switch result {
            case .success(let data):
                print(data)
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let value = try decoder.decode(Question.self, from: data)
                    nextQuestionIdentifier = value.quesId
                    print(value)
                    //                response = jsonData
                    group.leave()
                } catch {
                    print("json error", error)
                    group.leave()
                }

            case .failure(let apiError):
                print(apiError)
                group.leave()
            }
        })
    }

    group.wait()
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

func saveSurveyAnswers(surveyId: String ,answers: [SubmitAnswerPayload]) {
    func onGettingCredentials(_ credentials: Credentials){
        do {
            let headers = ["token":credentials.idToken, "login_type":LoginType.PERSONAL]
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let data = try encoder.encode(answers)
            print(String(data: data, encoding: .utf8)!)
            let request = RESTRequest(apiName: "surveyAPI", path: "/survey/\(surveyId)/save", headers: headers,
                                      queryParameters: nil, body: data)
            _ = Amplify.API.post(request: request, listener: { (result) in
                switch result {
                case .success(let data):
                    print("success", JSON(data))
//                    TODO: Remove the logic of submit survey from here.
//                    It has to be handled in the taskViewController didFinish delegate
                    submitSurvey(surveyId: surveyId) // FIXME: Remove me
                case .failure(let error):
                    print("failure", error)
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

func submitSurvey(surveyId: String) {
    func onGettingCredentials(_ credentials: Credentials){
        let headers = ["token":credentials.idToken, "login_type":LoginType.PERSONAL]
        let request = RESTRequest(apiName: "surveyAPI", path: "/survey/\(surveyId)/submit", headers: headers,
                                  queryParameters: nil, body: nil)
        _ = Amplify.API.post(request: request, listener: { (result) in
            switch result {
            case .success(let data):
                print("success", data)
            case .failure(let error):
                print("failure", error)
            }
        })
    }
    func onFailureCredentials(_ error: Error?) {
        print(error)
    }
    getCredentials(completion: onGettingCredentials(_:), onFailure: onFailureCredentials(_:))
}


