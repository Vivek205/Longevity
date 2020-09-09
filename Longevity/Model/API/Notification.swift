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
    let deviceIdForVendor = UIDevice.current.identifierForVendor?.uuidString

    func onGettingCredentials(_ credentials: Credentials){
        let headers = ["token":credentials.idToken, "content-type":"application/json", "login_type":LoginType.PERSONAL]

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

        let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/device/\(deviceIdForVendor)/notification/register" , headers: headers, body: bodyData)

        _ = Amplify.API.post(request: request, listener: { (result) in
            switch result {
            case .success(let data):
                let responseString = String(data: data, encoding: .utf8)
                Logger.log("register ARN sucess \(responseString)")
            case .failure(let apiError):
                Logger.log("registerARN failed \(apiError)")
            }
        })
    }

    func onFailureCredentials(_ error: Error?) {
        print("registerARN failed to fetch credentials \(error)")
        Logger.log("register ARN failed")
    }

    _ = getCredentials(completion: onGettingCredentials(_:), onFailure: onFailureCredentials(_:))


}

func retrieveARN(){
    let deviceIdForVendor = UIDevice.current.identifierForVendor?.uuidString

    func onGettingCredentials(_ credentials: Credentials){
        let headers = ["token":credentials.idToken, "content-type":"application/json", "login_type":LoginType.PERSONAL]

        let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/device/\(deviceIdForVendor)/notification" , headers: headers)

        _ = Amplify.API.get(request: request, listener: { (result) in
            switch result{
            case .success(let data):
                do {
                    let responseString = String(data: data, encoding: .utf8)
                    let jsonResponse = try JSON(data: data)
                    print(jsonResponse["endpoint_arn"])
                    if let snsARN =  jsonResponse["endpoint_arn"].rawValue as? String {
                        let defaults = UserDefaults.standard
                        let keys = UserDefaultsKeys()
                        defaults.set(snsARN, forKey: keys.endpointArnForSNS)
                         Logger.log("retrieveARN success")
                    }
                } catch  {
                   Logger.log("retrieveARN failed \(error)")
                }
            case .failure(let apiError):
                Logger.log("retrieveARN failed \(apiError)")
            }
        })
    }

    func onFailureCredentials(_ error: Error?) {
          print("retrieveARN failed to fetch credentials \(error)")
      }

    _ = getCredentials(completion: onGettingCredentials(_:), onFailure: onFailureCredentials(_:))
}
