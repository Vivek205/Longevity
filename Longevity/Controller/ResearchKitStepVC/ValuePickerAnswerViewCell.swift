//
//  ValuePickerAnswerViewCell.swift
//  Longevity
//
//  Created by vivek on 12/11/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

protocol ValuePickerAnswerViewCellDelegate: class {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
}

class ValuePickerAnswerViewCell: UICollectionViewCell {
    var textChoices: [ORKTextChoice]? {
        didSet {
            print("updated value picker choices")
            pickerView.reloadAllComponents()
        }
    }

    weak var delegate: ValuePickerAnswerViewCellDelegate?

    var questionId: String? {
        didSet {
            guard let questionId = questionId, let textChoices = textChoices else {return}
            if let lastLocalResponse = SurveyTaskUtility.shared.getCurrentSurveyLocalAnswer(questionIdentifier: questionId) {
                let toBeSelectedRow = textChoices.firstIndex { (choice) -> Bool in
                    let value: String = (choice.value as? NSString ?? "") as String
                    print("value getCurrentSurveyLocalAnswer", value)
                    return value == lastLocalResponse
                }
                if toBeSelectedRow != nil {
                    pickerView.selectRow(toBeSelectedRow!, inComponent: 0, animated: true)
                    delegate?.pickerView(pickerView, didSelectRow: toBeSelectedRow!, inComponent: 0)
                }

            } else if let lastServerResponse = SurveyTaskUtility.shared.getCurrentSurveyServerAnswer(questionIdentifier: questionId) {
                let toBeSelectedRow = textChoices.firstIndex { (choice) -> Bool in
                    let value: String = (choice.value as? NSString ?? "") as String
                    print("value getCurrentSurveyLocalAnswer", value)
                    return value == lastServerResponse
                }
                if toBeSelectedRow != nil {
                    pickerView.selectRow(toBeSelectedRow!, inComponent: 0, animated: true)
                    delegate?.pickerView(pickerView, didSelectRow: toBeSelectedRow!, inComponent: 0)
                }
            }
        }
    }

    lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.dataSource = self
        picker.delegate = self



        return picker
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        createLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.themeColor.cgColor

        if #available(iOS 14.0, *)
        {
            let transparent = UIColor(red: 255.0 , green: 255.0, blue: 255.0, alpha: 0.0)
            let pickerSubView =  pickerView.subviews[1]
            pickerSubView.backgroundColor = transparent

            let topLine = UIView()
            let bottomLine = UIView()

            pickerSubView.addSubview(topLine)
            pickerSubView.addSubview(bottomLine)

            topLine.anchor(top: pickerSubView.topAnchor, leading: self.leadingAnchor, bottom: nil, trailing: self.trailingAnchor, size: .init(width: 0, height: 0.5))
            topLine.backgroundColor = UIColor.divider

            bottomLine.anchor(top: pickerSubView.bottomAnchor, leading: self.leadingAnchor, bottom: nil, trailing: self.trailingAnchor, size: .init(width: 0, height: 0.5))
            bottomLine.backgroundColor = UIColor.divider
        }

        self.layer.masksToBounds = true
    }

    func createLayout() {
        self.addSubview(pickerView)
        pickerView.fillSuperview()
    }
}

extension ValuePickerAnswerViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return textChoices?.count ?? 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return textChoices?[row].text
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = textChoices?[row].text ?? ""
        let attributes = [NSAttributedString.Key.font:UIFont(name: AppFontName.regular, size: 23.0)!,
                          NSAttributedString.Key.foregroundColor:UIColor.pickerLabel]
        let myTitle = NSAttributedString(string: titleData, attributes: attributes)
        return myTitle
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let questionId = self.questionId,
              let selectedChoice = textChoices?[row] else {return}
        let answer:String = (selectedChoice.value as? NSString ?? "") as String
        SurveyTaskUtility.shared.setCurrentSurveyLocalAnswer(questionIdentifier: questionId, answer: answer)
        delegate?.pickerView(pickerView, didSelectRow: row, inComponent: component)
    }
}


