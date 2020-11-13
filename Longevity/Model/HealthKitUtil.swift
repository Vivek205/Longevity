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
            return "Male"
        case .female:
            return "Female"
        case .other:
            return "Other"
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
    let minimumHeightFt = 3.28
    let maximumHeightFt = 8.54
    let stepHeightFt = 0.01
    let minimumWeightKg = 28
    let maximumWeightKg = 200

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

    fileprivate func getMostRecentSample(for sampleType: HKSampleType,
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
            if let localGender = AppSyncManager.instance.healthProfile.value?.gender, !localGender.isEmpty {
                print("local gender", localGender)
            }else {
                AppSyncManager.instance.healthProfile.value?.gender = gender
            }

        }

        return self.userCharacteristicData
    }

    // MARK: Height
    func getHeightString(from heightSample: HKQuantitySample) -> String? {
        var heightString:String? = nil
        if self.selectedUnit == MeasurementUnits.metric {
            let heightInCentimeters = heightSample.quantity.doubleValue(for: HKUnit.meterUnit(with: .centi))
            heightString = "\(String(format: "%.0f", heightInCentimeters)) \(self.selectedUnit.height)"
            AppSyncManager.instance.healthProfile.value?.height = String(format: "%.0f",heightInCentimeters)
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
        guard let height = AppSyncManager.instance.healthProfile.value?.height, !height.isEmpty else { return nil}
        let heightInCenti = Measurement(value: (height as NSString).doubleValue, unit: UnitLength.centimeters)
        let heightInFeet = heightInCenti.converted(to: .feet)
        let feetInches = convertFeetToFeetInches(feet: heightInFeet.value)
        return feetInchesToString(feetInches: feetInches)
    }

    func getCentimeter(fromFeetInches value:String) -> String {

//        let feet = Measurement(value: (value as NSString).doubleValue, unit: UnitLength.feet)
        let feetValue = convertFeetInchesToFeet(feetInches: value)
        let feet = Measurement(value: feetValue, unit: UnitLength.feet)
        let centi = feet.converted(to: .centimeters)
        return String(format: "%.0f", centi.value)
    }

    func getFeet(fromCentimeter value:String) -> String {
        let centimeter = Measurement(value: (value as NSString).doubleValue, unit: UnitLength.centimeters)
        let feet = centimeter.converted(to: .feet)
        let feetInches = convertFeetToFeetInches(feet: feet.value)
        return feetInchesToString(feetInches: feetInches)
    }

    func convertFeetToFeetInches(feet: Double) -> (Double, Double)  {
        let splitFeet = modf(feet)
        var wholeFeet = splitFeet.0
        var wholeInches = round(splitFeet.1 * 12)

        if wholeInches == 12 {
            wholeInches = Double(0)
            wholeFeet += 1.0
        }
        return (wholeFeet, wholeInches)
    }

    func convertFeetInchesToFeet(feetInches: String) -> Double {
        let splitString = feetInches.components(separatedBy: "'")
        guard  let wholeFeet = Double(splitString[0]),
        let wholeInches = Double(splitString[1]) else {
            return Double(0)
        }
        let feet = wholeFeet + (wholeInches / 12)
        return feet
    }

    func feetInchesToString(feetInches:(Double, Double)) -> String{
        return  "\(String(format: "%.0f", feetInches.0))'\(String(format: "%.0f", feetInches.1))''"
    }
    

    func getHeightPickerOptions() -> [String] {
        var pickerData: [String] = [String]()
        switch selectedUnit {
        case .metric:
             pickerData = Array(minimumHeightCm...maximumHeightCm).map { "\($0) \(selectedUnit.height)"}
        case .imperial:
            for value in stride(from: minimumHeightFt, to: maximumHeightFt, by: stepHeightFt) {
                let feetInches = convertFeetToFeetInches(feet: value)
                pickerData.append("\(feetInchesToString(feetInches: feetInches)) \(self.selectedUnit.height)")
            }
        }
        let uniqueValues = pickerData.uniques
        return uniqueValues
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
            weightString = "\(String(format: "%.0f", weightInKilograms)) \(self.selectedUnit.weight)"
            AppSyncManager.instance.healthProfile.value?.weight = String(format: "%.0f",weightInKilograms)
        } else {
            let weightInPounds = weightSample.quantity.doubleValue(for: HKUnit.pound())
            weightString = "\(String(format: "%.0f", weightInPounds)) \(self.selectedUnit.weight)"
            // NOTE: Always store metric value in Appsync manager
            let weightInKilograms = weightSample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            AppSyncManager.instance.healthProfile.value?.weight = String(format: "%.0f",weightInKilograms)
        }
        return weightString
    }

    func getWeightStringInImperial() -> String? {
        guard let weight = AppSyncManager.instance.healthProfile.value?.weight, !weight.isEmpty else { return nil}
        let weightInKilo = Measurement(value: (weight as NSString).doubleValue, unit: UnitMass.kilograms)
        let weightInPounds = weightInKilo.converted(to: .pounds)
        return String(format: "%.0f", weightInPounds.value)
    }

    func getKilo(fromPounds value:String) -> String {
        let pounds = Measurement(value: (value as NSString).doubleValue, unit: UnitMass.pounds)
        let kilo = pounds.converted(to: .kilograms)
         return String(format: "%.0f", kilo.value)
    }

    func getPounds(fromKilo value:String) -> String {
        let kilo = Measurement(value: (value as NSString).doubleValue, unit: UnitMass.kilograms)
        let pounds = kilo.converted(to: .pounds)
        return String(format: "%.0f", pounds.value)
    }

    func getWeightPickerOptions() -> [String] {
           var pickerData: [String] = [String]()
           switch selectedUnit {
           case .metric:
                pickerData = Array(minimumWeightKg...maximumWeightKg).map { "\($0) \(selectedUnit.weight)"}
           case .imperial:
               pickerData = Array(minimumWeightKg...maximumWeightKg).map({[weak self] (value) -> String in
                let weightInKg = Measurement(value: Double(value), unit: UnitMass.kilograms)
                let weightInPounds = weightInKg.converted(to: .pounds)
                   return "\(String(format: "%.0f", weightInPounds.value)) \(self?.selectedUnit.weight ?? "")"
               })
           }
           return pickerData
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
