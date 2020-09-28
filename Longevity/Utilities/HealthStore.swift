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
    
    var healthReadings: [HealthReading] = [HealthReading]()
    
    private var healthDataTypes: Set<HKObjectType> {
        return Set([
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .flightsClimbed)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
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
            HKObjectType.categoryType(forIdentifier: .handwashingEvent)!
        ]) } else {
            return Set([
                HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
                HKObjectType.quantityType(forIdentifier: .distanceSwimming)!,
                HKObjectType.quantityType(forIdentifier: .distanceWheelchair)!,
                HKObjectType.quantityType(forIdentifier: .heartRate)!,
                HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
                HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!
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
        healthStore = HKHealthStore()
        if device == .applehealth {
            healthStore?.requestAuthorization(toShare: nil, read: healthDataTypes) {
                (success, error) in
                completion(success)
            }
        } else if device == .applewatch {
            healthStore?.requestAuthorization(toShare: nil, read: watchDataTypes) {
                (success, error) in
                completion(success)
            }
        }
    }
    
    //Get Steps Count
    func retrieveStepCount() {
        //   Define the Step Quantity Type
        let stepsCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        let calendar = Calendar.current
        let anchorDate = calendar.startOfDay(for: Date())
        var interval = DateComponents()
        interval.day = 1
        
        //  Perform the Query
        let query = HKStatisticsCollectionQuery(quantityType: stepsCount!, quantitySamplePredicate: nil, options: [.cumulativeSum], anchorDate: anchorDate, intervalComponents:interval)
        
        query.initialResultsHandler = { query, results, error in
            
            if error != nil {
                return
            }
            
            if let myResults = results{
                myResults.enumerateStatistics(from: anchorDate, to: Date(), with: {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        
                        let steps = quantity.doubleValue(for: HKUnit.count())
                        
                        var healthReadings = [HealthReading]()
                        let dateformatter = DateFormatter()
                        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        
                        healthReadings.append(HealthReading(value: steps.rounded(), unit: "steps", readingDate: dateformatter.string(from: Date())))
                        self.saveHealthData(healthType: .steps, healthReadings: healthReadings)
                    }
                })
            }
        }
        
        query.statisticsUpdateHandler = { query, statistics, statisticsCollection, error in
            // If new statistics are available
            if let sumQuantity = statistics?.sumQuantity() {
                let resultCount = sumQuantity.doubleValue(for: HKUnit.count())
                
                var healthReadings = [HealthReading]()
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                healthReadings.append(HealthReading(value: resultCount.rounded(), unit: "steps", readingDate: dateformatter.string(from: Date())))
                self.saveHealthData(healthType: .steps, healthReadings: healthReadings)
            } // end if
        }
        
        healthStore?.execute(query)
    }
    
    //Get Floors Climbed
    func retrieveFlightsClimbed() {
        
        //   Define the Step Quantity Type
        let flightsClimbed = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)
        
        let calendar = Calendar.current
        let anchorDate = calendar.startOfDay(for: Date())
        
        var interval = DateComponents()
        interval.day = 1
        
        //  Perform the Query
        let query = HKStatisticsCollectionQuery(quantityType: flightsClimbed!, quantitySamplePredicate: nil, options: [.cumulativeSum], anchorDate: anchorDate as Date, intervalComponents:interval)
        
        query.initialResultsHandler = { query, results, error in
            
            if error != nil {
                
                //  Something went Wrong
                return
            }
            
            if let myResults = results{
                myResults.enumerateStatistics(from: anchorDate, to: Date(), with: {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        
                        let flights = quantity.doubleValue(for: HKUnit.count())
                        var healthReadings = [HealthReading]()
                        let dateformatter = DateFormatter()
                        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        
                        healthReadings.append(HealthReading(value: flights.rounded(), unit: "floors", readingDate: dateformatter.string(from: Date())))
                        self.saveHealthData(healthType: .flights, healthReadings: healthReadings)
                    }
                })
            }
        }
        
        query.statisticsUpdateHandler = { query, statistics, statisticsCollection, error in
            // If new statistics are available
            if let sumQuantity = statistics?.sumQuantity() {
                let resultCount = sumQuantity.doubleValue(for: HKUnit.count())
                var healthReadings = [HealthReading]()
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                healthReadings.append(HealthReading(value: resultCount.rounded(), unit: "floors", readingDate: dateformatter.string(from: Date())))
                self.saveHealthData(healthType: .flights, healthReadings: healthReadings)
            } // end if
        }
        
        healthStore?.execute(query)
    }
    
    //Get Caolries Burned
    func retrieveActiveCaloriesBurned() {
        
        //   Define the calories burned
        let caloriesBurned = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)
        
        let calendar = Calendar.current
        let anchorDate = calendar.startOfDay(for: Date())
        
        var interval = DateComponents()
        interval.day = 1
        
        //  Perform the Query
        let query = HKStatisticsCollectionQuery(quantityType: caloriesBurned!, quantitySamplePredicate: nil, options: [.cumulativeSum], anchorDate: anchorDate as Date, intervalComponents:interval)
        
        query.initialResultsHandler = { query, results, error in
            
            if error != nil {
                
                //  Something went Wrong
                return
            }
            
            if let myResults = results {
                myResults.enumerateStatistics(from: anchorDate, to: Date(), with: {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        
                        let calories = quantity.doubleValue(for: HKUnit.largeCalorie())
                        var healthReadings = [HealthReading]()
                        let dateformatter = DateFormatter()
                        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        
                        healthReadings.append(HealthReading(value: calories, unit: "kCal", readingDate: dateformatter.string(from: Date())))
                        self.saveHealthData(healthType: .caloriesBurned, healthReadings: healthReadings)
                    }
                })
            }
        }
        
        query.statisticsUpdateHandler = { query, statistics, statisticsCollection, error in
            // If new statistics are available
            if let sumQuantity = statistics?.sumQuantity() {
                let resultCalories = sumQuantity.doubleValue(for: HKUnit.largeCalorie())
                var healthReadings = [HealthReading]()
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                healthReadings.append(HealthReading(value: resultCalories, unit: "kCal", readingDate: dateformatter.string(from: Date())))
                self.saveHealthData(healthType: .caloriesBurned, healthReadings: healthReadings)
            } // end if
        }
        
        healthStore?.execute(query)
    }
    
    //Get Distance for Walking, Swimming, Cycling & Wheelchair
    func retrieveDistance(healthType: HealthType) {
        
        let identifier = getHKQuantitytypeFor(healthType: healthType)
        
        let queryDistance = HKQuantityType.quantityType(forIdentifier: identifier)
        
        let calendar = Calendar.current
        let anchorDate = calendar.startOfDay(for: Date())
        
        var interval = DateComponents()
        interval.day = 1
        
        //  Perform the Query
        let query = HKStatisticsCollectionQuery(quantityType: queryDistance!, quantitySamplePredicate: nil, options: [.cumulativeSum], anchorDate: anchorDate as Date, intervalComponents:interval)
        
        query.initialResultsHandler = { query, results, error in
            
            if error != nil {
                return
            }
            
            if let myResults = results{
                myResults.enumerateStatistics(from: anchorDate, to: Date(), with: {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        var distance = quantity.doubleValue(for: HKUnit.meter())
                        distance = (100 * (distance / 1000)).rounded()/100
                         var healthReadings = [HealthReading]()
                                       let dateformatter = DateFormatter()
                                       dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                       
                                       healthReadings.append(HealthReading(value: distance, unit: "km", readingDate: dateformatter.string(from: Date())))
                                       self.saveHealthData(healthType: healthType, healthReadings: healthReadings)
                    }
                })
            }
        }
        
        query.statisticsUpdateHandler = { query, statistics, statisticsCollection, error in
            // If new statistics are available
            if let quantity = statistics?.sumQuantity() {
                var distance = quantity.doubleValue(for: HKUnit.meter())
                distance = (100 * (distance / 1000)).rounded()/100
                var healthReadings = [HealthReading]()
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                healthReadings.append(HealthReading(value: distance, unit: "km", readingDate: dateformatter.string(from: Date())))
                self.saveHealthData(healthType: healthType, healthReadings: healthReadings)
            } // end if
        }
        
        healthStore?.execute(query)
    }
    
    //Get Excercise Time
    func retrieveExerciseTime() {
        
        let exerciseTime = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)
        
        let calendar = Calendar.current
        let anchorDate = calendar.startOfDay(for: Date())
        
        var interval = DateComponents()
        interval.day = 1
        
        //  Perform the Query
        let query = HKStatisticsCollectionQuery(quantityType: exerciseTime!, quantitySamplePredicate: nil, options: [.cumulativeSum], anchorDate: anchorDate as Date, intervalComponents:interval)
        
        query.initialResultsHandler = { query, results, error in
            
            if error != nil {
                return
            }
            
            if let myResults = results{
                myResults.enumerateStatistics(from: anchorDate, to: Date(), with: {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        let excerciseTime = quantity.doubleValue(for: HKUnit.minute())
                        var healthReadings = [HealthReading]()
                        let dateformatter = DateFormatter()
                        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        
                        healthReadings.append(HealthReading(value: excerciseTime, unit: "min", readingDate: dateformatter.string(from: Date())))
                        self.saveHealthData(healthType: .exercise, healthReadings: healthReadings)
                    }
                })
            }
        }
        
        query.statisticsUpdateHandler = { query, statistics, statisticsCollection, error in
            // If new statistics are available
            if let quantity = statistics?.sumQuantity() {
                let excerciseTime = quantity.doubleValue(for: HKUnit.minute())
                var healthReadings = [HealthReading]()
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                healthReadings.append(HealthReading(value: excerciseTime, unit: "min", readingDate: dateformatter.string(from: Date())))
                self.saveHealthData(healthType: .exercise, healthReadings: healthReadings)
            }
        }
        
        healthStore?.execute(query)
    }
    
    //Get Heart Rate
    func retrieveHeartRate() {
        
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
        let query = HKSampleQuery( sampleType: heartRate!, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (_, results, error) in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            
            if let resultArray = results, !resultArray.isEmpty {
                
                var healthReadings = [HealthReading]()
                
                
                for result in resultArray {
                    guard let beatsPerMinute: Double = (result as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit(from: "count/min")) else { continue }
                    
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    
                    healthReadings.append(HealthReading(value: beatsPerMinute, unit: "bpm", readingDate: dateformatter.string(from: result.startDate)))
                }
                
                self.saveHealthData(healthType: .heartRate, healthReadings: healthReadings)
            }
        }
        healthStore?.execute(query)
    }
    
    func retrieveRestingHeartRate() {
        
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
        let query = HKSampleQuery( sampleType: heartRate!, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (_, results, error) in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            
            if let resultArray = results, !resultArray.isEmpty {
                var healthReadings = [HealthReading]()
                
                
                for result in resultArray {
                    guard let beatsPerMinute: Double = (result as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit(from: "count/min")) else { continue }
                    
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    
                    healthReadings.append(HealthReading(value: beatsPerMinute, unit: "bpm", readingDate: dateformatter.string(from: result.startDate)))
                }
                
                self.saveHealthData(healthType: .restingHeartRate, healthReadings: healthReadings)
            }
        }
        healthStore?.execute(query)
    }
    
    //Get Steps Count
    func retrieveOxygenSaturation() {
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
        let query = HKSampleQuery( sampleType: oxygenSaturation!, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (_, results, error) in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            
            if let resultArray = results, !resultArray.isEmpty {
                var healthReadings = [HealthReading]()
                
                
                for result in resultArray {
                    guard let oxygenPercentage: Double = (result as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit.percent()) else { continue }
                    
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    
                    healthReadings.append(HealthReading(value: oxygenPercentage, unit: "%", readingDate: dateformatter.string(from: result.startDate)))
                }
                
                self.saveHealthData(healthType: .oxygenlevel, healthReadings: healthReadings)
            }
        }
        healthStore?.execute(query)
    }
    
    //Get Handwashing Events
    @available(iOS 14.0, *)
    func retrieveHandwashingEvent() {
        
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
        let query = HKSampleQuery( sampleType: handwashingEvents!, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (_, results, error) in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            
            if let resultArray = results, !resultArray.isEmpty {
                var healthReadings = [HealthReading]()
                
                
                for result in resultArray {
                    guard let handwashtimes: Int = (result as? HKCategorySample)?.value else { continue }
                    
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    
                    healthReadings.append(HealthReading(value: 1.0, unit: "wash", readingDate: dateformatter.string(from: result.startDate)))
                }
                
                self.saveHealthData(healthType: .handwashing, healthReadings: healthReadings)
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
    
    func startQuerying(device: HealthDevices) {
        if device == .applehealth {
            self.startQueryingHealthData(dataTypes: self.healthDataTypes)
        } else if device == .applewatch {
            self.startQueryingHealthData(dataTypes: self.watchDataTypes)
        }
    }
    
    fileprivate func startObservingHealthData(dataTypes: Set<HKObjectType>) {
        for type in dataTypes {
            guard let sampleType = type as? HKSampleType else {
                continue
            }

            let observerQuery: HKObserverQuery = HKObserverQuery(sampleType: sampleType, predicate: nil) { [weak self](query, completionHandler, error) in
                self?.obServerQueryForSampleType(type: sampleType)
                completionHandler()
            }

            healthStore?.execute(observerQuery)
            healthStore?.enableBackgroundDelivery(for: sampleType, frequency: .immediate) { (completed, error) in
                if !completed {
                    if let theError = error{
                        print("Failed to enable background health queries enabled")
                        print("Error = \(theError)")
                    }
                }
            }
        }
    }
    
    fileprivate func startQueryingHealthData(dataTypes: Set<HKObjectType>) {
        for type in dataTypes {
            guard let sampleType = type as? HKSampleType else {
                continue
            }
            
            self.queryForSampleType(type: sampleType)
        }
    }
    
    func queryForSampleType(type: HKSampleType) {
            switch type {
            case HKObjectType.quantityType(forIdentifier: .stepCount)!:
                retrieveStepCount()
            case HKObjectType.quantityType(forIdentifier: .flightsClimbed)!:
                retrieveFlightsClimbed()
            case HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!:
                retrieveDistance(healthType: .walking)
            case HKObjectType.quantityType(forIdentifier: .distanceCycling)!:
                retrieveDistance(healthType: .cycling)
            case HKObjectType.quantityType(forIdentifier: .distanceSwimming)!:
                retrieveDistance(healthType: .swimming)
            case HKObjectType.quantityType(forIdentifier: .distanceWheelchair)!:
                retrieveDistance(healthType: .wheelchair)
            case HKObjectType.quantityType(forIdentifier: .heartRate)!:
                retrieveHeartRate()
            case HKObjectType.quantityType(forIdentifier: .restingHeartRate)!:
                retrieveRestingHeartRate()
            case HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!:
                retrieveActiveCaloriesBurned()
            case HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!:
                retrieveExerciseTime()
            case HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!:
                retrieveOxygenSaturation()
            default:
                break
            }
        
        if #available(iOS 14.0, *) {
            switch type {
            case HKObjectType.categoryType(forIdentifier: .handwashingEvent)!:
                retrieveHandwashingEvent()
            default:
                return
            }
        }
    }
    
    func obServerQueryForSampleType(type: HKSampleType) {
            switch type {
            case HKObjectType.quantityType(forIdentifier: .stepCount)!:
                retrieveStepCount()
            case HKObjectType.quantityType(forIdentifier: .flightsClimbed)!:
                retrieveFlightsClimbed()
            case HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!:
                retrieveDistance(healthType: .walking)
            case HKObjectType.quantityType(forIdentifier: .distanceCycling)!:
                retrieveDistance(healthType: .cycling)
            case HKObjectType.quantityType(forIdentifier: .distanceSwimming)!:
                retrieveDistance(healthType: .swimming)
            case HKObjectType.quantityType(forIdentifier: .distanceWheelchair)!:
                retrieveDistance(healthType: .wheelchair)
            case HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!:
                retrieveActiveCaloriesBurned()
            case HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!:
                retrieveExerciseTime()
            case HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!:
                retrieveOxygenSaturation()
            default:
                break
            }
        
        if #available(iOS 14.0, *) {
            switch type {
            case HKObjectType.categoryType(forIdentifier: .handwashingEvent)!:
                retrieveHandwashingEvent()
            default:
                return
            }
        }
    }
    
    fileprivate func saveHealthData(healthType: HealthType, healthReadings: [HealthReading]) {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        let date: String = dateformatter.string(from: Date())
        let healthData = Healthdata(dataType: healthType, data: healthReadings, recordDate: date)
        let healthKit = HealthkitAPI()
        healthKit.synchronizeHealthkit(healthData: healthData, completion: {
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
