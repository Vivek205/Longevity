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
    
    private enum CodingKeys: String, CodingKey {
        case text = "text", description = "description", value = "value"
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
        do {
            value = try String(container.decode(Int.self, forKey: .value))
        } catch DecodingError.typeMismatch {
            do {
                value = try container.decode(String.self, forKey: .value)
            } catch DecodingError.typeMismatch {
                value = try String(container.decode(Double.self, forKey: .value))
            }
        } catch {
            value = nil
            print(error)
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
                var value = try decoder.decode([SurveyListItem].self, from: data)

                //TODO: This logic to be removed upon new survey is populated
                value.append(SurveyListItem(surveyId: "COUGH_TEST_SURVEY_01", name: "Cough Test", description: SurveyDescription(shortDescription: "Test your cough for early detection of COVID.", longDescription: "You will be asked detailed questions that cover COVID symptoms, exposure, and your social distancing practices.\n\nFor best results, please complete your COVID Check-in daily."), imageUrl: nil, lastSubmission: nil, lastSubmissionId: nil, response: nil, isRepetitive: true, noOfTimesSurveyTaken: nil, lastSurveyStatus: .notstarted))
                
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
    
    func findNextQuestion(moduleId: Int? ,questionId: String, answerValue: String, isRetry: Bool = false) -> String? {
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
            
            guard let path = Bundle.main.path(forResource: "amplifyconfiguration", ofType: "json"),
                  let fileURL = URL(fileURLWithPath: path) as? URL,
                  let fileData = try? String(contentsOf: fileURL).data(using: .utf8) else {
                return nextQuestionIdentifier
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let configData = try? decoder.decode(AWSAmplifyConfig.self, from: fileData) as? AWSAmplifyConfig,
                  let requestUrl = URL(string: "\(configData.api.plugins.awsAPIPlugin.surveyAPI.endpoint)/survey/\(currentSurveyId)/question/next") else {
                semaphore.signal()
                return nextQuestionIdentifier
            }
            
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "POST"
            request.httpBody = data
            request.allHTTPHeaderFields = self.headers
            
            URLSession.shared.dataTask(with: request){
                (data, response, error) in
                
                if let error = error {
                    print(error)
                    semaphore.signal()
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    return
                }
                
                if httpResponse.statusCode == 403 && isRetry {
                    nextQuestionIdentifier = self.findNextQuestion(moduleId: moduleId, questionId: questionId, answerValue: answerValue, isRetry: true)
                    semaphore.signal()
                }
                
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
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
                } else {
                    semaphore.signal()
                }
            }.resume()
        } catch {
            semaphore.signal()
            return nil
        }
        
        _ = semaphore.wait(timeout: .distantFuture)
        return nextQuestionIdentifier
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
            print(String(data:data, encoding: .utf8))
            
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



    func surveySubmissionDetails(submissionIdList:[String],completion:@escaping (SurveySubmissionDetailsResponse?) -> Void,
                                 onFailure: @escaping (_ error: Error) -> Void) {
        enum SurveySubmissionDetailsError: Error {
            case unknownError
        }
        do {
            let jsonEncoder = JSONEncoder()
            let data = try jsonEncoder.encode(submissionIdList)
            let request = RESTRequest(apiName: "surveyAPI", path: "/survey/submissions/details", headers:headers , queryParameters: nil, body: data)
            self.makeAPICall(callType: .apiPOST, request: request) { (data, error) in
                if error != nil {
                    onFailure(error ?? SurveySubmissionDetailsError.unknownError)
                }
                guard let data = data else {
                    completion(nil)
                    return
                }
                let jsonDecoder = JSONDecoder()
                if let value = try? jsonDecoder.decode(SurveySubmissionDetailsResponse.self, from: data) {
                    completion(value)
                }
                completion(nil)
            }
        } catch  {
            print("surveySubmissionDetails error", error)
            onFailure(error)
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
