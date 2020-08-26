//
//  HealthkitUtil.swift
//  Longevity
//
//  Created by vivek on 24/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import HealthKit

fileprivate let healthKitStore: HKHealthStore = HKHealthStore()
fileprivate let defaults = UserDefaults.standard
fileprivate let keys = UserDefaultsKeys()

struct HealthkitCharacteristicUserData {
    var birthDate: DateComponents?
    var biologicalSex: HKBiologicalSex?
    var bloodType: HKBloodType?
    var currentAge: Int? {
        guard let birthDate = self.birthDate as? DateComponents else{
            return nil
        }
        let calendar = Calendar.current
        let date = calendar.date(from: birthDate)!
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"

        let currentYear = calendar.component(.year, from: Date())
        let currentAge = currentYear - birthDate.year!
        return currentAge
    }
    var birthDateString: String? {
        guard let birthDate = self.birthDate as? DateComponents else{
            return nil
        }
        let calendar = Calendar.current
        let date = calendar.date(from: birthDate)!
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let dateString = formatter.string(from: date)
        return dateString
    }
}

extension HKBiologicalSex {
    var string:String {
        switch self {
        case .male:
            return "male"
        case .female:
            return "female"
        case .other:
            return "other"
        case .notSet:
            return "notset"
        default:
            return ""
        }
    }
}


class HealthKitUtil {   
    var isHealthkitSynced:Bool {
        if let devices = defaults.object(forKey: keys.devices) as? [String:[String:Int]] {
            if let healthKitStatus = devices[ExternalDevices.HEALTHKIT] {
                return healthKitStatus["connected"] == 1
            }
        }
        return false
    }
    var selectedUnit: MeasurementUnits {
        get {
            if let measurementUnitRawValue = defaults.string(forKey: keys.unit) as? String {
                let unit = MeasurementUnits(rawValue: measurementUnitRawValue)
                return unit ?? MeasurementUnits.metric
            }
            return MeasurementUnits.metric
        }
        set(unit) {
            print("new unit value", unit)
            defaults.set(unit.rawValue, forKey: keys.unit)
        }
    }

    func setSelectedUnit(unit:MeasurementUnits) {
        self.selectedUnit = unit
    }

    func toggleSelectedUnit() {
        if selectedUnit == MeasurementUnits.metric {
            return setSelectedUnit(unit: MeasurementUnits.imperial)
        }
        return setSelectedUnit(unit: MeasurementUnits.metric)
    }

    var userCharacteristicData: HealthkitCharacteristicUserData?
    var latestHeightSample: HKQuantitySample?
    var latestWeightSample: HKQuantitySample?

