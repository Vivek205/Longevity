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
    let lastSurveyStatus: CheckInStatus
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
        default:
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
    let description: SurveyDescription
    let displaySettings: DisplaySettings
    let questions: [Question]
    let lastSubmission: String?
    let lastSubmissionId: String?
}

class SurveysAPI : BaseAuthAPI {
    
    static var instance: SurveysAPI = SurveysAPI()
    
    func getSurveys(completion:@escaping (_ surveys:[SurveyListItem]) -> Void,
                    onFailure:@escaping (_ error:Error) -> Void) {
        
        let request = RESTRequest(apiName: "surveyAPI", path: "/surveys", headers: headers, queryParameters: nil,
                                  body: nil)
        
        self.makeAPICall(callType: .apiGET, request: request) { (data, error) in
            guard let data = data else {
                completion([])
                return
            }
            
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
        }
    }
    
    func get(surveyId: String, completion: @escaping(SurveyDetails?) -> Void) {
        let request = RESTRequest(apiName: "surveyAPI", path: "/survey/\(surveyId)", headers: headers, queryParameters: nil, body: nil)
        
        self.makeAPICall(callType: .apiGET, request: request) { (data, error) in
            guard let data = data else {
                completion (nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let value = try decoder.decode(SurveyDetails.self, from: data)
                SurveyTaskUtility.shared.currentSurveyId = surveyId
                SurveyTaskUtility.shared.setSurveyDetails(for:surveyId, details: value)
                completion(value)
            } catch let error {
                SurveyTaskUtility.shared.currentSurveyId = nil
                SurveyTaskUtility.shared.setSurveyDetails(for:surveyId, details: nil)
                print("json error", error)
            }
        }
    }
    
    func findNextQuestion(moduleId: Int? ,questionId: String, answerValue: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy - HH:mm:ss.SSS"
        print("entry", dateFormatter.string(from: Date()))

        guard let currentSurveyId = SurveyTaskUtility.shared.currentSurveyId,
            let moduleId = moduleId else {return nil}
        var nextQuestionIdentifier: String?
        let payload = FindNextQuestionPayload(moduleId: moduleId, quesId: questionId, answer: answerValue)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let semaphore = DispatchSemaphore(value: 0)
        do {
            let data = try encoder.encode(payload)
            
            let path = "/survey/\(currentSurveyId)/question/next"
            
            let request = RESTRequest(apiName: "surveyAPI", path: path, headers: headers, queryParameters: nil, body: data)
            self.makeAPICall(callType: .apiPOST, request: request) { (data, error) in
                if error != nil {
                    print("json error", error)
                    semaphore.signal()
                }
                
                guard let data = data else { semaphore.signal()
                    return }
                
                let dataString = String(data: data, encoding: .utf8)
                print("data string", dataString)
                if dataString == "null" {
                    semaphore.signal()
                    return
                }
                do {
                     let decoder = JSONDecoder()
                                       decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let value = try decoder.decode(NextQuestion.self, from: data)
                    nextQuestionIdentifier = value.quesId
                    print("next question API", value)
                    semaphore.signal()
                } catch  {
                    print("json error", error)
                    semaphore.signal()
                }
            }
            
        } catch {
                    semaphore.signal()
                }
            
            _ = semaphore.wait(timeout: .distantFuture)
            print("exit", dateFormatter.string(from: Date()))
            return nextQuestionIdentifier
            
//            print("enocded post body", String(data:data, encoding: .utf8))
//            getCredentials(completion: { (credentials) in
////                let headers = ["token":credentials.idToken, "login_type":LoginType.PERSONAL]
//                let surveyAPI = "https://smu3xkqh66.execute-api.us-west-2.amazonaws.com/development/v1"
////                let path = "/survey/\(currentSurveyId)/question/next"
//                guard let requestUrl = URL(string: "\(surveyAPI)\(path)") else { semaphore.signal(); return}
//                var request = URLRequest(url: requestUrl)
//                request.httpMethod = "POST"
//                request.httpBody = data
////                request.setValue(credentials.idToken, forHTTPHeaderField: "token")
////                request.setValue(LoginType.PERSONAL, forHTTPHeaderField: "login_type")
////                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//                let task = URLSession.shared.dataTask(with: request){
//                    (data, response,_) in
//                    print("response", response)
//                    guard let httpResponse = response as? HTTPURLResponse,
//                    httpResponse.statusCode == 200,
//                    data != nil else {
//                        semaphore.signal()
//                        return
//                    }
//                    if let data = data, let dataString = String(data: data, encoding: .utf8) {
//                        print("data string", dataString)
//                        if dataString == "null" {
//                            semaphore.signal()
//                            return
//                        }
//                        do {
//                             let decoder = JSONDecoder()
//                                               decoder.keyDecodingStrategy = .convertFromSnakeCase
//                            let value = try decoder.decode(NextQuestion.self, from: data)
//                            nextQuestionIdentifier = value.quesId
//                            print("next question API", value)
//                            semaphore.signal()
//                        } catch  {
//                            print("json error", error)
//                            semaphore.signal()
//                        }
//                    }
//                }
//                task.resume()
//            }) { (error) in
//                print("credentials error", error)
//                semaphore.signal()
//            }
//        } catch {
//            semaphore.signal()
//            return nil
//        }
//
//
//        _ = semaphore.wait(timeout: .distantFuture)
//        print("exit", dateFormatter.string(from: Date()))
//        return nextQuestionIdentifier
    }
    
    func saveSurveyAnswers(surveyId: String? ,answers: [SubmitAnswerPayload],
                           completion:@escaping () -> Void,
                           onFailure: @escaping (_ error: Error) -> Void) {
        enum SaveSurveyError: Error {
            case surveyIdNotFound
        }
        guard let surveyId = surveyId else { return onFailure(SaveSurveyError.surveyIdNotFound)}
            do {
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                let data = try encoder.encode(answers)
                print(String(data:data, encoding: .utf8)!)

                let request = RESTRequest(apiName: "surveyAPI", path: "/survey/\(surveyId)/save", headers: headers,
                                          queryParameters: nil, body: data)
                
                self.makeAPICall(callType: .apiPOST, request: request) { (data, error) in
                    if error != nil {
                        onFailure(error!)
                    }
                    
                    guard data != nil else { return }
                    completion()
                }
            } catch  {
                print(error)
            }
    }

    func submitSurvey(surveyId: String?, completion:@escaping () -> Void,
                      onFailure: @escaping (_ error: Error) -> Void) {
        enum SubmitSurveyError: Error {
            case surveyIdIsEmpty
        }
        guard let surveyId = surveyId else { return onFailure(SubmitSurveyError.surveyIdIsEmpty) }
        
        let request = RESTRequest(apiName: "surveyAPI", path: "/survey/\(surveyId)/submit", headers: headers,
                                      queryParameters: nil, body: nil)
        self.makeAPICall(callType: .apiPOST, request: request) { (data, error) in
            if error != nil {
                onFailure(error!)
                return
            }
            completion()
        }
    }
}



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
