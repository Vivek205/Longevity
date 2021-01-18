//
//  SetupProfileBioDataVC.swift
//  Longevity
//
//  Created by vivek on 16/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import HealthKit
//import CoreLocation
//import ResearchKit

fileprivate let healthKitStore: HKHealthStore = HKHealthStore()

class SetupProfileBioDataVC: BaseProfileSetupViewController {
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var continueButton: CustomButtonFill!
    @IBOutlet weak var viewProgressBar: UIView!
    @IBOutlet weak var viewNavigationItem: UINavigationItem!
    @IBOutlet weak var footerView: UIView!
    
    var modalPresentation = false
    var changesSaved = true
    
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
        
        createPickersAndToolbar()
        
        if self.isFromSettings {
            let leftbutton = UIBarButtonItem(title:"Cancel", style: .plain, target: self, action: #selector(closeView))
            leftbutton.tintColor = .themeColor
            let rightButton = UIBarButtonItem(title:"Save", style: .plain, target: self, action: #selector(doneUpdate))
            rightButton.tintColor = .themeColor
            self.viewNavigationItem.leftBarButtonItem = leftbutton
            self.viewNavigationItem.rightBarButtonItem = rightButton
            
            let titleLabel = UILabel()
            titleLabel.text = "Update Biometrics"
            titleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 17.0)
            titleLabel.textColor = UIColor(hexString: "#4E4E4E")
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            self.navigationController?.navigationBar.tintColor = UIColor(hexString: "#FFFFFF")
            self.navigationItem.titleView = titleLabel
            
            self.footerView.isHidden = true
        } else {
            self.addProgressbar(progress: 40.0)
        }
        
        let footerheight: CGFloat = self.isFromSettings ? 0.0 : UIDevice.hasNotch ? 130.0 : 96.0
        
        NSLayoutConstraint.activate([
            self.footerView.heightAnchor.constraint(equalToConstant: footerheight)
        ])
        
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        layout.invalidateLayout()
        
        if self.modalPresentation {
            if #available(iOS 13.0, *) {
                self.isModalInPresentation = true
                self.navigationController?.presentationController?.delegate = self
            }
        }
        
