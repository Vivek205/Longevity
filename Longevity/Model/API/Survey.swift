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
    let imageUrl: String
    let lastSubmission: String
    let lastSubmissionId: String
    let response: [SurveyLastResponseData]
}

func getSurveys(completion:@escaping (_ surveys:[SurveyResponse])->Void, onFailure:@escaping (_ error:Error)-> Void) {
    let request = RESTRequest(apiName: "mockQuestionsAPI", path: "/survey", headers: nil, queryParameters: nil, body: nil)
    let response:[SurveyResponse] = [SurveyResponse]()

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


struct QuestionResponse:Decodable {
    let categoryId: String
    let moduleId: String
    let quesId: String
    let quesShortName: String
    let heading: String
    let text: String
    let quesType: String
    let options: [QuestionOption]
    let validations: String
    let dependents: String
    let otherDetails: String
    let isDynamic: Bool
    let nextQuestion: String?
    let validation: QuestionResponseValidation
    let otherAttribute: QuestionResponseOtherAttribute?
}

struct QuestionResponseValidation:Decodable {
    let regex: String
}

struct QuestionResponseOtherAttribute: Decodable {
    let scale: QuestionResponseOtherAttributeScale
}

struct QuestionResponseOtherAttributeScale: Decodable {
    let minimum: String
    let maximum: String
}

struct QuestionOption: Decodable {
    let text: String
    let description: String
    let value: Int
}

struct Question: Decodable {

}


func getQuestions() -> [QuestionResponse]?{
    let request = RESTRequest(apiName: "mockQuestionsAPI", path: "/question", headers: nil, queryParameters: nil, body: nil)
    var response:[QuestionResponse]? = nil

    let group = DispatchGroup()

    group.enter()
    DispatchQueue.global().async {
        _ = Amplify.API.get(request: request, listener: { (result) in
            switch result{
            case .success(let data):
                print(data)
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let value = try decoder.decode([QuestionResponse].self, from: data)
                    let jsonValue = JSON(data)


                    response = value
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

    return response

}

func findNextQuestion(questionId: String, answerValue: Int) -> String {
    let request = RESTRequest(apiName: "mockQuestionsAPI", path: "/question/123/nextQuestion", headers: nil, queryParameters: nil, body: nil)
    var nextQuestionIdentifier: String = ""

    let group = DispatchGroup()

    group.enter()
    DispatchQueue.global().async {
        _ = Amplify.API.post(request: request, listener: { (result) in
            switch result{
            case .success(let data):
                print(data)
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let value = try decoder.decode(QuestionResponse.self, from: data)
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



