//
//  SetupPreExistingConditionVC.swift
//  Longevity
//
//  Created by vivek on 13/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class SetupProfilePreConditionVC: BaseProfileSetupViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewProgressBar: UIView!
    @IBOutlet weak var viewNavigationItem: UINavigationItem!
    @IBOutlet weak var footerView: UIView!

    var modalPresentation = false
    var changesSaved = true

    // MARK: Collection View Data
    private var conditionCount:Int = 0
    var numberOfTotalItems:Int = 0
    var titleRowIndex:Int = 0
    var textAreaRowIndex:Int = 0
    var keyboardHeight: CGFloat?

    var isFromSettings: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeCollectionViewData()
        addKeyboardObservers()
        self.removeBackButtonNavigation()
        
        if self.isFromSettings {
//            self.viewProgressBar.isHidden = true
            let leftbutton = UIBarButtonItem(image: UIImage(named: "icon: arrow")?.withHorizontallyFlippedOrientation(), style: .plain, target: self, action: #selector(closeView))
            leftbutton.tintColor = .themeColor
            let rightButton = UIBarButtonItem(title:"Save", style: .plain, target: self, action: #selector(doneUpdate))
            rightButton.tintColor = .themeColor
            self.viewNavigationItem.leftBarButtonItem = leftbutton
            self.viewNavigationItem.rightBarButtonItem = rightButton
            self.footerView.isHidden = true

            NSLayoutConstraint.activate([
                self.footerView.heightAnchor.constraint(equalToConstant: 0)
            ])
        } else {
            self.addProgressbar(progress: 100.0)
        }

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

    deinit {
        removeKeyboardObservers()
    }

    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    func removeKeyboardObservers(){
        NotificationCenter.default.removeObserver(self,  name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }



    func initializeCollectionViewData() {
        conditionCount = preExistingMedicalConditionData.count
        numberOfTotalItems = conditionCount + 2
        titleRowIndex = 0
        textAreaRowIndex = conditionCount + 1
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    // MARK: Actions
    @IBAction func handleContinue(_ sender: Any) {
        updateMedicalConditions()
    }

}

extension SetupProfilePreConditionVC: SetupProfilePreConditionOptionCellDelegate {
    func checkBoxButton(wasPressedOnCell cell: SetupProfilePreConditionOptionCell) {
        changesSaved = false
        guard let optionIndex = preExistingMedicalConditionData.firstIndex(where:
            { (element) -> Bool in
            return element.id == cell.optionId
        }) else {
            return
        }
            preExistingMedicalConditionData[optionIndex].touched = true
            let currentState = preExistingMedicalConditionData[optionIndex].selected
            preExistingMedicalConditionData[optionIndex].selected = !currentState
            collectionView.reloadData()
    }
}

extension SetupProfilePreConditionVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        animateTextView(showKeyboard: true)
    }
    func textViewDidChange(_ textView: UITextView) {
        preExistingMedicalCondtionOtherText = textView.text
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        preExistingMedicalCondtionOtherText = textView.text
        animateTextView(showKeyboard: false)
    }

    func textView(_ textView: UITextView,
    shouldChangeTextIn range: NSRange,
    replacementText text: String) -> Bool {
        if text == "\n" {
            animateTextView(showKeyboard: false)
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    func animateTextView(showKeyboard: Bool) {
        print("animate text view", self.keyboardHeight)
//        let keyboardHeight = CGFloat(200)
        let movementDistance = self.keyboardHeight ?? CGFloat(200)
        let movementDuration = CGFloat(0.3)
        let movement = showKeyboard ? -movementDistance : 0
        view.frame.origin.y = movement
    }

    @objc func keyboardWillChange(notification: Notification) {
        print("keyboard notification \(notification.name.rawValue)")
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
               let keyboardRectangle = keyboardFrame.cgRectValue
                self.keyboardHeight = keyboardRectangle.height
                print("keyboard height", self.keyboardHeight)
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
        updateMedicalConditions()
        self.dismiss(animated: true, completion: nil)
    }
}

extension SetupProfilePreConditionVC: UICollectionViewDelegate,
UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfTotalItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == titleRowIndex {
            let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier: "SetupProfilePreHeadingCell", for: indexPath)
            return cell
        }
        if indexPath.row == textAreaRowIndex {
            let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier: "SetupProfilePreOtherCell", for: indexPath) as! SetupProfileOtherOptionCell
            cell.otherOptionTextView.delegate = self
            cell.otherOptionTextView.text = preExistingMedicalCondtionOtherText
            return cell
        }

        let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: "SetupProfilePreOptionCell", for: indexPath) as! SetupProfilePreConditionOptionCell
//        let optionData = preExistingMedicalConditionData[indexPath.row - 1]
        cell.optionData = preExistingMedicalConditionData[indexPath.row - 1]
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = view.frame.size.height
        let width = view.frame.size.width

        switch indexPath.row {
        case titleRowIndex:
            return CGSize(width: width - 40, height: CGFloat(150))
        case textAreaRowIndex:
            return CGSize(width: width - 40, height: CGFloat(200))
        default:
            return CGSize(width: width - 40, height: CGFloat(130))
        }
    }

}


extension SetupProfilePreConditionVC: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        self.closeView()
    }

    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return true
    }
}
