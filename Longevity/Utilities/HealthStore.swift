//
//  HealthStore.swift
//
//  Created by Jagan Kumar Mudila on 5/12/19.
//  Copyright © 2019 ShreNIT. All rights reserved.
//

import Foundation
import HealthKit

struct Healthdata: Codable {
    let dataType: HealthType
    let data: [HealthReading]
    let recordDate: String
}

struct HealthReading: Codable {
    let value: Double
    let unit: String
    let readingDate: String
}

enum HealthType: String, CaseIterable, Codable {
    case steps = "STEPS"
    case flights = "FLOORS_CLIMBED"
    case heartRate = "HEART_RATE"
    case walking = "WALKING_RUNNING_DISTANCE"
    case cycling = "CYCLING_DISTANCE"
    case swimming = "SWIMMING_DISTANCE"
    case wheelchair = "WHEELCHAIR_DISTANCE"
    case exercise = "EXERCISE_TIME"
    case caloriesBurned = "CALORIES_BURNED"
    case restingHeartRate = "RESTING_HEART_RATE"
    case handwashing = "HANDWASHING"
    case oxygenlevel = "OXYGEN_SATURATION"
}

final class HealthStore {
    
    static let shared = HealthStore()
    
    private var healthStore : HKHealthStore?
    
    private var operationQueue: OperationQueue?
    
    var healthReadings: [HealthReading] = [HealthReading]()
    
