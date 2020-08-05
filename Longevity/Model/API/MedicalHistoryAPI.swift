//
//  SetupProfile.swift
//  Longevity
//
//  Created by vivek on 15/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import SwiftyJSON
import Amplify

func updateMedicalConditions(otherOption: String?) {
    func onGettingCredentials(_ credentials: Credentials){
        let headers = ["token":credentials.idToken, "login_type":LoginType.PERSONAL]

        let touchedConditions = preExistingMedicalConditionData.filter{$0.selected}

        struct UpdatedConditionsPayload {
            let condition: String
            let type: String
            let status: Int
        }

        var updatedConditions =  touchedConditions.map { (item) -> [String:Any] in
            let value = ["condition": item.name, "type":"PREDEFINDED"] as [String : Any]
            return value
        }
        if otherOption != nil {
            updatedConditions.append(["condition": otherOption!, "type": "OTHER"])
        }

        let jsonToSend = ["pre_existing_conditions":updatedConditions]
        let body = JSON(jsonToSend)

        var bodyData:Data = Data()
        do {
            bodyData = try body.rawData()

        } catch  {
            print("body data error",error)
        }

        let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/health/profile" , headers: headers, body: bodyData)
        _ = Amplify.API.post(request: request, listener: { (result) in
            switch result{
            case .success(let data):
                let responseString = String(data: data, encoding: .utf8)
                print("sucess \(responseString)")
                let defaults = UserDefaults.standard
                let keys = UserDefaultsKeys()
                defaults.set(true, forKey: keys.providedPreExistingMedicalConditions)
                case .failure(let apiError):
                print("failed \(apiError)")
            }
        })
    }

    func onFailureCredentials(_ error: Error?) {
          print("failed to fetch credentials \(error)")
      }

    _ = getCredentials(completion: onGettingCredentials(_:), onFailure: onFailureCredentials(_:))

}


func getHealthProfile(){
    func onGettingCredentials(_ credentials: Credentials){
        let headers = ["token":credentials.idToken, "login_type":LoginType.PERSONAL]
        let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/health/profile" , headers: headers)
        _ = Amplify.API.get(request: request, listener: { (result) in
            switch result {
            case .success(let data):
                do {
                    let jsonData = try JSON(data: data)
                    let defaults = UserDefaults.standard
                    let keys = UserDefaultsKeys()
                    let userProfileData = jsonData["data"]
                    let weight = userProfileData[keys.weight].rawString()!
                    let height = userProfileData[keys.height].rawString()!
                    let gender = userProfileData[keys.gender].rawString()!
                    let birthday = userProfileData[keys.birthday].rawString()!
                    let unit = userProfileData[keys.unit].rawString()!
                    let devices = userProfileData[keys.devices].rawValue as? [String:[String:Int]]

                    var devicesStatus: [String:[String:Int]] = [:]

                    if !(weight.isEmpty) && weight != "null"{
                        defaults.set(weight, forKey: keys.weight)
                    }
                    if !(height.isEmpty) && height  != "null" {
                        defaults.set(height, forKey: keys.height)
                    }
                    if !(gender.isEmpty) && gender != "null" {
                        defaults.set(gender, forKey: keys.gender)
                    }
                    if !(birthday.isEmpty) && birthday != "null"{
                        defaults.set(birthday, forKey: keys.birthday)
                    }
                    if !(unit.isEmpty) && unit != "null" {
                        defaults.set(unit, forKey: keys.unit)
                    }else {
                        defaults.set(MeasurementUnits.metric, forKey: keys.unit)
                    }

                    if let fitbitStatus = devices?[ExternalDevices.FITBIT]{
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

    func onFailureCredentials(_ error: Error?) {
          print("failed to fetch credentials \(error)")
      }
    
    _ = getCredentials(completion: onGettingCredentials(_:), onFailure: onFailureCredentials(_:))
    getUserAttributes()
}

func updateHealthProfile(){
    func onGettingCredentials(_ credentials: Credentials){
        let headers = ["token":credentials.idToken, "login_type":LoginType.PERSONAL]
        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()
        let body = JSON([
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

        let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/health/profile" , headers: headers, body: bodyData)
        _ = Amplify.API.post(request: request, listener: { (result) in
            switch result{
            case .success(let data):
                let responseString = String(data: data, encoding: .utf8)
                print("sucess \(responseString)")
                updateSetupProfileCompletionStatus(currentState: .biodata)
                if let devices = defaults.object(forKey: keys.devices) as? [String:[String:Int]] {
                    let newDevices = [ExternalDevices.HEALTHKIT:["connected":1]]
                    let enhancedDevices = devices.merging(newDevices) {(_, newValues) in newValues }
                    defaults.set(enhancedDevices, forKey: keys.devices)
                } else {
                    let newDevices = [ExternalDevices.HEALTHKIT:["connected":1]]
                    defaults.set(newDevices, forKey: keys.devices)
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
}
