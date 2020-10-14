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
            
            let titleLabel = UILabel()
            titleLabel.text = "Update Pre-conditions"
            titleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 17.0)
            titleLabel.textColor = UIColor(hexString: "#4E4E4E")
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            self.navigationController?.navigationBar.tintColor = UIColor(hexString: "#FFFFFF")
            self.navigationItem.titleView = titleLabel
            self.footerView.isHidden = true

            NSLayoutConstraint.activate([
                self.footerView.heightAnchor.constraint(equalToConstant: 0)
            ])
        } else {
            self.addProgressbar(progress: 100.0)
        }
        
        NSLayoutConstraint.activate([
            self.footerView.heightAnchor.constraint(equalToConstant: self.isFromSettings ? 0.0 : 96.0)
        ])

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
        updateitemSelection(optionIndex:optionIndex)
//            preExistingMedicalConditionData[optionIndex].touched = true
//            let currentState = preExistingMedicalConditionData[optionIndex].selected
//            preExistingMedicalConditionData[optionIndex].selected = !currentState
//            collectionView.reloadData()
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
        let width = collectionView.bounds.width - 28.0

        switch indexPath.row {
        case titleRowIndex:
            return CGSize(width: width, height: self.isFromSettings ? 0.0 : CGFloat(150))
        case textAreaRowIndex:
            return CGSize(width: width, height: self.isFromSettings ? 0.0 : CGFloat(200))
        default:
            
            let optionData = preExistingMedicalConditionData[indexPath.row - 1]
            
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Medium", size: 18.0),.foregroundColor: UIColor(hexString: "#000000")]
            let attributedoptionData = NSMutableAttributedString(string: optionData.name, attributes: attributes)
            
            let gapAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Medium", size: 17.0)]
            
            let gapAttributedText = NSMutableAttributedString(string: "\n", attributes: gapAttributes)
            
            attributedoptionData.append(gapAttributedText)
            
            let optionDataDesc = optionData.description ?? ""
            
            let descAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Regular", size: 14.0),.foregroundColor: UIColor(hexString: "#666666")]
            let attributedDescText = NSMutableAttributedString(string: optionDataDesc, attributes: descAttributes)
            
            attributedoptionData.append(attributedDescText)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 1.8
            attributedoptionData.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedoptionData.length))
            
            attributedoptionData.addAttribute(NSAttributedString.Key.kern, value: CGFloat(0.4), range: NSRange(location: 0, length: attributedoptionData.length))
            
            let containerWidth = width - 57.0
            
            let height = attributedoptionData.height(containerWidth: containerWidth) + 32.0
            
            return CGSize(width: width, height: height)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case titleRowIndex:
            print("title clicked")
            self.view.endEditing(true)
        case textAreaRowIndex:
            changesSaved = false
            print("textArea clicked")
        default:
            self.view.endEditing(true)
            changesSaved = false
            updateitemSelection(optionIndex:( indexPath.item - 1))
        }
    }

    func updateitemSelection(optionIndex: Int) {
        let details = preExistingMedicalConditionData[optionIndex]
        preExistingMedicalConditionData[optionIndex].touched = true
        let currentState = preExistingMedicalConditionData[optionIndex].selected
        preExistingMedicalConditionData[optionIndex].selected = !currentState
        collectionView.reloadItems(at: [IndexPath(item: optionIndex+1, section: 0)])
        print("condition tapped", details)
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

extension NSAttributedString {

    func height(containerWidth: CGFloat) -> CGFloat {

        let rect = self.boundingRect(with: CGSize.init(width: containerWidth, height: CGFloat.greatestFiniteMagnitude),
                                     options: [.usesLineFragmentOrigin, .usesFontLeading],
                                     context: nil)
        return ceil(rect.size.height)
    }

    func width(containerHeight: CGFloat) -> CGFloat {

        let rect = self.boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: containerHeight),
                                     options: [.usesLineFragmentOrigin, .usesFontLeading],
                                     context: nil)
        return ceil(rect.size.width)
    }
}
