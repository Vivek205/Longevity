//
//  TextChoiceAnswerViewCell.swift
//  Longevity
//
//  Created by vivek on 10/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

protocol TextChoiceAnswerViewChangedDelegate: class {
    func checkboxButton(wasPressedOnCell cell:TextChoiceAnswerViewCell)
}

class TextChoiceAnswerViewCell: UICollectionViewCell {
    var isChosenOption = false
    weak var delegate: TextChoiceAnswerViewChangedDelegate?
    var value:Int?
    var answerFormatStyle:ORKChoiceAnswerStyle? {
        didSet {
            if answerFormatStyle == .singleChoice {
                self.checkbox.setImage(nil, for: .normal)
            }
        }
    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()//AnswerTitleLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    let checkbox: CheckboxButton = {
        let checkbox = CheckboxButton()
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        return checkbox
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func createLayout(text: String, extraInfo:String?) {
        self.backgroundColor = .white
        self.addSubview(titleLabel)
        self.addSubview(checkbox)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: checkbox.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])

        NSLayoutConstraint.activate([
            checkbox.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            checkbox.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkbox.widthAnchor.constraint(equalToConstant: 24)
        ])

        checkbox.addTarget(self, action: #selector(handleCheckboxTapped(_:)), for: .touchUpInside)

        
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Medium", size: 18), .foregroundColor: UIColor.black]
        let attributedoptionData = NSMutableAttributedString(string: text, attributes: attributes)

        if let extraInfo = extraInfo, !extraInfo.isEmpty  {
            let extraInfoAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.regular, size: 14.0), .foregroundColor: UIColor(hexString: "#666666")]
            let extraInfoAttributedText = NSMutableAttributedString(string: "\n\(extraInfo)", attributes: extraInfoAttributes)
            attributedoptionData.append(extraInfoAttributedText)
        }
        
        attributedoptionData.addAttribute(NSAttributedString.Key.kern, value: CGFloat(0.4), range: NSRange(location: 0, length: attributedoptionData.length))
        
        titleLabel.attributedText = attributedoptionData
    }

    func toggleIsChosenOption() {
        isChosenOption = !isChosenOption

        checkbox.isSelected = isChosenOption
        if isChosenOption {
            self.layer.borderColor = UIColor.themeColor.cgColor
            self.layer.borderWidth = 2
        } else {
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor.clear.cgColor
        }
    }

    @objc func handleCheckboxTapped(_ sender: Any) {
        toggleIsChosenOption()
        delegate?.checkboxButton(wasPressedOnCell: self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.cornerRadius = 5.0
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.cornerRadius = 5.0
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 0.25
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
}
