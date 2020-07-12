//
//  Notification.swift
//  Longevity
//
//  Created by vivek on 11/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import Amplify
import SwiftyJSON

func registerARN(platform:String, arnEndpoint: String) {
    let credentials = getCredentials()
    let headers = ["token":credentials.idToken, "content-type":"application/json"]
    
    let body = JSON([
        "platform" : platform,
        "endpoint_arn" : arnEndpoint
    ])

    var bodyData:Data = Data();
    do {
        bodyData = try body.rawData()
    } catch  {
        print(error)
    }

    let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/device/notification/register" , headers: headers, body: bodyData)
    _ = Amplify.API.post(request: request, listener: { (result) in
        switch result{
        case .success(let data):
            let responseString = String(data: data, encoding: .utf8)
            print("sucess \(responseString)")
        case .failure(let apiError):
            print("failed \(apiError)")
        }
    })
}