        AppSyncManager.instance.healthProfile.addAndNotify(observer: self) { [weak self] in
            let profile = AppSyncManager.instance.healthProfile.value
            DispatchQueue.main.async {
                
                if let devices = AppSyncManager.instance.healthProfile.value?.devices,
                   let _ = devices[ExternalDevices.healthkit] {
                    self?.collectionView.reloadItems(at: [IndexPath(item: 2, section: 0)])
                }
                
                if let gender = AppSyncManager.instance.healthProfile.value?.gender, !gender.isEmpty {
                    setupProfileOptionList[3]?.buttonText = gender.capitalizeFirstChar()
                    setupProfileOptionList[3]?.isSynced = true
                    self?.collectionView.reloadItems(at: [IndexPath(item: 3, section: 0)])
                }
                
                self?.selectedAgePickerValue = Calendar.current.date(byAdding: .year, value: -20, to: Date()) ?? Date()
                
                if let birthday = AppSyncManager.instance.healthProfile.value?.birthday, !birthday.isEmpty {
                    setupProfileOptionList[4]?.buttonText = self?.calculateAge(birthDate: birthday) ?? ""
                    setupProfileOptionList[4]?.isSynced = true
                    self?.collectionView.reloadItems(at: [IndexPath(item: 4, section: 0)])
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd-MM-yyyy"
                    if let birthDate = formatter.date(from: birthday) {
                        self?.selectedAgePickerValue = birthDate
                    }
                }
                
                if var height = AppSyncManager.instance.healthProfile.value?.height,
                   !height.isEmpty,
                   let unit = AppSyncManager.instance.healthProfile.value?.unit {
                    if unit == .imperial {
                        height = self?.healthKitUtil.getHeightStringInImperial() ?? ""
                    }
                    
                    if !height.isEmpty {
                        setupProfileOptionList[5]?.buttonText = "\(height) \(unit.height)"
                        setupProfileOptionList[5]?.isSynced = true
                        self?.collectionView.reloadItems(at: [IndexPath(item: 5, section: 0)])
                    }
                }
                
                if var weight = AppSyncManager.instance.healthProfile.value?.weight, !weight.isEmpty,
                   let unit = AppSyncManager.instance.healthProfile.value?.unit {
                    if unit == .imperial {
                        weight = self?.healthKitUtil.getWeightStringInImperial() ?? ""
                    }
                    if !weight.isEmpty {
                        setupProfileOptionList[6]?.buttonText = "\(weight) \(unit.weight)"
                        setupProfileOptionList[6]?.isSynced = true
                        self?.collectionView.reloadItems(at: [IndexPath(item: 6, section: 0)])
                    }
                }
                
                if let location = AppSyncManager.instance.healthProfile.value?.location {
                    var locationString = ""
                    if let city = location.city,
                       let state = location.state
                    {
                        locationString = "\(city), \(state)"
                    }
                    if  let postalCode = location.zipcode {
                        locationString = "\(locationString) zip: \(postalCode)"
                    }
                    
                    if !locationString.isEmpty {
                        setupProfileOptionList[7]?.buttonText = locationString
                        setupProfileOptionList[7]?.isSynced = true
                        let indexPath = NSIndexPath(row: 7, section: 0) as IndexPath
                        self?.collectionView.reloadItems(at: [indexPath])
                    }
                }
            }
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
        picker.setValue(UIColor.sectionHeaderColor, forKey: "textColor")
        
        // DatePicker
        agePicker.autoresizingMask = .flexibleWidth
        agePicker.contentMode = .center
        agePicker.backgroundColor = UIColor.white
        agePicker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        agePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            agePicker.preferredDatePickerStyle = .wheels
        }
        agePicker.isHidden = false
        agePicker.backgroundColor = .white
        agePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        agePicker.date = self.selectedAgePickerValue
        agePicker.addTarget(self, action: #selector(onAgeChanged(sender:)), for: .valueChanged)
        agePicker.setValue(UIColor.sectionHeaderColor, forKey: "textColor")
        
        // Toolbar
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .blackTranslucent
        toolBar.tintColor = .white
        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]
    }
    
    func actualValue(selectedOption: String) -> Double {
        let indexOfSpace = selectedOption.firstIndex(of: " ")!
        let valueString: String = String(selectedOption[..<indexOfSpace])
        return Double(valueString)!
    }
    
    // MARK: Actions
    @IBAction func handleContinue(_ sender: Any) {
        MedicalHistoryAPI.instance.updateHealthProfile()
        performSegue(withIdentifier: "SetupProfileBioDataToNotification", sender: self)
    }
    
    @IBAction func handleMetricTogglePress(_ sender: Any) {
        self.removePickers()
        healthKitUtil.toggleSelectedUnit()
        switch healthKitUtil.selectedUnit {
        case .metric:
            if let height = AppSyncManager.instance.healthProfile.value?.height, !height.isEmpty {
                setupProfileOptionList[5]?.buttonText = "\(height) \(healthKitUtil.selectedUnit.height)"
                self.collectionView.reloadItems(at: [IndexPath(item: 5, section: 0)])
            }
            if let weight = AppSyncManager.instance.healthProfile.value?.weight, !weight.isEmpty {
                setupProfileOptionList[6]?.buttonText = "\(weight) \(healthKitUtil.selectedUnit.weight)"
                self.collectionView.reloadItems(at: [IndexPath(item: 6, section: 0)])
            }
            break
        case .imperial:
            if let height = healthKitUtil.getHeightStringInImperial() {
                setupProfileOptionList[5]?.buttonText = "\(height) \(healthKitUtil.selectedUnit.height)"
                self.collectionView.reloadItems(at: [IndexPath(item: 5, section: 0)])
            }
            if let weight = healthKitUtil.getWeightStringInImperial() {
                setupProfileOptionList[6]?.buttonText = "\(weight) \(healthKitUtil.selectedUnit.weight)"
                self.collectionView.reloadItems(at: [IndexPath(item: 6, section: 0)])
            }
            
            break
        }
        return
    }
    
    func authorizeHealthKitInApp() {
        let appleHealthViewController = AppleHealthConnectionViewController()
        appleHealthViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: appleHealthViewController)
        NavigationUtility.presentOverCurrentContext(destination: navigationController)
    }
    
    func readHealthData() {
        if let characteristicData = healthKitUtil.readCharacteristicData() {
        }
        
        healthKitUtil.readHeightData {
            (height, error) in
            guard let heightSample = height as? HKQuantitySample else {return}
            let _ = self.healthKitUtil.getHeightString(from: heightSample)
            DispatchQueue.main.async {
                self.continueButton.isEnabled = true
            }
        }
        
        healthKitUtil.readWeightData {
            (weight, error) in
            if error != nil {
                return
            }
            guard let weightSample = weight as? HKQuantitySample else {return}
            let _ = self.healthKitUtil.getWeightString(from: weightSample)
            DispatchQueue.main.async {
                self.continueButton.isEnabled = true
            }
        }
    }
    
    @objc func closeView() {
        if changesSaved {
            self.dismiss(animated: true, completion: nil)
            return
        }
        let alertVC = UIAlertController(title: nil, message: "You have unsaved changes", preferredStyle: .actionSheet)
        let saveChanges = UIAlertAction(title: "Save Changes", style: .default) { [weak self] (action) in
            self?.doneUpdate()
        }
        saveChanges.setValue(UIColor.themeColor, forKey: "titleTextColor")
        let dismiss = UIAlertAction(title: "Discard", style: .destructive) {[weak self] (action) in
            self?.dismiss(animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) {[weak self] (action) in
        }
        cancel.setValue(UIColor.themeColor, forKey: "titleTextColor")
        alertVC.addAction(saveChanges)
        alertVC.addAction(dismiss)
        alertVC.addAction(cancel)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @objc func doneUpdate() {
        MedicalHistoryAPI.instance.updateHealthProfile()
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
        changesSaved = false
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
            AppSyncManager.instance.healthProfile.value?.birthday = selectedDate
        case PickerLabel.genderPicker:
            setupProfileOptionList[3]?.buttonText = "\(selectedPickerValue)"
            setupProfileOptionList[3]?.isSynced = true
            AppSyncManager.instance.healthProfile.value?.gender = selectedPickerValue
        case PickerLabel.heightPicker:
            setupProfileOptionList[5]?.buttonText = "\(selectedPickerValue)"
            setupProfileOptionList[5]?.isSynced = true
            var splitValue = selectedPickerValue.components(separatedBy: " ")[0]
            if healthKitUtil.selectedUnit == .imperial {
                splitValue = healthKitUtil.getCentimeter(fromFeetInches: splitValue)
            }
            AppSyncManager.instance.healthProfile.value?.height = splitValue
            
        case PickerLabel.weightPicker:
            setupProfileOptionList[6]?.buttonText = "\(selectedPickerValue)"
            setupProfileOptionList[6]?.isSynced = true
            var splitValue = selectedPickerValue.components(separatedBy: " ")[0]
            if healthKitUtil.selectedUnit == .imperial {
                splitValue = healthKitUtil.getKilo(fromPounds: splitValue)
            }
            AppSyncManager.instance.healthProfile.value?.weight = splitValue
            
        default:
            print(picker.accessibilityLabel)
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    @objc func onAgeChanged(sender: UIDatePicker) {
        changesSaved = false
        selectedAgePickerValue = sender.date
    }
    
    func showGenderPicker() {
        pickerData = ["Male", "Female", "Other"]
        if let gender = AppSyncManager.instance.healthProfile.value?.gender,
           let genderIndex = pickerData.firstIndex(of: gender){
            selectedPickerValue = gender.capitalizeFirstChar()
            picker.selectRow(genderIndex, inComponent: 0, animated: true)
            selectedPickerValue = pickerData[genderIndex]
        } else {
            picker.selectRow(0, inComponent: 0, animated: true)
            selectedPickerValue = pickerData[0]
        }
        picker.accessibilityLabel = PickerLabel.genderPicker
        picker.reloadAllComponents()
        showPicker()
    }
    
    func showHeightPicker() {
        pickerData = healthKitUtil.getHeightPickerOptions()
        picker.selectRow(30, inComponent: 0, animated: true)
        selectedPickerValue = pickerData[30]

        if var height = AppSyncManager.instance.healthProfile.value?.height,
           let unit = AppSyncManager.instance.healthProfile.value?.unit {
            if unit == .imperial {
                height = healthKitUtil.getFeet(fromCentimeter: height)
            }
            if let heightIndex = pickerData.firstIndex(of: "\(height) \(healthKitUtil.selectedUnit.height)") {
                selectedPickerValue = pickerData[heightIndex]
                picker.selectRow(heightIndex, inComponent: 0, animated: true)
            }
        }

        picker.accessibilityLabel = PickerLabel.heightPicker
        picker.reloadAllComponents()
        showPicker()
    }
    
    func showWeightPicker() {
        pickerData = healthKitUtil.getWeightPickerOptions()
        picker.selectRow(30, inComponent: 0, animated: true)
        selectedPickerValue = pickerData[30]

        if var weight = AppSyncManager.instance.healthProfile.value?.weight,
           let unit = AppSyncManager.instance.healthProfile.value?.unit {
            if unit == .imperial {
                weight = healthKitUtil.getPounds(fromKilo: weight)
            }
            if let weightIndex = pickerData.firstIndex(of: "\(weight) \(healthKitUtil.selectedUnit.weight)") {
                selectedPickerValue = pickerData[weightIndex]
                picker.selectRow(weightIndex, inComponent: 0, animated: true)
            }
        }
        picker.accessibilityLabel = PickerLabel.weightPicker
        picker.reloadAllComponents()
        showPicker()
    }
    
    func showAgePicker() {
        removePickers()
        picker.accessibilityLabel = PickerLabel.agePicker
        agePicker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        self.view.addSubview(agePicker)
        print(agePicker.frame.size.width)
        self.view.addSubview(toolBar)
    }
    
    func button(wasPressedOnCell cell: SetupProfileBioOptionCell) {
        switch cell.biometricLabel.text {
        case "Apple Health":
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
        return String(pickerData[pickerRow])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow pickerRow: Int, inComponent component: Int) {
        selectedPickerValue = pickerData[pickerRow]
        //        handlePickerSelected(selectedRow: pickerRow)
    }
}

extension SetupProfileBioDataVC: UICollectionViewDelegate,
                                UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell =
                collectionView.dequeueReusableCell(withReuseIdentifier: "SetupProfileBioTitleCell", for: indexPath)
            return cell
        } else if indexPath.item == 7 {
            let cell =
                collectionView.dequeueReusableCell(withReuseIdentifier: "SetupProfileBioInfoCell", for: indexPath)
            return cell
        } else if indexPath.item == 1 {
            let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier: "SetupProfileBioMetric", for: indexPath) as! SetupProfileUnitSelectionCell
            if healthKitUtil.selectedUnit == MeasurementUnits.metric {
                cell.unitSwitch.isOn = true
                cell.unitSwitch.setOn(true, animated: true)
            } else {
                cell.unitSwitch.isOn = false
                cell.unitSwitch.setOn(false, animated: true)
            }
            
            return cell
        } else {
            guard let cell = collectionView.getCell(with: SetupProfileBioOptionCell.self, at: indexPath) as? SetupProfileBioOptionCell
            else { preconditionFailure("Invalid cell type") }
            cell.setupCell(index: indexPath.item)
            cell.delegate = self
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height = (self.isFromSettings && indexPath.item == 0) ? 0.0 : 65.0
        return CGSize(width: width, height: CGFloat(height))
    }
    
    fileprivate func calculateAge(birthDate: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        guard let birthday = formatter.date(from: birthDate) else { return "" }
        let form = DateComponentsFormatter()
        form.maximumUnitCount = 2
        form.unitsStyle = .full
        form.allowedUnits = [.year]
        let currentAge = form.string(from: birthday, to: Date()) ?? ""
        return currentAge
    }
}

extension SetupProfileBioDataVC: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        self.closeView()
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return true
    }
}

extension SetupProfileBioDataVC: AppleHealthConnectionDelegate {
    func device(connected: Bool) {
        if connected {
            self.readHealthData()
        }
    }
}
