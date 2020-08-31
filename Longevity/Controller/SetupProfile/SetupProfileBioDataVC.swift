//
//  SetupProfileBioDataVC.swift
//  Longevity
//
//  Created by vivek on 16/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import HealthKit
//import ResearchKit

fileprivate let healthKitStore: HKHealthStore = HKHealthStore()

class SetupProfileBioDataVC: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var continueButton: CustomButtonFill!
    @IBOutlet weak var viewProgressBar: UIView!
    @IBOutlet weak var viewNavigationItem: UINavigationItem!
    @IBOutlet weak var footerView: UIView!
    
    let healthKitUtil: HealthKitUtil = HealthKitUtil.shared


    var toolBar = UIToolbar()
    var picker  = UIPickerView()
    var agePicker = UIDatePicker()
    var pickerData = [String]()
    var selectedPickerValue:String = ""
    var selectedAgePickerValue:Date = Date()

    var isFromSettings: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeBackButtonNavigation()
        collectionView.delegate = self
        collectionView.dataSource = self
        continueButton.isEnabled = false
        createPickersAndToolbar()
        self.readHealthData()
        checkIfHealthKitSyncedAlready()
        
        if self.isFromSettings {
            self.viewProgressBar.isHidden = true
            let leftbutton = UIBarButtonItem(image: UIImage(named: "icon: arrow")?.withHorizontallyFlippedOrientation(), style: .plain, target: self, action: #selector(closeView))
            leftbutton.tintColor = .themeColor
            let rightButton = UIBarButtonItem(title:"Done", style: .plain, target: self, action: #selector(doneUpdate))
              rightButton.tintColor = .themeColor
            self.viewNavigationItem.leftBarButtonItem = leftbutton
            self.viewNavigationItem.rightBarButtonItem = rightButton
            self.footerView.isHidden = true
        }
    }

    func checkIfHealthKitSyncedAlready() {
        if healthKitUtil.isHealthkitSynced {
            continueButton.isEnabled = true
        }
    }

    func createPickersAndToolbar() {
        // Picker
        picker.delegate = self
        picker.dataSource = self
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        picker.backgroundColor = UIColor.white
        picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)

        // DatePicker
        agePicker.autoresizingMask = .flexibleWidth
        agePicker.contentMode = .center
        agePicker.backgroundColor = UIColor.white
        agePicker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        agePicker.datePickerMode = .date
        agePicker.isHidden = false
        agePicker.addTarget(self, action: #selector(onAgeChanged(sender:)), for: .valueChanged)
        agePicker.maximumDate = Date()

        // Toolbar
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .blackTranslucent
        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]

    }

    func actualValue(selectedOption: String) -> Double {
        let indexOfSpace = selectedOption.firstIndex(of: " ")!
        let valueString: String = String(selectedOption[..<indexOfSpace])
        return Double(valueString)!
    }

    // MARK: Actions
    @IBAction func handleContinue(_ sender: Any) {
        updateHealthProfile()
        performSegue(withIdentifier: "SetupProfileBioDataToNotification", sender: self)
    }

    @IBAction func handleMetricTogglePress(_ sender: Any) {
        healthKitUtil.toggleSelectedUnit()
        self.readHealthData()
        return 

        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()

        func formatMass(measurement: Measurement<UnitMass>) -> String {
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 2
            let measurementFormatter = MeasurementFormatter()
            measurementFormatter.unitOptions = .providedUnit
            measurementFormatter.numberFormatter = numberFormatter
            let formattedMassString = measurementFormatter.string(from: measurement) // Culprit
            return formattedMassString
        }

        func formatLength(measurement: Measurement<UnitLength>) -> String {
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 2
            let measurementFormatter = MeasurementFormatter()
            measurementFormatter.unitOptions = .providedUnit
            measurementFormatter.numberFormatter = numberFormatter
            let formattedMassString = measurementFormatter.string(from: measurement) // Culprit
            return formattedMassString
        }

        if healthKitUtil.selectedUnit == MeasurementUnits.metric {
            healthKitUtil.selectedUnit = MeasurementUnits.imperial
            // WEIGHT
            if setupProfileOptionList[6]?.buttonText != "ENTER" && setupProfileOptionList[6]?.buttonText != "Enter" {
                let btnText = setupProfileOptionList[6]!.buttonText
                let weight = actualValue(selectedOption: btnText)
                let weightInKilograms = Measurement(value: weight, unit: UnitMass.kilograms)
                let weightInPounds = weightInKilograms.converted(to: .pounds)
                let weightString = formatMass(measurement: weightInPounds)
                setupProfileOptionList[6]?.buttonText = weightString
                defaults.set(actualValue(selectedOption: weightString), forKey: keys.weight)
                print(weightString)
            }
            // HEIGHT
            if setupProfileOptionList[5]?.buttonText != "ENTER" && setupProfileOptionList[5]?.buttonText != "Enter" {
                let btnText = setupProfileOptionList[5]!.buttonText
                let height = actualValue(selectedOption: btnText)
                let heightInCentimeters = Measurement(value: height, unit: UnitLength.centimeters)
                let heightInFeet = heightInCentimeters.converted(to: .feet)
                let heightString = formatLength(measurement: heightInFeet)
                setupProfileOptionList[5]?.buttonText = heightString
                defaults.set(actualValue(selectedOption: heightString), forKey: keys.height)
                print(heightString)
            }
        } else {
            healthKitUtil.selectedUnit = MeasurementUnits.metric
            // WEIGHT
            if setupProfileOptionList[6]?.buttonText != "ENTER" && setupProfileOptionList[6]?.buttonText != "Enter" {
                let btnText = setupProfileOptionList[6]!.buttonText
                let weight = actualValue(selectedOption: btnText)
                let weightInPounds = Measurement(value: weight, unit: UnitMass.pounds)
                let weightInKilograms = weightInPounds.converted(to: .kilograms)
                let weightString = formatMass(measurement: weightInKilograms)
                setupProfileOptionList[6]?.buttonText = weightString
                defaults.set(actualValue(selectedOption: weightString), forKey: keys.weight)
                print(weightString)
            }
            // HEIGHT
            if setupProfileOptionList[5]?.buttonText != "ENTER" && setupProfileOptionList[5]?.buttonText != "Enter" {
                let btnText = setupProfileOptionList[5]!.buttonText
                let height = actualValue(selectedOption: btnText)
                let heightInFeet = Measurement(value: height, unit: UnitLength.feet)
                let heightInCentimeters = heightInFeet.converted(to: .centimeters)
                let heightString = formatLength(measurement: heightInCentimeters)
                setupProfileOptionList[5]?.buttonText = heightString
                defaults.set(actualValue(selectedOption: heightString), forKey: keys.height)
                print(heightString)
            }
        }
        self.collectionView.reloadData()
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
        healthKitUtil.authorize
            { (success, error) in
                print("is healthkit authorized?", success)
                if !success {
                    print("Healthdata not authorized")
                    return
                }
                let healthKitUserData =  self.healthKitUtil.readCharacteristicData()
                DispatchQueue.main.async {
                    self.readHealthData()
                }
        }
    }
    
    func readHealthData() {
        if healthKitUtil.isHealthkitSynced {
            if healthKitUtil.selectedUnit == MeasurementUnits.metric {

            }
            healthKitUtil.readCharacteristicData()
            if let currentAge = healthKitUtil.userCharacteristicData?.currentAge {
                setupProfileOptionList[4]?.isSynced = true
                setupProfileOptionList[4]?.buttonText = "\(currentAge) years"
            }
            if let biologicalSex = healthKitUtil.userCharacteristicData?.biologicalSex {
                setupProfileOptionList[3]?.isSynced = true
                setupProfileOptionList[3]?.buttonText = biologicalSex.string
            }

            healthKitUtil.getHeightData {
                (height, error) in
                guard let heightSample = height as? HKQuantitySample else {return}
                let heightString = self.healthKitUtil.getHeightString(from: heightSample)
                DispatchQueue.main.async {
                    setupProfileOptionList[5]?.buttonText = heightString ?? ""
                    setupProfileOptionList[5]?.isSynced = true
                    self.continueButton.isEnabled = true
                    self.collectionView.reloadData()
                }
            }

            healthKitUtil.getWeightData {
                (weight, error) in
                if error != nil {
                    return
                }
                guard let weightSample = weight as? HKQuantitySample else {return}
                let weightString = self.healthKitUtil.getWeightString(from: weightSample)
                DispatchQueue.main.async {
                    setupProfileOptionList[6]?.buttonText = weightString ?? ""
                    setupProfileOptionList[6]?.isSynced = true
                    self.continueButton.isEnabled = true
                    self.collectionView.reloadData()
                }
            }
            self.continueButton.isEnabled = true
            self.collectionView.reloadData()
        }
    }
    
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func doneUpdate() {
        updateHealthProfile()
        self.dismiss(animated: true, completion: nil)
    }
}

