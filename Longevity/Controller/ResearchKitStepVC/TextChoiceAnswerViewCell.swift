//
//  TextChoiceAnswerViewCell.swift
//  Longevity
//
//  Created by vivek on 10/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

protocol TextChoiceAnswerViewChangedDelegate {
    func checkboxButton(wasPressedOnCell cell:TextChoiceAnswerViewCell)
}

class TextChoiceAnswerViewCell: UICollectionViewCell {
    var isChosenOption = false
    var delegate: TextChoiceAnswerViewChangedDelegate?

    lazy var cardView: CardView = {
        let cardView = CardView()
        cardView.backgroundColor = .white
        cardView.translatesAutoresizingMaskIntoConstraints = false
        return cardView
    }()

    let titleLabel: AnswerTitleLabel = {
        let label = AnswerTitleLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
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

    func createLayout(text:String, extraInfo:String?) {
        self.addSubview(cardView)
        self.addSubview(titleLabel)
        self.addSubview(checkbox)

        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            cardView.topAnchor.constraint(equalTo: self.topAnchor),
            cardView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

        titleLabel.text = text
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: checkbox.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            checkbox.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            checkbox.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
        ])

        checkbox.addTarget(self, action: #selector(handleCheckboxTapped(_:)), for: .touchUpInside)

////            let estimatedWidth = self.bounds.width - 40.0
////            let attributes = [NSAttributedString.Key.font: titleLabel.font.pointSize]
////            let estimatedSize = CGSize(width: estimatedWidth, height: 1000.0)
////            let estimatedFrame = NSString(string: self.text!).boundingRect(with: estimatedSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
//
////            let estimatedHeight = text.height(withConstrainedWidth: self.bounds.width, font: titleLabel.font)

    }

    func toggleChosenOption() {
        isChosenOption = !isChosenOption

        checkbox.isSelected = isChosenOption
        if isChosenOption {
            // FIXME: BorderColor not working
            self.layer.borderColor =
                UIColor(red: 90/255, green: 167/255, blue: 167/255, alpha: 1).cgColor
            self.layer.borderWidth = 2
        } else {
            self.layer.borderColor = UIColor.white.cgColor
        }

    }

    @objc func handleCheckboxTapped(_ sender: Any) {
        toggleChosenOption()
        delegate?.checkboxButton(wasPressedOnCell: self)
    }
}
