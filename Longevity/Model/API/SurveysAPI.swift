//
//  SurveysAPI.swift
//  COVID Signals
//
//  Created by Jagan Kumar Mudila on 10/12/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import Amplify
import SwiftyJSON

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
        
//        if surveyId.contains("COUGH") {
//
//            let surveyText = """
//{\"survey_id\":\"COUGH_TEST_SURVEY_01\",\"name\":\"Cough Test\",\"description\":{\"long_description\":\"You will be asked detailed questions that cover COVID symptoms, exposure, and your social distancing practices.\\n\\nFor best results, please complete your COVID Check-in daily.\",\"short_description\":\"Test your cough for early detection of COVID.\"},\"display_settings\":{\"categories\":[{\"cough\":{\"id\":2000,\"view\":\"MODULE_LEVEL\",\"modules\":[{\"cough\":{\"id\":2000}}]}}]},\"is_repetitive\":true,\"questions\":[{\"module_id\":2000,\"ques_id\":\"4000\",\"short_name\":\"cough_recorder\",\"heading\":\"\",\"text\":\"Start recording and cough into your phone's mic\",\"ques_type\":\"SPEECH_RECOGNITION\",\"options\":[],\"validations\":{\"valid\":[]},\"dependents\":{},\"other_details\":{},\"category_id\":2000,\"next\":\"8001\",\"action\":\"STATIC\"}]}
//"""
//            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//            guard let data = surveyText.data(using: .utf8) else {
//                return
//            }
//            do {
//                let value = try decoder.decode(SurveyDetails.self, from: data)
//                completion(value)
//            } catch {
//                print(error)
//            }
//
//            return
//        }
        
        
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
            print("save survey payload",String(data:data, encoding: .utf8))
            
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
