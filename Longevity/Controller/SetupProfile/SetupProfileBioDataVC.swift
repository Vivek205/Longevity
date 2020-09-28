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
//        continueButton.isEnabled = false
        createPickersAndToolbar()
        
        checkIfHealthKitSyncedAlready()
        
        if self.isFromSettings {
            self.viewProgressBar.isHidden = true
            let leftbutton = UIBarButtonItem(title:"Cancel", style: .plain, target: self, action: #selector(closeView))
            leftbutton.tintColor = .themeColor
            let rightButton = UIBarButtonItem(title:"Save", style: .plain, target: self, action: #selector(doneUpdate))
            rightButton.tintColor = .themeColor
            self.viewNavigationItem.leftBarButtonItem = leftbutton
            self.viewNavigationItem.rightBarButtonItem = rightButton
            self.footerView.isHidden = true
        } else {
            self.addProgressbar(progress: 40.0)
        }
        
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        layout.invalidateLayout()

        if self.modalPresentation {
            if #available(iOS 13.0, *) {
                self.isModalInPresentation = true
                print("delegate", self.navigationController?.presentationController?.delegate)
                self.navigationController?.presentationController?.delegate = self
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func checkIfHealthKitSyncedAlready() {
        if healthKitUtil.isHealthkitSynced {
            self.readHealthData()
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
        picker.setValue(UIColor.sectionHeaderColor, forKey: "textColor")
        
        // DatePicker
        agePicker.autoresizingMask = .flexibleWidth
        agePicker.contentMode = .center
        agePicker.backgroundColor = UIColor.white
        agePicker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        agePicker.datePickerMode = .date
        agePicker.isHidden = false
        agePicker.addTarget(self, action: #selector(onAgeChanged(sender:)), for: .valueChanged)
        agePicker.maximumDate = Date()
        agePicker.setValue(UIColor.sectionHeaderColor, forKey: "textColor")
        
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
        guard healthKitUtil.isHealthkitSynced else {return}
        
        switch healthKitUtil.selectedUnit {
        case .metric:
            if let height = AppSyncManager.instance.healthProfile.value?.height {
                setupProfileOptionList[5]?.buttonText = "\(height) \(healthKitUtil.selectedUnit.height)"
            }
            if let weight = AppSyncManager.instance.healthProfile.value?.weight {
                setupProfileOptionList[6]?.buttonText = "\(weight) \(healthKitUtil.selectedUnit.weight)"
            }
            break
        case .imperial:
            if let height = healthKitUtil.getHeightStringInImperial() {
                setupProfileOptionList[5]?.buttonText = "\(height) \(healthKitUtil.selectedUnit.height)"
            }
            if let weight = healthKitUtil.getWeightStringInImperial() {
                setupProfileOptionList[6]?.buttonText = "\(weight) \(healthKitUtil.selectedUnit.weight)"
            }
            
            break
        }
        
        self.collectionView.reloadData()
        return
    }
    
    func authorizeHealthKitInApp() {
        healthKitUtil.authorize
            { (success, error) in
                print("is healthkit authorized?", success)
                if !success {
                    print("Healthdata not authorized")
                    return
                }
                DispatchQueue.main.async {
                    self.readHealthData()
                }
        }
    }
    
    func readHealthData() {
        if let characteristicData = healthKitUtil.readCharacteristicData() {
            if let currentAge = characteristicData.currentAge {
                setupProfileOptionList[4]?.isSynced = true
                setupProfileOptionList[4]?.buttonText = "\(currentAge) years"
            }
            if let biologicalSex = characteristicData.biologicalSex {
                setupProfileOptionList[3]?.isSynced = true
                setupProfileOptionList[3]?.buttonText = biologicalSex.string
            }
        }
        
        healthKitUtil.readHeightData {
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
        
        healthKitUtil.readWeightData {
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
    
    @objc func closeView() {
        if changesSaved {
            self.dismiss(animated: true, completion: nil)
            return
        }
        let alertVC = UIAlertController(title: "Discard changes", message: "Are you sure to discard all your unsaved changes?", preferredStyle: .actionSheet)
        let dismiss = UIAlertAction(title: "dismiss", style: .destructive) {[weak self] (action) in
            self?.dismiss(animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "cancel", style: .default) {[weak self] (action) in
//            self?.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(dismiss)
        alertVC.addAction(cancel)
        self.present(alertVC, animated: true, completion: nil)
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
                splitValue = healthKitUtil.getCentimeter(fromFeet: splitValue)
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
        picker.selectRow(0, inComponent: 0, animated: true)
        pickerData = ["male", "female","other"]
        selectedPickerValue = pickerData[0]
        picker.accessibilityLabel = PickerLabel.genderPicker
        picker.reloadAllComponents()
        showPicker()
    }
    
    func showHeightPicker() {
        pickerData = healthKitUtil.getHeightPickerOptions()
        picker.selectRow(30, inComponent: 0, animated: true)
        selectedPickerValue = pickerData[30]
        picker.accessibilityLabel = PickerLabel.heightPicker
        picker.reloadAllComponents()
        showPicker()
    }
    
    func showWeightPicker() {
        pickerData = healthKitUtil.getWeightPickerOptions()
        picker.selectRow(30, inComponent: 0, animated: true)
        selectedPickerValue = pickerData[30]
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
        } else if indexPath.row == 1 {
            let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier: "SetupProfileBioInfoCell", for: indexPath)
            return cell
        } else if indexPath.row == 7 {
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
                cell.button.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 18)
            }else {
                cell.button.layer.borderColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
                cell.button.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 14)
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
            
            let verticalLine = UIView()
            verticalLine.backgroundColor = UIColor(hexString: "#D6D6D6")
            verticalLine.translatesAutoresizingMaskIntoConstraints = false
            
            cell.addSubview(verticalLine)
            
            NSLayoutConstraint.activate([
                verticalLine.widthAnchor.constraint(equalToConstant: 1.5),
                verticalLine.centerXAnchor.constraint(equalTo: cell.logo.centerXAnchor)
            ])
            
            if indexPath.item == 2 {
                NSLayoutConstraint.activate([
                    verticalLine.topAnchor.constraint(equalTo: cell.logo.centerYAnchor),
                    verticalLine.bottomAnchor.constraint(equalTo: cell.bottomAnchor)
                ])
            } else if indexPath.item == 6 {
                NSLayoutConstraint.activate([
                    verticalLine.topAnchor.constraint(equalTo: cell.topAnchor),
                    verticalLine.bottomAnchor.constraint(equalTo: cell.logo.centerYAnchor)
                ])
            } else {
                NSLayoutConstraint.activate([
                    verticalLine.topAnchor.constraint(equalTo: cell.topAnchor),
                    verticalLine.bottomAnchor.constraint(equalTo: cell.bottomAnchor)
                ])
            }
            cell.sendSubviewToBack(verticalLine)
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = view.frame.size.height
        let width = view.frame.size.width
        return CGSize(width: width, height: CGFloat(60))
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