extension SetupProfileBioDataVC: SetupProfileBioOptionCellDelegate {
    private struct PickerLabel {
        static let heightPicker = "height"
        static let weightPicker = "weight"
        static let agePicker = "age"
        static let genderPicker = "gender"
    }

    func showPicker() {
        self.view.addSubview(picker)
        self.view.addSubview(toolBar)
    }

    func removePickers() {
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
        agePicker.removeFromSuperview()
    }

    @objc func onDoneButtonTapped() {
        removePickers()
        updateUserDefaultsOnPickerDone()
    }

    func updateUserDefaultsOnPickerDone(selectedRow: Int = 0) {
        //        let selectedValue =  pickerData[selectedRow]
        let defaults = UserDefaults.standard
        let keys = UserDefaultsKeys()

        switch picker.accessibilityLabel {
        case PickerLabel.agePicker:
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let selectedDate: String = dateFormatter.string(from: selectedAgePickerValue)

            let calendar = Calendar.current
            let ageComponents = calendar.dateComponents([.year], from: selectedAgePickerValue, to: Date())
            let currentAge = ageComponents.year!

            setupProfileOptionList[4]?.buttonText = "\(currentAge) years"
            setupProfileOptionList[4]?.isSynced = true
            defaults.set(selectedDate, forKey: keys.birthday)
        case PickerLabel.genderPicker:
            setupProfileOptionList[3]?.buttonText = "\(selectedPickerValue)"
            setupProfileOptionList[3]?.isSynced = true
            defaults.set(selectedPickerValue, forKey:keys.gender)
        case PickerLabel.heightPicker:
            setupProfileOptionList[5]?.buttonText = "\(selectedPickerValue)"
            setupProfileOptionList[5]?.isSynced = true
            defaults.set(actualValue(selectedOption: selectedPickerValue), forKey:keys.height)

        case PickerLabel.weightPicker:
            setupProfileOptionList[6]?.buttonText = "\(selectedPickerValue)"
            setupProfileOptionList[6]?.isSynced = true
            defaults.set(actualValue(selectedOption: selectedPickerValue), forKey:keys.weight)

        default:
            print(picker.accessibilityLabel)
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    @objc func onAgeChanged(sender: UIDatePicker) {
        selectedAgePickerValue = sender.date
    }

    func showGenderPicker() {
        picker.selectRow(0, inComponent: 0, animated: true)
        pickerData = ["male", "female","other"]
        selectedPickerValue = pickerData[0]
        picker.accessibilityLabel = PickerLabel.genderPicker
        picker.reloadAllComponents()
        showPicker()
    }

    func showHeightPicker() {
        let minHeight = 20
        let maxHeight = 200
        pickerData = Array(minHeight...maxHeight).map { "\($0) \(healthKitUtil.selectedUnit.height)"}
        picker.selectRow(100, inComponent: 0, animated: true)
        selectedPickerValue = pickerData[0]
        picker.accessibilityLabel = PickerLabel.heightPicker
        picker.reloadAllComponents()
        showPicker()
    }

    func showWeightPicker() {
        let minWeight = 20.00
        let maxWeight = 200.00
        let step = 0.50
        pickerData = Array(stride(from: minWeight, to: maxWeight, by: step)).map { "\($0) \(healthKitUtil.selectedUnit.weight)" }
        picker.selectRow(40, inComponent: 0, animated: true)
        selectedPickerValue = pickerData[0]
        picker.accessibilityLabel = PickerLabel.weightPicker
        picker.reloadAllComponents()
        showPicker()
    }

    func showAgePicker() {
        removePickers()
        picker.accessibilityLabel = PickerLabel.agePicker
        self.view.addSubview(agePicker)
        self.view.addSubview(toolBar)
    }

    func button(wasPressedOnCell cell: SetupProfileBioOptionCell) {
        switch cell.label.text {
        case "Sync Apple Health Profile":
            authorizeHealthKitInApp()
        case "Gender":
            showGenderPicker()
        case "Age":
            print("gender")
            showAgePicker()
        case "Height":
            showHeightPicker()
        case "Weight":
            showWeightPicker()
        default:
            print("do nothing")
        }
    }
}

extension SetupProfileBioDataVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow pickerRow: Int, forComponent component: Int) -> String? {
        //        print("\(pickerData[row])")

