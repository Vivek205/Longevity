//
//  User.swift
//  Longevity
//
//  Created by vivek on 03/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import Amplify
import AWSPluginsCore

func getProfile(){
    let credentials = getCredentials()
    print("idtoken", credentials.idToken)
//    let userProfileURL = "https://edjyqewn8e.execute-api.us-west-2.amazonaws.com/development/profile"
    let headers = ["authorization":credentials.idToken]
    let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/profile" , headers: headers)
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


func getCurrentUser() {
    print("started getCurrent user")
    func onSuccess(userSignedIn: Bool) {
        if userSignedIn {
            print("success")
        }
    }

    func onFailure(error: AuthError) {
        print(error)
    }

    _ = Amplify.Auth.fetchAuthSession { (result) in
        switch result {
        case .success(let session):
            onSuccess(userSignedIn: session.isSignedIn)
        case .failure(let error):
            onFailure(error: error)
        }
    }

}

struct Credentials {
    var usersub = ""
    var identityId = ""
    var accessKey = ""
    var idToken = ""
}


func getCredentials() -> Credentials {
    var usersub = "", identityId = "", accessKey = "", idToken = "";
    var credentials = Credentials()
    let group = DispatchGroup()
    group.enter()

    DispatchQueue.main.async {
        _ = Amplify.Auth.fetchAuthSession { result in
            do {
                let session = try result.get()

                // Get user sub or identity id
                if let identityProvider = session as? AuthCognitoIdentityProvider {
                    credentials.usersub = try identityProvider.getUserSub().get()
                    credentials.identityId = try identityProvider.getIdentityId().get()
//                    print("User sub - \(usersub) and identity id \(identityId)")

                }

                // Get aws credentials
                if let awsCredentialsProvider = session as? AuthAWSCredentialsProvider {
                    let awsCredentials = try awsCredentialsProvider.getAWSCredentials().get()
                    credentials.accessKey = awsCredentials.accessKey
//                    print("Access key - \(awsCredentials.accessKey) ")
                }

                // Get cognito user pool token
                if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                    let tokens = try cognitoTokenProvider.getCognitoTokens().get()
                    credentials.idToken = tokens.idToken
//                    print("Id token - \(tokens.idToken) ")
                }
                group.leave()
            } catch {
                print("Fetch auth session failed with error - \(error)")
                group.leave()
            }
        }
    }
    group.wait()
    return credentials
}
