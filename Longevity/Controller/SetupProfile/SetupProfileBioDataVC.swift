//
//  SetupProfileBioDataVC.swift
//  Longevity
//
//  Created by vivek on 16/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import HealthKit
import ResearchKit

let healthKitStore:HKHealthStore = HKHealthStore();

class SetupProfileBioDataVC: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeBackButtonNavigation()
        collectionView.delegate = self
        collectionView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    // MARK: Actions
    @IBAction func consentTapped(sender: AnyObject) {
        //        MARK: Snippet for presenting consent
        //        let taskViewController = ORKTaskViewController(task: consentTask, taskRun: nil)
        //        taskViewController.delegate = self
        //        present(taskViewController, animated: true, completion: nil)
        let taskViewController = ORKTaskViewController(task: surveyTask, taskRun: nil)
        taskViewController.delegate = self
        present(taskViewController, animated: true, completion: nil)
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
                                    sortDescriptors: [sortDescriptor]) { (query, samples, error) in

        //2. Always dispatch to the main thread when complete.
        DispatchQueue.main.async {

          guard let samples = samples,
                let mostRecentSample = samples.first as? HKQuantitySample else {

                completion(nil, error)
                return
          }

          completion(mostRecentSample, nil)
        }
      }

    HKHealthStore().execute(sampleQuery)
    }

    func authorizeHealthKitInApp() {
        guard let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
            let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
            let height = HKSampleType.quantityType(forIdentifier: .height)
            else {
                return print("error", "data not available")
        }
        let healthKitTypesToWrite: Set<HKSampleType> = []
        let healthKitTypesToRead:Set<HKObjectType> = [dateOfBirth, biologicalSex, bodyMass, height]

        if !HKHealthStore.isHealthDataAvailable() {
            return print("health data not available")
        }
        healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite,
                                            read: healthKitTypesToRead)
        { (success, error) in
            if !success {
                return print("error in health kit", error)
            }
            print("success", success)
            self.readHealthData()
        }
    }
    
    func readHealthData(){
        // MARK: Read Age
        do {
            let birthDate = try healthKitStore.dateOfBirthComponents()
            let calendar = Calendar.current
            let currentYear = calendar.component(.year, from: Date())
            let currentAge = currentYear - birthDate.year!
            print(currentAge)
            setupProfileOptionList[4]?.buttonText = "\(currentAge)"
            setupProfileOptionList[4]?.isSynced = true
        } catch {
            print(error)
        }
        // MARK: Read Gender
        do {
            let biologicalSex = try healthKitStore.biologicalSex()
            let unwrappedBioSex = biologicalSex.biologicalSex
            
            switch unwrappedBioSex.rawValue{
            case 0:
                print("biological sex not set")
            case 1:
                setupProfileOptionList[3]?.buttonText = "female"
                setupProfileOptionList[3]?.isSynced = true
            case 2:
                setupProfileOptionList[3]?.buttonText = "male"
                setupProfileOptionList[3]?.isSynced = true
            case 3:
                setupProfileOptionList[3]?.buttonText = "other"
                setupProfileOptionList[3]?.isSynced = true
            default:
                print("not set")
            }
        } catch  {}

        // MARK: Read Height
        guard let heightSampleType = HKSampleType.quantityType(forIdentifier: .height) else {
          print("Height Sample Type is no longer available in HealthKit")
          return
        }
        getMostRecentSample(for: heightSampleType) { (sample, error) in
          guard let sample = sample else {
            if let error = error {print(error)}
            return
          }
          let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
          setupProfileOptionList[5]?.buttonText = "\(heightInMeters)"
 setupProfileOptionList[5]?.isSynced = true
        }

        // MARK: Read Weight
        guard let weightSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
          print("Body Mass Sample Type is no longer available in HealthKit")
          return
        }
        getMostRecentSample(for: weightSampleType){ (sample, error) in
          guard let sample = sample else {
            if let error = error {print(error)}
            return
          }
          let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
          setupProfileOptionList[6]?.buttonText = "\(weightInKilograms)"
            setupProfileOptionList[6]?.isSynced = true
        }

        // MARK: Reload the collection view
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}


extension SetupProfileBioDataVC: ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController,
                            didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        taskViewController.dismiss(animated: true) {
            print("task view controller dismissed")
        }
    }
}

extension SetupProfileBioDataVC: SetupProfileBioOptionCellDelegate {
    func button(wasPressedOnCell cell: SetupProfileBioOptionCell) {
        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()

        switch cell.label.text {
        case "Sync Apple Health Profile":
            authorizeHealthKitInApp()
            print("sync Health Kit")
        case "Gender":
            print("sync Health Kit", defaults.value(forKey: keys.gender))
        default:
            print("nothing happened")
        }
    }
}

extension SetupProfileBioDataVC:UICollectionViewDelegate,
UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier: "SetupProfileBioTitleCell", for: indexPath)
            return cell
        }
        if indexPath.row == 1 {
            let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier: "SetupProfileBioInfoCell", for: indexPath)
            return cell
        }
        if indexPath.row == 8 {
            let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier: "SetupProfileBioMetric", for: indexPath)
            return cell
        }
        let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: "SetupProfileBioOptionCell",
                for: indexPath) as! SetupProfileBioOptionCell
        let option = setupProfileOptionList[indexPath.row]
        cell.logo.image = option?.image
        cell.label.text = option?.label
        cell.button.setTitle(option?.buttonText, for: .normal)
        let isSynced = option?.isSynced
        if(isSynced == true){
            cell.button.layer.borderColor = UIColor.clear.cgColor
        }else {
            cell.button.layer.borderColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
        }
        cell.delegate = self
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = view.frame.size.height
        let width = view.frame.size.width
        return CGSize(width: width, height: CGFloat(60))
    }
}
