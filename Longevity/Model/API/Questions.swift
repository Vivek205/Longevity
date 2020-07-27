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

struct QuestionResponse:Decodable {
    let categoryId: String
    let moduleId: String
    let quesId: String
    let quesShortName: String
    let heading: String
    let quesText: String
    let quesType: String
    let options: [QuestionOption]
    let validations: String
    let dependents: String
    let otherDetails: String
}

struct QuestionOption: Decodable {
    let text: String
    let description: String
    let value: Int
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
                        response = value
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

    return response

}

