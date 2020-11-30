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

class UserAPI: BaseAuthAPI {
    
    static var instance = UserAPI()
    
    func updateProfile(){
        let keys = UserDefaultsKeys()
        var bodyDict:[String:String] = [String:String]()
        let appSyncManager = AppSyncManager.instance
        
        bodyDict[keys.name] = appSyncManager.userProfile.value?.name
        bodyDict[keys.phone] = appSyncManager.userProfile.value?.phone
        bodyDict[keys.weight] = appSyncManager.healthProfile.value?.weight
        bodyDict[keys.height] = appSyncManager.healthProfile.value?.height
        bodyDict[keys.gender] = appSyncManager.healthProfile.value?.gender
        bodyDict[keys.unit] = appSyncManager.healthProfile.value?.unit.rawValue
        if let birthday = appSyncManager.healthProfile.value?.birthday, !birthday.isEmpty {
            bodyDict[keys.birthday] = birthday
        }
        
        let body = JSON(bodyDict)
        var bodyData:Data = Data()
        do {
            bodyData = try body.rawData()
        } catch {
            print(error)
        }
        
        let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/profile" , headers: headers, body: bodyData)
        
        self.makeAPICall(callType: .apiPOST, request: request) { (data, error) in
            guard let data = data else {
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("sucess \(responseString)")
        }
    }
    
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
}

struct Credentials {
    var usersub = ""
    var identityId = ""
    var accessKey = ""
    var idToken = ""
}
