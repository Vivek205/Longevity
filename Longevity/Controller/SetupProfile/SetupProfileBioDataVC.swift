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
        authorizeHealthKitInApp()
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
            self.readHealthData()
        }
    }
    
    func readHealthData(){
        do {
            let birthDate = try healthKitStore.dateOfBirthComponents()
            let calendar = Calendar.current
            let currentYear = calendar.component(.year, from: Date())
            let currentAge = currentYear - birthDate.year!
            print(currentAge)
        } catch  {
            print(error)
        }
        
        do {
            let biologicalSex = try healthKitStore.biologicalSex()
            let unwrappedBioSex = biologicalSex.biologicalSex
            
            switch unwrappedBioSex.rawValue{
            case 0:
                print("biological sex not set")
            case 1:
                print("female")
            case 2:
                print("male")
            case 3:
                print("other")
            default:
                print("not set")
            }
        } catch  {}
    }
    
}


extension SetupProfileBioDataVC: ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        taskViewController.dismiss(animated: true) {
            print("task view controller dismissed")
        }
    }
    
    
}

extension SetupProfileBioDataVC:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SetupProfileBioTitleCell", for: indexPath)
            return cell
        }
        if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SetupProfileBioInfoCell", for: indexPath)
            return cell
        }
        if indexPath.row == 8 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SetupProfileBioMetric", for: indexPath)
            return cell
        }
        print(setupProfileOptionList[indexPath.row])
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SetupProfileBioOptionCell", for: indexPath) as! SetupProfileBioOptionCell
        let option = setupProfileOptionList[indexPath.row]
        cell.logo.image = option?.image
        cell.label.text = option?.label
        cell.button.setTitle(option?.buttonText, for: .normal)
//        if indexPath.row != 2 {
//            cell.logo.layer.cornerRadius = cell.logo.frame.size.width/2
//            cell.logo.clipsToBounds = true
//            cell.logo.layer.borderColor = UIColor.white.cgColor
//            cell.logo.layer.borderWidth = 5.0
//        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = view.frame.size.height
        let width = view.frame.size.width
        return CGSize(width: width, height: CGFloat(60))
    }
    
}
