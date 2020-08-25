//
//  HealthStore.swift
//
//  Created by Jagan Kumar Mudila on 5/12/19.
//  Copyright © 2019 ShreNIT. All rights reserved.
//

import Foundation
import HealthKit

struct HealthReading: Codable {
    let healthType: HealthType
    let healthValue: Double
    let healthValueText: String
    let lastUpdated: Date
}

enum HealthType: String, CaseIterable, Codable {
    case steps
    case flights
    case heartRate
    case walking
    case cycling
    case swimming
    case wheelchair
    case exercise
    case caloriesBurned
//    case StandTime
    case restingHeartRate
    case height
    case weight
    case bodymassindex
}

final class HealthStore {
    
    static let shared = HealthStore()
    
    private var healthStore : HKHealthStore?
    
    var healthReadings: [HealthReading] = [HealthReading]()
    
    private let healthDataTypes = Set([
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .flightsClimbed)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
        HKObjectType.quantityType(forIdentifier: .distanceSwimming)!,
        HKObjectType.quantityType(forIdentifier: .distanceWheelchair)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
//        HKObjectType.quantityType(forIdentifier: .appleStandTime)!,
        HKObjectType.quantityType(forIdentifier: .height)!,
        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
        HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!
    ])
    
    private init() {}
    
    func getHealthStore() -> HKHealthStore {
        if let healthStore = self.healthStore {
            return healthStore
        } else {
            healthStore = HKHealthStore()
            
            healthStore?.requestAuthorization(toShare: nil, read: healthDataTypes) {
                (success, error) in
                if !success {
                    // Handle the error here.
                } else {
                    self.startQueryingHealthData()
                }
            }
            return healthStore!
        }
    }
    
    func getChallengeCurrentValue(type: HealthType, completion: @escaping (_ currentValue: Double, _ currentValueText: String) -> Void) {
        switch type {
        case .steps:
            //Get steps data
            retrieveStepCount { (steps) in
                completion(steps, "\(Int(steps))")
            }
        case .flights:
            //Walking Distance
            retrieveFlightsClimbed(completion: { (floors) in
                completion(floors, "\(floors)")
            })
        case .heartRate:
            //Walking Distance
            retrieveHeartRate(completion: { (heartRate) in
                completion(heartRate, "\(heartRate)")
            })
        case .walking:
            //Walking Distance
            retrieveDistance(healthType: .walking) { (distance) in
                completion(distance, "\(distance)")
            }
        case .cycling:
            //Cycling Distance
            retrieveDistance(healthType: .cycling) { (distance) in
                completion(distance, "\(distance)")
            }
        case .swimming:
            //Swimming Distance
            retrieveDistance(healthType: .swimming) { (distance) in
                completion(distance, "\(distance)")
            }
        case .wheelchair:
            //Wheelchair Distance
            retrieveDistance(healthType: .wheelchair) { (distance) in
                completion(distance, "\(distance)")
            }
        case .exercise:
            //Exercise Minutes
            retrieveExerciseTime { (minutes) in
                completion(minutes, "\(Int(minutes))")
            }
        case .caloriesBurned:
            //Calories Burned
            retrieveActiveCaloriesBurned { (calories) in
                completion(calories, "\(calories)")
            }
        case .height:
            //Calories Burned
            retrieveHeight { (height) in
                completion(height, "\(Int(height))")
            }
        case .weight:
            //Calories Burned
            retrieveWeight { (weight) in
                completion(weight, "\(Int(weight))")
            }
        case .bodymassindex:
            //Calories Burned
            retrieveBMI(completion: { (bodymassindex) in
                completion(bodymassindex, "\(bodymassindex)")
            })
//        case .StandTime:
//            retrieveStandTime { (time) in
//                completion(time, "\(time)")
//            }
        case .restingHeartRate:
            retrieveRestingHeartRate(completion: { (heartRate) in
                completion(heartRate, "\(heartRate)")
            })
        }
    }
    
    //Get Steps Count
    func retrieveStepCount(completion: @escaping (_ stepRetrieved: Double) -> Void) {
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
                        completion(steps.rounded())
                    }
                })
            }
        }
        
        query.statisticsUpdateHandler = { query, statistics, statisticsCollection, error in
            // If new statistics are available
            if let sumQuantity = statistics?.sumQuantity() {
                let resultCount = sumQuantity.doubleValue(for: HKUnit.count())
                completion(resultCount.rounded())
            } // end if
        }
        
        healthStore?.execute(query)
    }
    
    //Get Floors Climbed
    func retrieveFlightsClimbed(completion: @escaping (_ flightClimbed: Double) -> Void) {
        
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
                        completion(flights.rounded())
                    }
                })
            }
        }
        
        query.statisticsUpdateHandler = { query, statistics, statisticsCollection, error in
            // If new statistics are available
            if let sumQuantity = statistics?.sumQuantity() {
                let resultCount = sumQuantity.doubleValue(for: HKUnit.count())
                completion(resultCount.rounded())
            } // end if
        }
        
        healthStore?.execute(query)
    }
    
    //Get Caolries Burned
    func retrieveActiveCaloriesBurned(completion: @escaping (_ calories: Double) -> Void) {
        
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
                        completion(calories)
                    }
                })
            }
        }
        
        query.statisticsUpdateHandler = { query, statistics, statisticsCollection, error in
            // If new statistics are available
            if let sumQuantity = statistics?.sumQuantity() {
                let resultCalories = sumQuantity.doubleValue(for: HKUnit.largeCalorie())
                completion(resultCalories)
            } // end if
        }
        
        healthStore?.execute(query)
    }
    
    //Get Distance for Walking, Swimming, Cycling & Wheelchair
    func retrieveDistance(healthType: HealthType, completion: @escaping (_ distance: Double) -> Void) {
        
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
                        completion(distance)
                    }
                })
            }
        }
        
        query.statisticsUpdateHandler = { query, statistics, statisticsCollection, error in
            // If new statistics are available
            if let quantity = statistics?.sumQuantity() {
                var distance = quantity.doubleValue(for: HKUnit.meter())
                distance = (100 * (distance / 1000)).rounded()/100
                completion(distance)
            } // end if
        }
        
        healthStore?.execute(query)
    }
    
    //Get Excercise Time
    func retrieveExerciseTime(completion: @escaping (_ time: Double) -> Void) {
        
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
                        completion(excerciseTime)
                    }
                })
            }
        }
        
        query.statisticsUpdateHandler = { query, statistics, statisticsCollection, error in
            // If new statistics are available
            if let quantity = statistics?.sumQuantity() {
                let excerciseTime = quantity.doubleValue(for: HKUnit.minute())
                completion(excerciseTime)
            }
        }
        
        healthStore?.execute(query)
    }
    
    //Get Excercise Time
    @available(iOS 13.0, *)
    func retrieveStandTime(completion: @escaping (_ time: Double) -> Void) {
        
        let standTime = HKQuantityType.quantityType(forIdentifier: .appleStandTime)
        
        let calendar = Calendar.current
        let anchorDate = calendar.startOfDay(for: Date())
        
        var interval = DateComponents()
        interval.day = 1
        
        //  Perform the Query
        let query = HKStatisticsCollectionQuery(quantityType: standTime!, quantitySamplePredicate: nil, options: [.cumulativeSum], anchorDate: anchorDate as Date, intervalComponents:interval)
        
        query.initialResultsHandler = { query, results, error in
            
            if error != nil {
                return
            }
            
            if let myResults = results{
                myResults.enumerateStatistics(from: anchorDate, to: Date(), with: {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        let standigmins = quantity.doubleValue(for: HKUnit.minute())
                        completion(standigmins)
                    }
                })
            }
        }
        
        query.statisticsUpdateHandler = { query, statistics, statisticsCollection, error in
            // If new statistics are available
            if let quantity = statistics?.sumQuantity() {
                let standigmins = quantity.doubleValue(for: HKUnit.minute())
                completion(standigmins)
            }
        }
        
        healthStore?.execute(query)
    }
    
    //Get Heart Rate
    func retrieveHeartRate(completion: @escaping (_ heartRate: Double) -> Void) {
        
        let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate)
        
        //  Set the Predicates & Interval
        var interval = DateComponents()
        interval.minute = 1
        
        //predicate