        return String(pickerData[pickerRow])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow pickerRow: Int, inComponent component: Int) {
        selectedPickerValue = pickerData[pickerRow]
        //        handlePickerSelected(selectedRow: pickerRow)
    }
}

extension SetupProfileBioDataVC:UICollectionViewDelegate,
UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
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
        if indexPath.row == 7 {
            let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier: "SetupProfileBioMetric", for: indexPath) as! SetupProfileUnitSelectionCell

            if healthKitUtil.selectedUnit == MeasurementUnits.metric {
                cell.unitSwitch.isOn = true
                cell.unitSwitch.setOn(true, animated: true)
            }else {
                cell.unitSwitch.isOn = false
                cell.unitSwitch.setOn(false, animated: true)
            }

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
        cell.button.setImage(nil, for: .normal)
        let isSynced = option?.isSynced
        if(isSynced == true) {
            cell.button.layer.borderColor = UIColor.clear.cgColor
        }else {
            cell.button.layer.borderColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
        }
        cell.delegate = self

        // SYNC Button
        if indexPath.row == 2 && cell.label.text == "Sync Apple Health Profile" {
            if healthKitUtil.isHealthkitSynced {
                cell.button.setImage(#imageLiteral(resourceName: "icon: check mark"), for: .normal)
                cell.button.tintColor = #colorLiteral(red: 0.4175422788, green: 0.7088702321, blue: 0.7134250998, alpha: 1)
                cell.button.setTitle("SYNCED", for: .normal)
                cell.button.layer.borderColor = UIColor.clear.cgColor
            } else{
                cell.button.setImage(nil, for: .normal)
                cell.button.setTitle("SYNC", for: .normal)
                cell.button.layer.borderColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
            }
        }
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