    private var healthDataTypes: Set<HKObjectType> {
        return Set([
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKSampleType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .flightsClimbed)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ])
    }
    
    private var watchDataTypes: Set<HKObjectType> {
        if #available(iOS 14.0, *) {
        return Set([
            HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
            HKObjectType.quantityType(forIdentifier: .distanceSwimming)!,
            HKObjectType.quantityType(forIdentifier: .distanceWheelchair)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
            HKObjectType.categoryType(forIdentifier: .handwashingEvent)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        ]) } else {
            return Set([
                HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
                HKObjectType.quantityType(forIdentifier: .distanceSwimming)!,
                HKObjectType.quantityType(forIdentifier: .distanceWheelchair)!,
                HKObjectType.quantityType(forIdentifier: .heartRate)!,
                HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
                HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
                HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
            ])
        }
    }
    
    private init() {}
    
    func getHealthStore() -> HKHealthStore {
        if let healthStore = self.healthStore {
            return healthStore
        } else {
            healthStore = HKHealthStore()
            return healthStore!
        }
    }
    
    func getHealthKitAuthorization(device: HealthDevices, completion: @escaping ((Bool) -> Void)) {
        if HKHealthStore.isHealthDataAvailable() {
            if self.healthStore == nil {
                self.healthStore = HKHealthStore()
            }
            if device == .applehealth {
                healthStore?.requestAuthorization(toShare: nil, read: healthDataTypes) { (success, error) in
                    completion(success)
                }
            } else if device == .applewatch {
                healthStore?.requestAuthorization(toShare: nil, read: watchDataTypes) { (success, error) in
                    completion(success)
                }
            }
        }
    }
    
    func getAllAuthorization() {
        if HKHealthStore.isHealthDataAvailable() {
            if self.healthStore == nil {
                self.healthStore = HKHealthStore()
            }
            let allHealthTypes = healthDataTypes.union(watchDataTypes)
            healthStore?.requestAuthorization(toShare: nil,
                                              read: allHealthTypes) { (success, error) in }
        }
    }
    
    //Get Steps Count
    func retrieveStepCount(completion: @escaping(() -> Void)) {
        //   Define the Step Quantity Type
        let stepsCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        let calendar = Calendar.current
        let anchorDate = calendar.startOfDay(for: Date())
        var interval = DateComponents()
        interval.day = 1
        
        let today = HKQuery.predicateForSamples(withStart: anchorDate, end: Date(), options: [])
        
        //  Perform the Query
        let query = HKStatisticsQuery(quantityType: stepsCount!,
                                      quantitySamplePredicate: today,
                                      options: [.cumulativeSum]) { [weak self] (query, statistics, error) in
            if error != nil {
                completion()
                return
            }
            
            if let quantity = statistics?.sumQuantity() {
                let steps = quantity.doubleValue(for: HKUnit.count())
                var healthReadings = [HealthReading]()
                
                healthReadings.append(HealthReading(value: steps.rounded(), unit: "steps",
                                                    readingDate: DateUtility.getTodayString()))
                self?.saveHealthData(deviceType: .applehealth, healthType: .steps, healthReadings: healthReadings)
            }
            completion()
        }
        
        healthStore?.execute(query)
    }
    
    //Get Floors Climbed
    func retrieveFlightsClimbed(completion: @escaping(() -> Void)) {
        let flightsClimbed = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)
        
        let calendar = Calendar.current
        let anchorDate = calendar.startOfDay(for: Date())
        
        let today = HKQuery.predicateForSamples(withStart: anchorDate, end: Date(), options: [])
        
        //  Perform the Query
        let query = HKStatisticsQuery(quantityType: flightsClimbed!,
                                      quantitySamplePredicate: today,
                                      options: [.cumulativeSum]) { [weak self] (query, statistics, error) in
            if error != nil {
                completion()
                return
            }
            
            if let quantity = statistics?.sumQuantity() {
                
                let flights = quantity.doubleValue(for: HKUnit.count())
                var healthReadings = [HealthReading]()
                
                healthReadings.append(HealthReading(value: flights.rounded(), unit: "floors",
                                                    readingDate: DateUtility.getTodayString()))
                self?.saveHealthData(deviceType: .applehealth,
                                    healthType: .flights, healthReadings: healthReadings)
            }
            completion()
        }
        
        healthStore?.execute(query)
    }
    
    //Get Caolries Burned
    func retrieveActiveCaloriesBurned(completion: @escaping(() -> Void)) {
        
        //   Define the calories burned
        let caloriesBurned = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)
        
        let calendar = Calendar.current
        let anchorDate = calendar.startOfDay(for: Date())
        
        let today = HKQuery.predicateForSamples(withStart: anchorDate, end: Date(), options: [])
        
        let query = HKStatisticsQuery(quantityType: caloriesBurned!,
                                      quantitySamplePredicate: today,
                                      options: [.cumulativeSum]) { [weak self] (query, statistics, error) in
            if error != nil {
                completion()
                return
            }
            
            if let quantity = statistics?.sumQuantity() {
                let calories = quantity.doubleValue(for: HKUnit.largeCalorie())
                var healthReadings = [HealthReading]()
                
                healthReadings.append(HealthReading(value: calories, unit: "kCal",
                                                    readingDate: DateUtility.getTodayString()))
                self?.saveHealthData(deviceType: .applewatch,healthType: .caloriesBurned, healthReadings: healthReadings)
            }
            completion()
        }
        
        healthStore?.execute(query)
    }
    
    //Get Distance for Walking, Swimming, Cycling & Wheelchair
    func retrieveDistance(healthType: HealthType, completion: @escaping(() -> Void)) {
        
        let identifier = getHKQuantitytypeFor(healthType: healthType)
        
        let queryDistance = HKQuantityType.quantityType(forIdentifier: identifier)
        
        let calendar = Calendar.current
        let anchorDate = calendar.startOfDay(for: Date())
        
        let today = HKQuery.predicateForSamples(withStart: anchorDate, end: Date(), options: [])
        
        let query = HKStatisticsQuery(quantityType: queryDistance!, quantitySamplePredicate: today,
                                      options: [.cumulativeSum]) { [weak self] (query, statistics, error) in
            if error != nil {
                completion()
                return
            }
            
            if let quantity = statistics?.sumQuantity() {
                var distance = quantity.doubleValue(for: HKUnit.meter())
                distance = (100 * (distance / 1000)).rounded()/100
                 var healthReadings = [HealthReading]()
                               
                               healthReadings.append(HealthReading(value: distance, unit: "km",
                                                                   readingDate: DateUtility.getTodayString()))
                let devicetype = healthType == .walking ? HealthDevices.applehealth : HealthDevices.applewatch
                self?.saveHealthData(deviceType: devicetype, healthType: healthType, healthReadings: healthReadings)
            }
            completion()
        }
        
        healthStore?.execute(query)
    }
    
    //Get Excercise Time
    func retrieveExerciseTime(completion: @escaping(() -> Void)) {
        
        let exerciseTime = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)
        
        let calendar = Calendar.current
        let anchorDate = calendar.startOfDay(for: Date())
        
        let today = HKQuery.predicateForSamples(withStart: anchorDate, end: Date(), options: [])
        
        let query = HKStatisticsQuery(quantityType: exerciseTime!,
                                      quantitySamplePredicate: today,
                                      options: [.cumulativeSum]) { [weak self] (query, statistics, error) in
            if error != nil {
                completion()
                return
            }
            
            if let quantity = statistics?.sumQuantity() {
                let excerciseTime = quantity.doubleValue(for: HKUnit.minute())
                var healthReadings = [HealthReading]()
                
                healthReadings.append(HealthReading(value: excerciseTime, unit: "min",
                                                    readingDate: DateUtility.getTodayString()))
                self?.saveHealthData(deviceType: .applewatch, healthType: .exercise, healthReadings: healthReadings)
            }
            completion()
        }
        
        healthStore?.execute(query)
    }
    
    //Get Heart Rate
    func retrieveHeartRate(completion: @escaping(() -> Void)) {
        
        let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate)
        
        //  Set the Predicates & Interval
        var interval = DateComponents()
        interval.minute = 1
        
        let calendar = Calendar.current
        let anchorDate = calendar.startOfDay(for: Date())
        
        let predicate = HKQuery.predicateForSamples(withStart: anchorDate, end: Date(), options: [])
        
        /// Set sorting by date.
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        /// Create the query
        let query = HKSampleQuery( sampleType: heartRate!, predicate: predicate,
                                   limit: Int(HKObjectQueryNoLimit),
                                   sortDescriptors: [sortDescriptor]) { [weak self] (_, results, error) in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                completion()
                return
            }
            
            if let resultArray = results, !resultArray.isEmpty {
                
                var healthReadings = [HealthReading]()
                
                for result in resultArray {
                    guard let beatsPerMinute: Double = (result as? HKQuantitySample)?.quantity.doubleValue(for:
                                                                                                            HKUnit(from: "count/min")) else { continue }
                    healthReadings.append(HealthReading(value: beatsPerMinute, unit: "bpm", readingDate:
                                                            DateUtility.getString(from: result.startDate)))
                }
                self?.saveHealthData(deviceType: .applewatch, healthType: .heartRate, healthReadings: healthReadings)
            }
            completion()
        }
        healthStore?.execute(query)
    }
    
    //Get Heart Rate Variability
    func retrieveHeartRateVariability(completion: @escaping(() -> Void)) {
        
        guard let heartRateVariability = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else { return }
        
        //  Set the Predicates & Interval
        var interval = DateComponents()
        interval.minute = 1
        
        let calendar = Calendar.current
        let anchorDate = calendar.startOfDay(for: Date())
        
        let today = HKQuery.predicateForSamples(withStart: anchorDate, end: Date(), options: [])
        
//        let query = HKStatisticsQuery(quantityType: heartRateVariability,
//                                      quantitySamplePredicate: today,
//                                      options: [.discreteMin, .discreteMax, .discreteAverage]) { [weak self] (query, statistics, error) in
//            if error != nil {
//                completion()
//                return
//            }
//
//            if let quantity = statistics?. {
//                let excerciseTime = quantity.doubleValue(for: HKUnit.minute())
//                var healthReadings = [HealthReading]()
//                let dateformatter = DateFormatter()
//                dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//
//                healthReadings.append(HealthReading(value: excerciseTime, unit: "min",
//                                                    readingDate: dateformatter.string(from: Date())))
//                self?.saveHealthData(deviceType: .applewatch, healthType: .exercise, healthReadings: healthReadings)
//            }
//            completion()
//        }
        
        
//        let calendar = Calendar.current
//        let anchorDate = calendar.startOfDay(for: Date())
//
//        let predicate = HKQuery.predicateForSamples(withStart: anchorDate, end: Date(), options: [])
//
//        /// Set sorting by date.
//        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
//
//        /// Create the query
//        let query = HKSampleQuery( sampleType: heartRateVariability, predicate: predicate,
//                                   limit: Int(HKObjectQueryNoLimit),
//                                   sortDescriptors: [sortDescriptor]) { (_, results, error) in
//            guard error == nil else {
//                print("Error: \(error!.localizedDescription)")
//                completion()
//                return
//            }
//
//            if let resultArray = results, !resultArray.isEmpty {
//
//                var healthReadings = [HealthReading]()
//
//                for result in resultArray {
//                    guard let beatsPerMinute: Double = (result as? HKQuantitySample)?.quantity.doubleValue(for:
//                                                                                                            HKUnit(from: "count/min")) else { continue }
//                    let dateformatter = DateFormatter()
//                    dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//                    healthReadings.append(HealthReading(value: beatsPerMinute, unit: "bpm", readingDate:
//                                                            dateformatter.string(from: result.startDate)))
//                }
//                self.saveHealthData(deviceType: .applewatch, healthType: .heartRate, healthReadings: healthReadings)
//            }
//            completion()
//        }
//        healthStore?.execute(query)
    }
    
    func retrieveRestingHeartRate(completion: @escaping(() -> Void)) {
        
        let heartRate = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)
        
        //  Set the Predicates & Interval
        var interval = DateComponents()
        interval.minute = 1
        
        //predicate
        let calendar = NSCalendar.current
        let current = Date()
        let components = calendar.dateComponents([.year,.month,.day], from: current as Date)
        guard let startDate:Date = calendar.date(from: components) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: [])
        
        /// Set sorting by date.
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        /// Create the query
        let query = HKSampleQuery( sampleType: heartRate!,
                                   predicate: predicate,
                                   limit: Int(HKObjectQueryNoLimit),
                                   sortDescriptors: [sortDescriptor]) { [weak self] (_, results, error) in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                completion()
                return
            }
            
            if let resultArray = results, !resultArray.isEmpty {
                var healthReadings = [HealthReading]()
                for result in resultArray {
                    guard let beatsPerMinute: Double = (result as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit(from: "count/min")) else { continue }

                    let dateString = DateUtility.getString(from: result.startDate)
                    healthReadings.append(HealthReading(value: beatsPerMinute, unit: "bpm",
                                                        readingDate: dateString))
                }
                self?.saveHealthData(deviceType: .applewatch, healthType: .restingHeartRate,
                                    healthReadings: healthReadings)
            }
            completion()
        }
        healthStore?.execute(query)
    }
    
    //Get Steps Count
    func retrieveOxygenSaturation(completion: @escaping(() -> Void)) {
        //   Define the Step Quantity Type
        let oxygenSaturation = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.oxygenSaturation)
        
        //  Set the Predicates & Interval
        var interval = DateComponents()
        interval.minute = 1
        
        //predicate
        let calendar = NSCalendar.current
        let current = Date()
        let components = calendar.dateComponents([.year,.month,.day], from: current as Date)
        guard let startDate:Date = calendar.date(from: components) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: [.strictEndDate])
        
        /// Set sorting by date.
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        /// Create the query
        let query = HKSampleQuery( sampleType: oxygenSaturation!,
                                   predicate: predicate,
                                   limit: Int(HKObjectQueryNoLimit),
                                   sortDescriptors: [sortDescriptor]) { [weak self] (_, results, error) in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                completion()
                return
            }
            
            if let resultArray = results, !resultArray.isEmpty {
                var healthReadings = [HealthReading]()
                for result in resultArray {
                    guard let oxygenPercentage: Double = (result as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit.percent()) else { continue }
                    healthReadings.append(HealthReading(value: oxygenPercentage, unit: "%", readingDate:
                                                            DateUtility.getString(from: result.startDate)))
                }
                
                self?.saveHealthData(deviceType: .applewatch, healthType: .oxygenlevel, healthReadings: healthReadings)
                completion()
            }
        }
        healthStore?.execute(query)
    }
    
    //Get Handwashing Events
    @available(iOS 14.0, *)
    func retrieveHandwashingEvent(completion: @escaping(() -> Void)) {
        
        let handwashingEvents = HKQuantityType.categoryType(forIdentifier: .handwashingEvent)
        
        //  Set the Predicates & Interval
        var interval = DateComponents()
        interval.minute = 1
        
        //predicate
        let calendar = NSCalendar.current
        let current = Date()
        let components = calendar.dateComponents([.year,.month,.day], from: current as Date)
        guard let startDate:Date = calendar.date(from: components) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: [.strictEndDate])
        
        /// Set sorting by date.
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        /// Create the query
        let query = HKSampleQuery( sampleType: handwashingEvents!,
                                   predicate: predicate, limit: Int(HKObjectQueryNoLimit),
                                   sortDescriptors: [sortDescriptor]) { [weak self] (_, results, error) in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                completion()
                return
            }
            
            if let resultArray = results, !resultArray.isEmpty {
                var healthReadings = [HealthReading]()
                
                for result in resultArray {
                    guard let handwashtimes: Int = (result as? HKCategorySample)?.value else { continue }
                    
                    healthReadings.append(HealthReading(value: 1.0, unit: "wash",
                                                        readingDate: DateUtility.getString(from: result.startDate)))
                }
                
                self?.saveHealthData(deviceType: .applewatch, healthType: .handwashing, healthReadings: healthReadings)
                completion()
            }
        }
        healthStore?.execute(query)
    }
    
    
    fileprivate func getHKQuantitytypeFor(healthType: HealthType) -> HKQuantityTypeIdentifier {
        switch healthType {
        case .walking:
            return .distanceWalkingRunning
        case .swimming:
            return .distanceSwimming
        case .cycling:
            return .distanceCycling
        case .wheelchair:
            return .distanceWheelchair
        default:
            return .init(rawValue: "Default")
        }
    }
    
    func startObserving(device: HealthDevices) {
        if device == .applehealth {
            self.startObservingHealthData(dataTypes: self.healthDataTypes)
        } else if device == .applewatch {
            self.startObservingHealthData(dataTypes: self.watchDataTypes)
        }
    }
    
    fileprivate func startObservingHealthData(dataTypes: Set<HKObjectType>) {
        for type in dataTypes {
            guard let sampleType = type as? HKSampleType else {
                continue
            }

            let observerQuery: HKObserverQuery = HKObserverQuery(sampleType: sampleType,
                                                                 predicate: nil) { [weak self](query, completionHandler, error) in
                self?.obServerQueryForSampleType(type: sampleType, completion: completionHandler)
            }

            healthStore?.execute(observerQuery)
            healthStore?.enableBackgroundDelivery(for: sampleType, frequency: .hourly) { (completed, error) in
                if !completed {
                    if let theError = error{
                        print("Failed to enable background health queries enabled")
                        print("Error = \(theError)")
                    }
                }
            }
        }
    }
    
    func obServerQueryForSampleType(type: HKSampleType, completion: @escaping(() -> Void)) {
            switch type {
            case HKObjectType.quantityType(forIdentifier: .stepCount)!:
                retrieveStepCount(completion: completion)
            case HKObjectType.quantityType(forIdentifier: .flightsClimbed)!:
                retrieveFlightsClimbed(completion: completion)
            case HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!:
                retrieveDistance(healthType: .walking, completion: completion)
            case HKObjectType.quantityType(forIdentifier: .distanceCycling)!:
                retrieveDistance(healthType: .cycling, completion: completion)
            case HKObjectType.quantityType(forIdentifier: .distanceSwimming)!:
                retrieveDistance(healthType: .swimming, completion: completion)
            case HKObjectType.quantityType(forIdentifier: .distanceWheelchair)!:
                retrieveDistance(healthType: .wheelchair, completion: completion)
            case HKObjectType.quantityType(forIdentifier: .heartRate)!:
                retrieveHeartRate(completion: completion)
            case HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!:
                retrieveActiveCaloriesBurned(completion: completion)
            case HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!:
                retrieveExerciseTime(completion: completion)
            case HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!:
                retrieveOxygenSaturation(completion: completion)
            case HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!:
                retrieveHeartRateVariability(completion: completion)
            default:
                break
            }
        
        if #available(iOS 14.0, *) {
            switch type {
            case HKObjectType.categoryType(forIdentifier: .handwashingEvent)!:
                retrieveHandwashingEvent(completion: completion)
            default:
                return
            }
        }
    }
    
    fileprivate func saveHealthData(deviceType: HealthDevices,healthType: HealthType, healthReadings: [HealthReading]) {
        if self.operationQueue == nil {
            self.operationQueue = OperationQueue()
            self.operationQueue?.maxConcurrentOperationCount = 3
        }
        self.operationQueue?.addOperation({
            let healthData = Healthdata(dataType: healthType, data: healthReadings, recordDate: DateUtility.getTodayString())
            HealthkitAPI.instance.synchronizeHealthkit(deviceName: deviceType.deviceType, healthData: healthData, completion: {
                
            }) { (error) in
                
            }
        })
    }
}
