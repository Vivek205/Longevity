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

func updateMedicalConditions() {
    func onGettingCredentials(_ credentials: Credentials){
        let headers = ["token":credentials.idToken, "login_type":LoginType.PERSONAL]

        let selectedConditions = preExistingMedicalConditionData.filter{$0.selected}
        let otherOption = preExistingMedicalCondtionOtherText

        struct UpdatedConditionsPayload {
            let condition: String
            let type: String
            let status: Int
        }

        var updatedConditions =  selectedConditions.map { (item) -> [String:Any] in
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
            print(String(data: bodyData, encoding: .utf8))

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
                print("updateMedicalConditions failed \(apiError)")
            }
        })
    }

    func onFailureCredentials(_ error: Error?) {
          print("updateMedicalConditions failed to fetch credentials \(error)")
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
                    let preExistingConditions = userProfileData["pre_existing_conditions"].rawValue as? [[String:String]]

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
                        defaults.set(MeasurementUnits.metric.rawValue, forKey: keys.unit)
                    }
                    if preExistingConditions != nil && !preExistingConditions!.isEmpty {
                        preExistingConditions?.forEach({ (condition) in
                            if condition["type"] == "PREDEFINDED" {
                                if let index = preExistingMedicalConditionData.firstIndex(where: { (item) -> Bool in
                                    return item.name == condition["condition"]
                                }) {
                                    preExistingMedicalConditionData[index].selected = true
                                }
                            } else if condition["type"] == "OTHER" {
                                preExistingMedicalCondtionOtherText = condition["condition"]
                            }

                        })
                    }


                    if let fitbitStatus = devices?[ExternalDevices.FITBIT] {
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
                print("getHealthProfile failed \(apiError)")
            }
        })
    }

    func onFailureCredentials(_ error: Error?) {
          print("getHealthProfile failed to fetch credentials \(error)")
      }
    
    _ = getCredentials(completion: onGettingCredentials(_:), onFailure: onFailureCredentials(_:))
    getUserAttributes()
}

func updateHealthProfile() {
    func onGettingCredentials(_ credentials: Credentials){
        let headers = ["token":credentials.idToken, "login_type":LoginType.PERSONAL]
        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()
        var bodyDict = [
            keys.weight: defaults.value(forKey: keys.weight),
            keys.height: defaults.value(forKey: keys.height),
            keys.gender: defaults.value(forKey: keys.gender),
            keys.birthday: defaults.value(forKey: keys.birthday),
            keys.unit: defaults.value(forKey: keys.unit)
        ]

        if let devices = defaults.object(forKey: keys.devices) as? [String:[String:Int]] {
            var devicesStatus:[String:[String:Int]] = [String:[String:Int]]()
            if let fitbitStatus = devices[ExternalDevices.FITBIT] as? [String: Int] {
                print("fitbitstatus", fitbitStatus)
                devicesStatus[ExternalDevices.FITBIT] = fitbitStatus
            }
            if let healthkitStatus = devices[ExternalDevices.HEALTHKIT] as? [String: Int] {
                devicesStatus[ExternalDevices.HEALTHKIT] = healthkitStatus
            }
            bodyDict["devices"] = devicesStatus
        }

        let body = JSON(bodyDict)

        var bodyData:Data = Data()
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
                print("updateHealthProfile failed \(apiError)")
            }
        })
    }

    func onFailureCredentials(_ error: Error?) {
          print("updateHealthProfile failed to fetch credentials \(error)")
      }

    _ = getCredentials(completion: onGettingCredentials(_:), onFailure: onFailureCredentials(_:))
}
