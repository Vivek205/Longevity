//
//  User.swift
//  Longevity
//
//  Created by vivek on 03/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import Amplify

func getProfile(){
    let userProfileURL = "https://edjyqewn8e.execute-api.us-west-2.amazonaws.com/development/profile"
    let request = RESTRequest(path:userProfileURL, body: nil )
    _ = Amplify.API.get(request: request, listener: { (result) in
        switch result{
        case .success(let data):
            let responseString = String(data: data, encoding: .utf8)
            print("sucess \(responseString)")
        case .failure(let apiError):
            print("failed \(apiError)")
        }
    })
}
