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
    var activeTextView:UITextView?
    var rollbackYOrigin: CGFloat?

    var modalPresentation = false
    var changesSaved = true

    // MARK: Collection View Data
    var numberOfTotalItems:Int = 0
    var titleRowIndex:Int = 0
    var textAreaRowIndex:Int = 0
    var keyboardHeight: CGFloat?

    var isFromSettings: Bool = false
    
    var currentEditedText: String = ""
    var currentPreExistingMedicalConditions:[PreExistingMedicalConditionModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentEditedText = preExistingMedicalCondtionOtherText ?? ""
        self.currentPreExistingMedicalConditions = preExistingMedicalConditionData
        
        initializeCollectionViewData()
        addKeyboardObservers()
        self.removeBackButtonNavigation()
        
        if self.isFromSettings {
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
        } else {
            self.addProgressbar(progress: 100.0)
        }
        
        let footerheight: CGFloat = self.isFromSettings ? 0.0 : UIDevice.hasNotch ? 130.0 : 96.0
        
        NSLayoutConstraint.activate([
            self.footerView.heightAnchor.constraint(equalToConstant: footerheight)
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

        self.rollbackYOrigin = self.view.frame.origin.y
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.rollbackYOrigin = self.view.frame.origin.y
        self.addKeyboardObservers()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeKeyboardObservers()
    }


    func initializeCollectionViewData() {
        let conditionsCount = currentPreExistingMedicalConditions?.count ?? 0
        numberOfTotalItems = conditionsCount + 2
        titleRowIndex = 0
        textAreaRowIndex = conditionsCount + 1
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    // MARK: Actions
    @IBAction func handleContinue(_ sender: Any) {
        self.doSaveData()
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
    }
}

extension SetupProfilePreConditionVC: SetupProfileOtherOptionCellDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        activeTextView = textView
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
        changesSaved = false
    }
    
    func updateCurrentText(text: String?) {
        self.currentEditedText = text ?? ""
    }
    
    @objc func closeView() {
        self.view.endEditing(true)
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
        self.doSaveData()
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func doSaveData() {
        preExistingMedicalCondtionOtherText = self.currentEditedText
        if let updatedConditions = self.currentPreExistingMedicalConditions {
            preExistingMedicalConditionData = updatedConditions
        }
        MedicalHistoryAPI.instance.updateMedicalConditions()
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
            cell.configureTextView(text: preExistingMedicalCondtionOtherText)
            cell.delegate = self
            self.activeTextView = cell.otherOptionTextView
            return cell
        }

        let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: "SetupProfilePreOptionCell", for: indexPath) as! SetupProfilePreConditionOptionCell
        cell.optionData = self.currentPreExistingMedicalConditions?[indexPath.row - 1]
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 28.0

        switch indexPath.row {
        case titleRowIndex:
            return CGSize(width: width, height: self.isFromSettings ? 0.0 : CGFloat(120))
        case textAreaRowIndex:
            return CGSize(width: width, height: CGFloat(200))
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
        guard let details = self.currentPreExistingMedicalConditions?[optionIndex] else { return }
        self.currentPreExistingMedicalConditions?[optionIndex].touched = true
        let currentState = self.currentPreExistingMedicalConditions?[optionIndex].selected ?? false
        self.currentPreExistingMedicalConditions?[optionIndex].selected = !currentState
        collectionView.reloadItems(at: [IndexPath(item: optionIndex + 1, section: 0)])
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

// MARK: - KEYBOARD observers
extension SetupProfilePreConditionVC {
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self,  name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWasShown(notification: NSNotification){
        guard let info = notification.userInfo else {return}
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)
        guard let keyboardHeight = keyboardSize?.height ,
            let navbarHeight = self.navigationController?.navigationBar.frame.size.height,
            let inputAccessoryHeight = activeTextView?.inputAccessoryView?.frame.height
        else {return}
        let topPadding:CGFloat = 20.0
        let viewYPadding = navbarHeight + topPadding
        var visibleScreen : CGRect = self.view.frame
        visibleScreen.size.height -= (keyboardHeight + viewYPadding)

        self.view.frame.origin.y = -(keyboardHeight - inputAccessoryHeight - viewYPadding)
    }

    @objc func keyboardWillBeHidden(notification: NSNotification){
        guard let rollbackYOrigin = self.rollbackYOrigin else {return}
        self.view.frame.origin.y = rollbackYOrigin
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

extension UITextView {
    func addInputAccessoryView(title: String, target: Any, selector: Selector) {
        let toolBar = UIToolbar(frame: CGRect(x: 0.0,
                                              y: 0.0,
                                              width: UIScreen.main.bounds.size.width,
                                              height: 44.0))
        toolBar.barStyle = .blackTranslucent
        toolBar.tintColor = .white
        let barButton = UIBarButtonItem(title: title, style: .done, target: target, action: selector)
        toolBar.setItems([barButton], animated: false)
        self.inputAccessoryView = toolBar
    }
}
