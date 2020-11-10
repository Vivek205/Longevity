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
    static let fitbit = "FITBIT"
    static let healthkit = "HEALTHKIT"
    static let healthkitBio = "HEALTHKIT_BIO"
    static let watch = "APPLEWATCH"
}

struct LoginType {
    static let PERSONAL = "PERSONAL"
    static let CLINICALTRIAL = "CLINICAL_TRIAL"
}

let longevityTNCVersion = 1


func updateProfile(){
    func onGettingCredentials(_ credentials: Credentials){
        let headers = ["token":credentials.idToken,"login_type":LoginType.PERSONAL]
        let keys = UserDefaultsKeys()
        var bodyDict:[String:String] = [String:String]()

        let appSyncManager = AppSyncManager.instance

        bodyDict[keys.name] = appSyncManager.userProfile.value?.name
        bodyDict[keys.phone] = appSyncManager.userProfile.value?.phone
        bodyDict[keys.weight] = appSyncManager.healthProfile.value?.weight
        bodyDict[keys.height] = appSyncManager.healthProfile.value?.height
        bodyDict[keys.gender] = appSyncManager.healthProfile.value?.gender
        bodyDict[keys.birthday] = appSyncManager.healthProfile.value?.birthday
        bodyDict[keys.unit] = appSyncManager.healthProfile.value?.unit.rawValue

        let body = JSON(bodyDict)
        print(body.rawValue)

        var bodyData:Data = Data()
        do {
            bodyData = try body.rawData()
        } catch {
            print(error)
        }

        let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/profile" , headers: headers, body: bodyData)
        _ = Amplify.API.post(request: request, listener: { (result) in
            switch result{
            case .success(let data):
                let responseString = String(data: data, encoding: .utf8)
                print("sucess \(responseString)")
            case .failure(let apiError):
                print("updateProfile failed \(apiError)")
            }
        })
    }
    func onFailureCredentials(_ error: Error?) {
        print("updateProfile failed to fetch credentials \(error)")
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
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"

    if let idTokenExp = try? KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.idTokenExp).readItem()  {

        if let expDate = dateFormatter.date(from: idTokenExp) {
            let currentDate = Date()
            if currentDate < expDate {
                if let idToken = try? KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.idToken).readItem() {

                    completion(  Credentials(usersub: "", identityId: "", accessKey: "", idToken: idToken))
                    return

                }
            }

        }
    }

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
//                print("expiry", awsCredentials.expiration)
                credentials.accessKey = awsCredentials.accessKey
            }

            // Get cognito user pool token
            if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                let tokens = try cognitoTokenProvider.getCognitoTokens().get()
                credentials.idToken = tokens.idToken

                let secondsOffset50Mins = Double(50 * 60)
                let date50MinFuture = Date().addingTimeInterval(secondsOffset50Mins)
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                let dateString50MinFuture = dateFormatter.string(from: date50MinFuture)

                guard let idTokenData = tokens.idToken.data(using: .utf8),
                let idTokenExpData = dateString50MinFuture.data(using: .utf8) else {
                    return completion(credentials)
                }

                try? KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.idToken).saveItem(tokens.idToken)
                try? KeyChain(service: KeychainConfiguration.serviceName, account: KeychainKeys.idTokenExp).saveItem(dateString50MinFuture)
                
//                KeyChain.save(name: KeychainKeys.idToken, data: idTokenData)
//                KeyChain.save(name: KeychainKeys.idTokenExp, data: idTokenExpData)
//                print(tokens.idToken)
            }

            completion(credentials)
        } catch {
            print("Fetch auth session failed with error - \(error)")
            onFailure(error)
        }
    }
}


//func getUserAttributes() {
//    _ = Amplify.Auth.fetchUserAttributes() { result in
//        switch result {
//        case .success(let attributes):
//            for attribute in attributes {
//                let name = attribute.key
//                let value = attribute.value
//                if name.rawValue == CustomCognitoAttributes.longevityTNC {
//                    let data: Data? = value.data(using: .utf8)!
//                    let json = (try? JSONSerialization.jsonObject(with: data!, options: [])) as? [String: Any]
//
//                    if json!["isAccepted"] as! NSNumber == 1 {
//                        AppSyncManager.instance.isTermsAccepted.value = true
//                    }
//                }
//            }
//        case .failure(let error):
//            print("Fetching user attributes failed with error \(error)")
//        }
//    }
//}


func acceptTNC(value: Bool) {
    let tncValue = ["version" : 1, "isAccepted" : value] as [String: Any]
    let json = JSON(tncValue)
    let tncValueString = json.rawString([.castNilToNSNull : true])!

    _ = Amplify.Auth.update(userAttribute: AuthUserAttribute(.unknown(CustomCognitoAttributes.longevityTNC), value: tncValueString)) { result in
        do {
            let updateResult = try result.get()
            switch updateResult.nextStep {
            case .confirmAttributeWithCode(let deliveryDetails, let info):
                print("Confirm the attribute with details send to - \(deliveryDetails) \(info)")
            case .done:
                print("Update completed")
                AppSyncManager.instance.isTermsAccepted.value = .accepted
            }
        } catch {
            print("Update attribute failed with error \(error)")
        }
    }
}
