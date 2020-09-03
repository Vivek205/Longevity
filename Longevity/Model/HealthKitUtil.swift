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


final class HealthKitUtil {
    private init() {
        self.readCharacteristicData()
        readHeightData(completion: nil)
        readWeightData(completion: nil)
        _ = self.selectedUnit
    }
    static let shared = HealthKitUtil()
    var isHealthkitSynced:Bool {
        if let healthkitConnected = UserDefaults.standard.value(forKey: UserDefaultsKeys().healthkitBioConnected) as? Bool {
            return healthkitConnected
        }
        return false
    }
    var selectedUnit: MeasurementUnits {
        get {
            if let unit = AppSyncManager.instance.healthProfile.value?.unit {
                return unit
            }

            return MeasurementUnits.metric
        }
        set(unit) {
            AppSyncManager.instance.healthProfile.value?.unit = unit
        }
    }
    let minimumHeightCm = 100
    let maximumHeightCm = 260

    func setSelectedUnit(unit:MeasurementUnits) {
        self.selectedUnit = unit
    }

    func toggleSelectedUnit() {

        if selectedUnit == MeasurementUnits.metric {
            setSelectedUnit(unit: MeasurementUnits.imperial)
        } else {
            setSelectedUnit(unit: MeasurementUnits.metric)
        }

//        guard self.isHealthkitSynced else {return}
//
//        if let heightSample = self.latestHeightSample {
//            _ = getHeightString(from: heightSample)
//        }
//        if let weightSample = self.latestWeightSample {
//            _ = getWeightString(from: weightSample)
//        }
        return
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
                UserDefaults.standard.set(true, forKey: UserDefaultsKeys().healthkitBioConnected)
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
        if let birthDateString = self.userCharacteristicData?.birthDateString {
            AppSyncManager.instance.healthProfile.value?.birthday = birthDateString
        }
        if let gender = self.userCharacteristicData?.biologicalSex?.string {
            AppSyncManager.instance.healthProfile.value?.gender = gender
        }

        return self.userCharacteristicData
    }

    // MARK: Height
    func getHeightString(from heightSample: HKQuantitySample) -> String? {
        var heightString:String? = nil
        if self.selectedUnit == MeasurementUnits.metric {
            let heightInCentimeters = heightSample.quantity.doubleValue(for: HKUnit.meterUnit(with: .centi))
            heightString = "\(String(format: "%.2f", heightInCentimeters)) \(self.selectedUnit.height)"
            AppSyncManager.instance.healthProfile.value?.height = String(format: "%.2f",heightInCentimeters)
        } else {
            let heightInFeet = heightSample.quantity.doubleValue(for: HKUnit.foot())
            heightString = "\(String(format: "%.2f", heightInFeet)) \(self.selectedUnit.height)"
            // NOTE: Always store metric value in Appsync manager
            let heightInCentimeters = heightSample.quantity.doubleValue(for: HKUnit.meterUnit(with: .centi))
            AppSyncManager.instance.healthProfile.value?.height = String(format: "%.2f",heightInCentimeters)
        }
        return heightString
    }

    func getHeightStringInImperial() -> String? {
        guard let height = AppSyncManager.instance.healthProfile.value?.height else { return nil}
        let heightInCenti = Measurement(value: (height as NSString).doubleValue, unit: UnitLength.centimeters)
        let heightInFeet = heightInCenti.converted(to: .feet)
        return String(format: "%.2f", heightInFeet.value)
    }

    func getHeightPickerOptions() -> [String]? {
        var pickerData: [String] = [String]()
        switch selectedUnit {
        case .metric:
            print("metric heights")
             pickerData = Array(minimumHeightCm...maximumHeightCm).map { "\($0) \(selectedUnit.height)"}
        case .imperial:
            let minCenti = Measurement(value: Double(minimumHeightCm), unit: UnitLength.centimeters)
            let minFeet = minCenti.converted(to: .feet)
            let maxCenti = Measurement(value: Double(maximumHeightCm), unit: UnitLength.centimeters)
            let maxFeet = maxCenti.converted(to: .feet)
//            pickerData = Array(minFeet.value...maxFeet.value){"\(String(format:"%.2f", $0)) \(selectedUnit.height)"}
            print("imperial heights")
        }
        return nil
    }

    func readHeightData(completion: ((_ height: HKQuantitySample?,_ error: Error?) -> Void)? = nil) {
        enum HeightError:Error {
            case heightNotFound
        }
        if self.latestHeightSample != nil {
            if completion != nil {
                completion!(self.latestHeightSample, nil)
            }
            return
        }

        if let heightSampleType = HKSampleType.quantityType(forIdentifier: .height) {
            getMostRecentSample(for: heightSampleType) { (sample, error) in
                if error != nil {
                    if completion != nil {
                        completion!(nil, error)
                    }
                    return
                }
                if let heightSample = sample {
                    self.latestHeightSample = heightSample
                    if completion != nil {
                        completion!(heightSample, nil)
                    }
                    return
                }
            }
        } else {
            if completion != nil {
                completion!(nil, HeightError.heightNotFound)
            }

        }
    }

    // MARK: Weight
    func getWeightString(from weightSample: HKQuantitySample) -> String? {
        var weightString:String? = nil
        if self.selectedUnit == MeasurementUnits.metric {
            let weightInKilograms = weightSample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            weightString = "\(String(format: "%.2f", weightInKilograms)) \(self.selectedUnit.weight)"
            AppSyncManager.instance.healthProfile.value?.weight = String(format: "%.2f",weightInKilograms)
        } else {
            let weightInPounds = weightSample.quantity.doubleValue(for: HKUnit.pound())
            weightString = "\(String(format: "%.2f", weightInPounds)) \(self.selectedUnit.weight)"
            // NOTE: Always store metric value in Appsync manager
            let weightInKilograms = weightSample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            AppSyncManager.instance.healthProfile.value?.weight = String(format: "%.2f",weightInKilograms)
        }
        return weightString
    }

    func getWeightStringInImperial() -> String? {
        guard let weight = AppSyncManager.instance.healthProfile.value?.weight else { return nil}
        let weightInKilo = Measurement(value: (weight as NSString).doubleValue, unit: UnitMass.kilograms)
        let weightInPounds = weightInKilo.converted(to: .pounds)
        return String(format: "%.2f", weightInPounds.value)
    }


    func readWeightData(completion: ((_ weight: HKQuantitySample?,_ error: Error?) -> Void)? = nil) {
        enum WeightError:Error {
            case weightNotFound
        }

        if self.latestWeightSample != nil {
            if completion != nil {
                completion!(self.latestWeightSample, nil)
            }
            return
        }
        if let weightSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) {
            getMostRecentSample(for: weightSampleType){ (sample, error) in
                if error != nil {
                    if completion != nil {
                        completion!(nil , error)
                    }
                    return
                }
                if let weightSample = sample {
                    self.latestWeightSample = weightSample
                    if completion != nil {
                         completion!(weightSample, nil)
                    }
                }
            }
        }
        if completion != nil {
            completion!(nil, WeightError.weightNotFound)
        }
    }
}