//        let calendar = NSCalendar.current
//        let now = Date()
//        let components = calendar.dateComponents([.year,.month,.day], from: now as Date)
//        guard let startDate:Date = calendar.date(from: components) else { return }
        
        
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
            
            if let resultArray = results, resultArray.isEmpty {
                
                for result in resultArray {
                    guard let beatsPerMinute: Double = (result as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit(from: "count/min")) else { return }
                    print("{ StartDate: \(result.startDate) , EndDate: \(result.endDate), HeartRate: \(beatsPerMinute) bpm }")
//                    completion(beatsPerMinute)
                }
                
                guard let beatsPerMinute: Double = (resultArray[0] as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit(from: "count/min")) else { return }
                completion(beatsPerMinute)
            }
        }
        healthStore?.execute(query)
    }
    
    //Get Heart Rate
    func retrieveHeartRate2(completion: @escaping (_ heartRate: Double) -> Void) {
        
        let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate)
        
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
            
            if let resultArray = results, resultArray.isEmpty {
                guard let beatsPerMinute: Double = (resultArray[0] as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit(from: "count/min")) else { return }
                completion(beatsPerMinute)
            }
        }
        healthStore?.execute(query)
    }
    
    func retrieveRestingHeartRate(completion: @escaping (_ heartRate: Double) -> Void) {
        
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
            
            if let resultArray = results, resultArray.isEmpty {
                guard let beatsPerMinute: Double = (resultArray[0] as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit(from: "count/min")) else { return }
                completion(beatsPerMinute)
            }
        }
        healthStore?.execute(query)
    }
    
    func retrieveHeight(completion: @escaping(_ height: Double) -> Void) {
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                              end: Date(),
                                                              options: .strictEndDate)
        let heightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
        let query = HKSampleQuery(sampleType: heightType, predicate: mostRecentPredicate, limit: 1, sortDescriptors: nil) { (query, results, error) in
            if let result = results?.first as? HKQuantitySample{
                completion(result.quantity.doubleValue(for: .meterUnit(with: .centi)))
            }
        }
        
        healthStore?.execute(query)
    }
    
    func retrieveWeight(completion: @escaping(_ weight: Double) -> Void) {
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date(),
                                                              end: Date(),
                                                              options: .strictEndDate)
        let weightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        let query = HKSampleQuery(sampleType: weightType, predicate: mostRecentPredicate, limit: 1, sortDescriptors: nil) { (query, results, error) in
            if let result = results?.first as? HKQuantitySample{
                completion(result.quantity.doubleValue(for: .gramUnit(with: .kilo)))
            }
        }
        
        healthStore?.execute(query)
    }
    
    func retrieveBMI(completion: @escaping(_ bmi: Double) -> Void) {
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date(),
                                                              end: Date(),
                                                              options: .strictEndDate)
        let bmiType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMassIndex)!
        let query = HKSampleQuery(sampleType: bmiType, predicate: mostRecentPredicate, limit: 1, sortDescriptors: nil) { (query, results, error) in
            if let result = results?.first as? HKQuantitySample{
                completion(result.quantity.doubleValue(for: .count()))
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
    
//    func startObservingHealthData() {
//        for type in healthDataTypes {
//            guard let sampleType = type as? HKSampleType else {
//                continue
//            }
//
//            let observerQuery: HKObserverQuery = HKObserverQuery(sampleType: sampleType, predicate: nil) { [weak self](query, completionHandler, error) in
//                self?.obServerQueryForSampleType(type: sampleType)
//                completionHandler()
//            }
//
//            healthStore?.execute(observerQuery)
//            healthStore?.enableBackgroundDelivery(for: sampleType, frequency: .immediate) { (completed, error) in
//                if !completed {
//                    if let theError = error{
//                        print("Failed to enable background health queries enabled")
//                        print("Error = \(theError)")
//                    }
//                }
//            }
//        }
//    }
    
    func startQueryingHealthData() {
        for type in healthDataTypes {
            guard let sampleType = type as? HKSampleType else {
                continue
            }
            
            self.queryForSampleType(type: sampleType)
        }
    }
    
    func queryForSampleType(type: HKSampleType) {
        
        switch type {
        case HKObjectType.quantityType(forIdentifier: .stepCount)!:
            retrieveStepCount { [weak self] (steps) in
                let stepsCount = steps >= 10000 ? "\(Double(steps / 10000))K" : "\(Int(steps))"
                self?.addHealthReading(healthReading: HealthReading(healthType: .steps, healthValue: steps, healthValueText: stepsCount, lastUpdated: Date()))
            }
        case HKObjectType.quantityType(forIdentifier: .flightsClimbed)!:
            retrieveFlightsClimbed { [weak self] (floors) in
                self?.addHealthReading(healthReading: HealthReading(healthType: .flights, healthValue: floors, healthValueText: "\(floors)", lastUpdated: Date()))
            }
        case HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!:
            retrieveDistance(healthType: .walking) { [weak self] (distance) in
                self?.addHealthReading(healthReading: HealthReading(healthType: .walking, healthValue: distance, healthValueText: "\(distance)", lastUpdated: Date()))
            }
        case HKObjectType.quantityType(forIdentifier: .distanceCycling)!:
            retrieveDistance(healthType: .cycling) { [weak self] (distance) in
                self?.addHealthReading(healthReading: HealthReading(healthType: .cycling, healthValue: distance, healthValueText: "\(distance)", lastUpdated: Date()))
            }
        case HKObjectType.quantityType(forIdentifier: .distanceSwimming)!:
            retrieveDistance(healthType: .swimming) { [weak self] (distance) in
                self?.addHealthReading(healthReading: HealthReading(healthType: .swimming, healthValue: distance, healthValueText: "\(distance)", lastUpdated: Date()))
            }
        case HKObjectType.quantityType(forIdentifier: .distanceWheelchair)!:
            retrieveDistance(healthType: .wheelchair) { [weak self] (distance) in
                self?.addHealthReading(healthReading: HealthReading(healthType: .wheelchair, healthValue: distance, healthValueText: "\(distance)", lastUpdated: Date()))
            }
        case HKObjectType.quantityType(forIdentifier: .heartRate)!:
            retrieveHeartRate { [weak self] (heartRate) in
                self?.addHealthReading(healthReading: HealthReading(healthType: .heartRate, healthValue: heartRate, healthValueText: "\(heartRate)", lastUpdated: Date()))
            }
        case HKObjectType.quantityType(forIdentifier: .restingHeartRate)!:
            retrieveRestingHeartRate { [weak self] (heartRate) in
                self?.addHealthReading(healthReading: HealthReading(healthType: .restingHeartRate, healthValue: heartRate, healthValueText: "\(heartRate)", lastUpdated: Date()))
            }
        case HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!:
            retrieveActiveCaloriesBurned { [weak self] (calories) in
                self?.addHealthReading(healthReading: HealthReading(healthType: .caloriesBurned, healthValue: calories, healthValueText: String(format: "%.2f", calories), lastUpdated: Date()))
            }
        case HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!:
            retrieveExerciseTime { [weak self] (time) in
                self?.addHealthReading(healthReading: HealthReading(healthType: .exercise, healthValue: time, healthValueText: "\(Int(time))", lastUpdated: Date()))
            }
//        case HKObjectType.quantityType(forIdentifier: .appleStandTime)!:
//            retrieveStandTime { [weak self] (time) in
//                self?.addHealthReading(healthReading: HealthReading(healthType: .StandTime, healthValue: time, healthValueText: "\(Int(time))", lastUpdated: Date()))
//            }
        case HKObjectType.quantityType(forIdentifier: .height)!:
            retrieveHeight { [weak self] (height) in
                self?.addHealthReading(healthReading: HealthReading(healthType: .height, healthValue: height, healthValueText: "\(Int(height))", lastUpdated: Date()))
            }
        case HKObjectType.quantityType(forIdentifier: .bodyMass)!:
            retrieveWeight { [weak self] (weight) in
                self?.addHealthReading(healthReading: HealthReading(healthType: .weight, healthValue: weight, healthValueText: "\(Int(weight))", lastUpdated: Date()))
            }
        case HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!:
            retrieveBMI { [weak self] (bodymassindex) in
                self?.addHealthReading(healthReading: HealthReading(healthType: .bodymassindex, healthValue: bodymassindex, healthValueText: "\(bodymassindex)", lastUpdated: Date()))
            }
        default:
            print("Unknown case")
        }
    }
    
//    func obServerQueryForSampleType(type: HKSampleType) {
//
//        switch type {
//        case HKObjectType.quantityType(forIdentifier: .stepCount)!:
//            retrieveStepCount { [weak self] (steps) in
//                self?.updateHealthChallenge(by: .Steps, currentValue: steps)
//            }
//        case HKObjectType.quantityType(forIdentifier: .flightsClimbed)!:
//            retrieveFlightsClimbed { [weak self] (floors) in
//                self?.updateHealthChallenge(by: .Flights, currentValue: floors)
//            }
//        case HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!:
//            retrieveDistance(healthType: .Walking) { [weak self] (distance) in
//                self?.updateHealthChallenge(by: .Walking, currentValue: distance)
//            }
//        case HKObjectType.quantityType(forIdentifier: .distanceCycling)!:
//            retrieveDistance(healthType: .Cycling) { [weak self] (distance) in
//                self?.updateHealthChallenge(by: .Cycling, currentValue: distance)
//            }
//        case HKObjectType.quantityType(forIdentifier: .distanceSwimming)!:
//            retrieveDistance(healthType: .Swimming) { [weak self] (distance) in
//                self?.updateHealthChallenge(by: .Swimming, currentValue: distance)
//            }
//        case HKObjectType.quantityType(forIdentifier: .distanceWheelchair)!:
//            retrieveDistance(healthType: .Wheelchair) { [weak self] (distance) in
//                self?.updateHealthChallenge(by: .Wheelchair, currentValue: distance)
//            }
//        case HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!:
//            retrieveActiveCaloriesBurned { [weak self] (calories) in
//                self?.updateHealthChallenge(by: .CaloriesBurned, currentValue: calories)
//            }
//        case HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!:
//            retrieveExerciseTime { [weak self] (time) in
//                self?.updateHealthChallenge(by: .Exercise, currentValue: time)
//            }
//        default:
//            return
//        }
//    }
    
    fileprivate func addHealthReading(healthReading: HealthReading) {
//        healthReadings.append(healthReading)
//
//        print(json(from: healthReadings))
    }
}
