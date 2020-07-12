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

let longevityTNCVersion = 1

func getProfile(){
    let credentials = getCredentials()
    getUserAttributes()
    print("idtoken", credentials.idToken)
    let headers = ["token":credentials.idToken]
    let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/profile" , headers: headers)
    _ = Amplify.API.get(request: request, listener: { (result) in
        switch result{
        case .success(let data):
            do {
                let jsonData = try JSON(data: data)
                print("json ", jsonData)
                let defaults = UserDefaults.standard
                let keys = UserDefaultsKeys()
                let userProfileData = jsonData["data"]
                let name = userProfileData[keys.name].rawString()!
                let weight = userProfileData[keys.weight].rawString()!
                let height = userProfileData[keys.height].rawString()!
                let gender = userProfileData[keys.gender].rawString()!
                let birthday = userProfileData[keys.birthday].rawString()!
                let unit = userProfileData[keys.unit].rawString()!
                let devices = userProfileData[keys.devices].rawValue as? [String:[String:Int]]

                var devicesStatus: [String:[String:Int]] = [:]

                if !(name.isEmpty){
                    defaults.set(name, forKey: keys.name)
                }
                if !(weight.isEmpty){
                    defaults.set(weight, forKey: keys.weight)
                }
                if !(height.isEmpty) {
                    defaults.set(height, forKey: keys.height)
                }
                if !(gender.isEmpty)  {
                    defaults.set(gender, forKey: keys.gender)
                }
                if !(birthday.isEmpty) {
                    defaults.set(birthday, forKey: keys.birthday)
                }
                if !(unit.isEmpty) {
                    defaults.set(unit, forKey: keys.unit)
                }


                if let fitbitStatus = devices![ExternalDevices.FITBIT]  as? [String: Int]{
                    print("devices", devices)
                    devicesStatus[ExternalDevices.FITBIT] = ["connected": fitbitStatus["connected"]!]

                    if let devices = defaults.object(forKey: keys.devices) as? [String:[String:Int]] {
                        let enhancedDevices = devices.merging(devicesStatus) {(_, newValues) in newValues }
                        defaults.set(enhancedDevices, forKey: keys.devices)
                    }else {
                        defaults.set(devicesStatus, forKey: keys.devices)
                    }
                }

            } catch {
                print("json parse error", error)
            }
        case .failure(let apiError):
            print("failed \(apiError)")
        }
    })
}

func updateProfile(){
    let credentials = getCredentials()
    print("idtoken", credentials.idToken)
    //    let userProfileURL = "https://edjyqewn8e.execute-api.us-west-2.amazonaws.com/development/profile"
    let headers = ["token":credentials.idToken]
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

    let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/edit" , headers: headers, body: bodyData)
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

    DispatchQueue.global().async {
        _ = Amplify.Auth.fetchAuthSession { result in
            do {
                let session = try result.get()

                // Get user sub or identity id
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


func getUserAttributes() {
    let defaults = UserDefaults.standard
    let keys = UserDefaultsKeys()
    _ = Amplify.Auth.fetchUserAttributes() { result in
        switch result {
        case .success(let attributes):
            print("User attributes - \(attributes)")
            print("json user attributes", JSON(attributes))
            for attribute in attributes {
                let name = attribute.key
                let value = attribute.value
                //                let value = "{\"version\":1,\"isAccepted\":false}"
                print("Raw key valye", name.rawValue)
                if name.rawValue == CustomCognitoAttributes.longevityTNC {
                    let data: Data? = value.data(using: .utf8)!
                    let json = (try? JSONSerialization.jsonObject(with: data!, options: [])) as? [String: Any]
                    //                    guard let json = try JSON(data: value.data(using: .utf8)!) else {
                    //                        return
                    //                    }
                    //                    if let valueDict = JSONSerialization.jsonObject(with: <#T##Data#>, options: <#T##JSONSerialization.ReadingOptions#>)
                    print(json, json!["isAccepted"]);
                    if json!["isAccepted"] as! NSNumber == 1 {
                        defaults.set(1, forKey: keys.isTermsAccepted)
                    }
                }
                //                if(
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
    //    print("json", json.rawString([.castNilToNSNull : true]))
    let tncValueString = json.rawString([.castNilToNSNull : true])!
    print("tncValueString", tncValueString)
    _ = Amplify.Auth.update(userAttribute: AuthUserAttribute(.unknown(CustomCognitoAttributes.longevityTNC), value: tncValueString)) { result in
        do {
            defaults.set(1, forKey: keys.isTermsAccepted)
            let updateResult = try result.get()
            switch updateResult.nextStep {
            case .confirmAttributeWithCode(let deliveryDetails, let info):
                print("Confirm the attribute with details send to - \(deliveryDetails) \(info)")
            case .done:
                print("Update completed")
            }
        } catch {
            print("Update attribute failed with error \(error)")
        }
    }
}