    func authorize(completion: @escaping(_ success: Bool,_ error: Error?) -> Void) {
        guard let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
            let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
            let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
            let height = HKSampleType.quantityType(forIdentifier: .height)
            else {
                print("error", "data not available")
                return 
        }

        let healthKitTypesToWrite: Set<HKSampleType> = []
        let healthKitTypesToRead:Set<HKObjectType> = [dateOfBirth, biologicalSex,bloodType, bodyMass, height]


        healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite,
                                            read: healthKitTypesToRead)
        { (success, error) in
            if !success {
                print("error in health kit", error)
            } else {
                //                 MARK: Save healthkit status in userDefaults
                if let devices = defaults.object(forKey: keys.devices) as? [String:[String:Int]] {
                    let newDevices = [ExternalDevices.HEALTHKIT:["connected":1]]
                    let enhancedDevices = devices.merging(newDevices) {(_, newValues) in newValues }
                    defaults.set(enhancedDevices, forKey: keys.devices)
                } else {
                    let newDevices = [ExternalDevices.HEALTHKIT:["connected":1]]
                    defaults.set(newDevices, forKey: keys.devices)
                }
            }
            completion(success, error)
        }
    }

    func getMostRecentSample(for sampleType: HKSampleType,
                             completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {
        //1. Use HKQuery to load the most recent samples.
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                              end: Date(),
                                                              options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)
        let limit = 1
        let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                        predicate: mostRecentPredicate,
                                        limit: limit,
                                        sortDescriptors: [sortDescriptor])
        { (query, samples, error) in
            guard let samples = samples,
                let mostRecentSample = samples.first as? HKQuantitySample else {
                    print("most recent sample error", error)
                    completion(nil, error)
                    return
            }
            print("most recent sample", mostRecentSample)
            completion(mostRecentSample, nil)
        }
        HKHealthStore().execute(sampleQuery)
    }

    func readCharacteristicData() -> HealthkitCharacteristicUserData? {
        var birthDate: DateComponents?
        var biologicalSex: HKBiologicalSex?
        var bloodType: HKBloodType?

        do {
            birthDate = try healthKitStore.dateOfBirthComponents()
        } catch  {
            print(error)
        }
        do {
            let biologicalSexObject = try healthKitStore.biologicalSex()
            biologicalSex = biologicalSexObject.biologicalSex
        } catch  {
            print(error)
        }

        do {
            let bloodTypeObject = try healthKitStore.bloodType()
            bloodType = bloodTypeObject.bloodType
        } catch  {
            print(error)
        }
        self.userCharacteristicData = HealthkitCharacteristicUserData(birthDate: birthDate, biologicalSex: biologicalSex,bloodType: bloodType)
        return self.userCharacteristicData
    }

    // MARK: Height
    func getHeightString(from heightSample: HKQuantitySample) -> String? {
        var heightString:String? = nil
        if self.selectedUnit == MeasurementUnits.metric {
            let heightInCentimeters = heightSample.quantity.doubleValue(for: HKUnit.meterUnit(with: .centi))
            heightString = "\(String(format: "%.2f", heightInCentimeters)) \(self.selectedUnit.height)"
        } else {
            let heightInFeet = heightSample.quantity.doubleValue(for: HKUnit.foot())
            heightString = "\(String(format: "%.2f", heightInFeet)) \(self.selectedUnit.height)"
        }
        return heightString
    }

    func getHeightData(completion: @escaping(_ height: HKQuantitySample?,_ error: Error?) -> Void) {
        enum HeightError:Error {
            case heightNotFound
        }
        if self.latestHeightSample != nil {
            return completion(self.latestHeightSample, nil)
        }

        if let heightSampleType = HKSampleType.quantityType(forIdentifier: .height) {
            getMostRecentSample(for: heightSampleType) { (sample, error) in
                if error != nil {
                    return completion(nil, error)
                }
                if let heightSample = sample {
                    self.latestHeightSample = heightSample
                    return completion(heightSample, nil)
                }
            }
        } else {
            completion(nil, HeightError.heightNotFound)
        }
    }

    // MARK: Weight
    func getWeightString(from weightSample: HKQuantitySample) -> String? {
        var weightString:String? = nil
        if self.selectedUnit == MeasurementUnits.metric {
            let weightInKilograms = weightSample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            weightString = "\(String(format: "%.2f", weightInKilograms)) \(self.selectedUnit.weight)"
        } else {
            let weightInPounds = weightSample.quantity.doubleValue(for: HKUnit.pound())
            weightString = "\(String(format: "%.2f", weightInPounds)) \(self.selectedUnit.weight)"
        }
        return weightString
    }

    func getWeightData(completion: @escaping(_ weight: HKQuantitySample?,_ error: Error?) -> Void) {
        enum WeightError:Error {
            case weightNotFound
        }
        if self.latestWeightSample != nil {
            return completion(self.latestWeightSample, nil)
        }
        if let weightSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) {
            getMostRecentSample(for: weightSampleType){ (sample, error) in
                if error != nil {
                    completion(nil , error)
                }
                if let weightSample = sample {
                    self.latestWeightSample = weightSample
                    completion(weightSample, nil)
                }
            }
        }
        completion(nil, WeightError.weightNotFound)
    }
}
