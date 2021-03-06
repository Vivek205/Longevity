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

class MedicalHistoryAPI: BaseAuthAPI {
    
    static var instance = MedicalHistoryAPI()
    
    func updateMedicalConditions() {
        //    func onGettingCredentials(_ credentials: Credentials){
        //        let headers = ["token":credentials.idToken, "login_type":LoginType.PERSONAL]
        
        let selectedConditions = preExistingMedicalConditionData.filter{$0.selected}
        let otherOption = preExistingMedicalCondtionOtherText
        
        struct UpdatedConditionsPayload {
            let condition: String
            let type: String
            let status: Int
        }
        
        var updatedConditions =  selectedConditions.map { (item) -> [String:String] in
            let value = ["condition": item.id.rawValue, "type":"PREDEFINDED"] as [String : String]
            return value
        }
        if !(otherOption?.isEmpty ?? false) {
            updatedConditions.append(["condition": otherOption!, "type": "OTHER"])
        }
        AppSyncManager.instance.healthProfile.value?.preExistingConditions = updatedConditions
        
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
        self.makeAPICall(callType: .apiPOST, request: request) { (data, error) in
            if error != nil {
                print("updateMedicalConditions failed \(error)")
            }
            
            guard let data = data else { return }
            let responseString = String(data: data, encoding: .utf8)
            print("sucess \(responseString)")
        }
        
        
        //            _ = Amplify.API.post(request: request, listener: { (result) in
        //                switch result{
        //                case .success(let data):
        //
        //                    case .failure(let apiError):
        //                    print("updateMedicalConditions failed \(apiError)")
        //                }
        //            })
        //        }
        //
        //        func onFailureCredentials(_ error: Error?) {
        //              print("updateMedicalConditions failed to fetch credentials \(error)")
        //          }
        //
        //        _ = getCredentials(completion: onGettingCredentials(_:), onFailure: onFailureCredentials(_:))
        
    }
    
    func updateHealthProfile() {
        //        func onGettingCredentials(_ credentials: Credentials){
        //            let headers = ["token":credentials.idToken, "login_type":LoginType.PERSONAL]
        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()
        var bodyDict:[String:Any] = [
            keys.weight: AppSyncManager.instance.healthProfile.value?.weight,
            keys.height: AppSyncManager.instance.healthProfile.value?.height,
            keys.gender: AppSyncManager.instance.healthProfile.value?.gender,
            keys.unit: AppSyncManager.instance.healthProfile.value?.unit.rawValue,
            keys.devices: AppSyncManager.instance.healthProfile.value?.devices
        ]
        
        if let birthday = AppSyncManager.instance.healthProfile.value?.birthday, !birthday.isEmpty {
            bodyDict[keys.birthday] = birthday
        }
        
        let body = JSON(bodyDict)
        
        var bodyData:Data = Data()
        do {
            bodyData = try body.rawData()
            print(String(data: bodyData, encoding: .utf8))
        } catch  {
            print(error)
        }
        
        let request = RESTRequest(apiName:"rejuveDevelopmentAPI", path: "/health/profile" , headers: headers, body: bodyData)
        self.makeAPICall(callType: .apiPOST, request: request) { (data, error) in
            if error != nil {
                print("updateHealthProfile failed \(error)")
                return
            }
            
            guard let data = data else { return }
            let responseString = String(data: data, encoding: .utf8)
            print("sucess \(responseString)")
        }
        //            _ = Amplify.API.post(request: request, listener: { (result) in
        //                switch result{
        //                case .success(let data):
        //                    let responseString = String(data: data, encoding: .utf8)
        //                    print("sucess \(responseString)")
        //                case .failure(let apiError):
        //                    print("updateHealthProfile failed \(apiError)")
        //                }
        //            })
        //        }
        
        //        func onFailureCredentials(_ error: Error?) {
        //              print("updateHealthProfile failed to fetch credentials \(error)")
        //          }
        //
        //        _ = getCredentials(completion: onGettingCredentials(_:), onFailure: onFailureCredentials(_:))
    }
}
