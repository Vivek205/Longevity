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
import SwiftyJSON

struct CustomCognitoAttributes {
    static let longevityTNC = "custom:longevity_tnc"
}

struct CustomCognitoAttributesDefaults {
    static let longevityTNC = "{\"version\":1,\"isAccepted\":false}"
}

struct ExternalDevices {
    static let FITBIT = "FITBIT"
    static let HEALTHKIT = "HEALTHKIT"
}

struct LoginType {
    static let PERSONAL = "PERSONAL"
    static let CLINICALTRIAL = "CLINICAL_TRIAL"
}

let longevityTNCVersion = 1

func getProfile() {
    getHealthProfile()

    func onGettingCredentials(_ credentials: Credentials) {
        print("idtoken", credentials.idToken)
        let headers = ["token":credentials.idToken, "login_type":LoginType.PERSONAL]
        let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/profile" , headers: headers)
        _ = Amplify.API.get(request: request, listener: { (result) in
            switch result {
            case .success(let data):
                do {
                    let jsonData = try JSON(data: data)
                    let defaults = UserDefaults.standard
                    let keys = UserDefaultsKeys()
                    let userProfileData = jsonData["data"]
                    let name = userProfileData[keys.name].rawString()!

                    var devicesStatus: [String:[String:Int]] = [:]

                    if !(name.isEmpty) && name != "null"{
                        defaults.set(name, forKey: keys.name)
                    }

                } catch {
                    print("json parse error", error)
                }
            case .failure(let apiError):
                print("failed \(apiError)")
            }
        })
    }

    func onFailureCredentials(_ error: Error?) {
        print("failed to fetch credentials \(error)")
    }


    _ = getCredentials(completion: onGettingCredentials(_:), onFailure: onFailureCredentials(_:))
    getUserAttributes()



}

func updateProfile(){
    func onGettingCredentials(_ credentials: Credentials){
        let headers = ["token":credentials.idToken,"login_type":LoginType.PERSONAL]
        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()
        let body = JSON([
            keys.name: defaults.value(forKey: keys.name),
            keys.weight: defaults.value(forKey: keys.weight),
            keys.height: defaults.value(forKey: keys.height),
            keys.gender: defaults.value(forKey: keys.gender),
            keys.birthday: defaults.value(forKey: keys.birthday),
            keys.unit: defaults.value(forKey: keys.unit)
        ])

        var bodyData:Data = Data();
        do {
            bodyData = try body.rawData()
        } catch  {
            print(error)
        }

        let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/profile" , headers: headers, body: bodyData)
        _ = Amplify.API.post(request: request, listener: { (result) in
            switch result{
            case .success(let data):
                let responseString = String(data: data, encoding: .utf8)
                print("sucess \(responseString)")
                updateSetupProfileCompletionStatus(currentState: .biodata)
            case .failure(let apiError):
                print("failed \(apiError)")
            }
        })
    }
    func onFailureCredentials(_ error: Error?) {
        print("failed to fetch credentials \(error)")
    }
    let credentials = getCredentials(completion: onGettingCredentials(_:), onFailure: onFailureCredentials(_:))


}


func getCurrentUser() {
    func onSuccess(userSignedIn: Bool) {
        if userSignedIn {
            print("user signed in")
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

func getCredentials(completion: @escaping (_ credentials: Credentials)-> Void,
                    onFailure: @escaping (_ error: Error)-> Void) {
    var usersub = "", identityId = "", accessKey = "", idToken = ""
    var credentials = Credentials()
    _ = Amplify.Auth.fetchAuthSession { result in
        do {
            let session = try result.get()

            if let identityProvider = session as? AuthCognitoIdentityProvider {
                credentials.usersub = try identityProvider.getUserSub().get()
                credentials.identityId = try identityProvider.getIdentityId().get()
            }

            // Get aws credentials
            if let awsCredentialsProvider = session as? AuthAWSCredentialsProvider {
                let awsCredentials = try awsCredentialsProvider.getAWSCredentials().get()
                credentials.accessKey = awsCredentials.accessKey
            }

            // Get cognito user pool token
            if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                let tokens = try cognitoTokenProvider.getCognitoTokens().get()
                credentials.idToken = tokens.idToken
            }

            completion(credentials)
        } catch {
            print("Fetch auth session failed with error - \(error)")
            onFailure(error)
        }
    }
}


func getUserAttributes() {
    let defaults = UserDefaults.standard
    let keys = UserDefaultsKeys()
    _ = Amplify.Auth.fetchUserAttributes() { result in
        switch result {
        case .success(let attributes):
            for attribute in attributes {
                let name = attribute.key
                let value = attribute.value
                if name.rawValue == CustomCognitoAttributes.longevityTNC {
                    let data: Data? = value.data(using: .utf8)!
                    let json = (try? JSONSerialization.jsonObject(with: data!, options: [])) as? [String: Any]

                    if json!["isAccepted"] as! NSNumber == 1 {
                        defaults.set(1, forKey: keys.isTermsAccepted)
                    }
                }
            }
        case .failure(let error):
            print("Fetching user attributes failed with error \(error)")
        }
    }
}


func acceptTNC(value: Bool) {
    let defaults = UserDefaults.standard
    let keys = UserDefaultsKeys()
    let tncValue = ["version" : 1, "isAccepted" : value] as [String: Any]
    let json = JSON(tncValue)
    let tncValueString = json.rawString([.castNilToNSNull : true])!

    _ = Amplify.Auth.update(userAttribute: AuthUserAttribute(.unknown(CustomCognitoAttributes.longevityTNC), value: tncValueString)) { result in
        do {
            defaults.set(1, forKey: keys.isTermsAccepted)
            let updateResult = try result.get()
            switch updateResult.nextStep {
            case .confirmAttributeWithCode(let deliveryDetails, let info):
                print("Confirm the attribute with details send to - \(deliveryDetails) \(info)")
            case .done:
                print("Update completed")
                updateSetupProfileCompletionStatus(currentState: .acceptTerms)
            }
        } catch {
            print("Update attribute failed with error \(error)")
        }
    }
}

