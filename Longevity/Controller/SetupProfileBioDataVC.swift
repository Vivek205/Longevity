//
//  SetupProfileBioDataVC.swift
//  Longevity
//
//  Created by vivek on 16/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import HealthKit

let healthKitStore:HKHealthStore = HKHealthStore();

class SetupProfileBioDataVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        authorizeHealthKitInApp()

        // Do any additional setup after loading the view.
    }

    func authorizeHealthKitInApp() {
        guard let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
            let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass)
        else {
            return print("error", "data not available")
        }

        let healthKitTypesToWrite: Set<HKSampleType> = []
        let healthKitTypesToRead:Set<HKObjectType> = [dateOfBirth, biologicalSex, bodyMass]


        if !HKHealthStore.isHealthDataAvailable(){
           return print("health data not available")
        }

        healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) in
            if !success {
                return print("error in health kit", error)
            }
            print("success", success)
        }
    }

}
