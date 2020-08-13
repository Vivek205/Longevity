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
    var value:Int?

    lazy var cardView: CardView = {
        let cardView = CardView()
        cardView.backgroundColor = .white
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = 5.0
        return cardView
    }()

    lazy var titleLabel: AnswerTitleLabel = {
        let label = AnswerTitleLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    lazy var extraInfoLabel: AnswerDescriptionLabel = {
        let label = AnswerDescriptionLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
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
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10)
        ])

        let titleLabelBottomAnchor =  titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10)

        NSLayoutConstraint.activate([
            checkbox.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            checkbox.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            checkbox.widthAnchor.constraint(equalToConstant: 24)
        ])

        checkbox.addTarget(self, action: #selector(handleCheckboxTapped(_:)), for: .touchUpInside)


        if extraInfo != nil {
            self.addSubview(extraInfoLabel)
            extraInfoLabel.text = extraInfo
            NSLayoutConstraint.activate([
                extraInfoLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
                extraInfoLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
                extraInfoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
                extraInfoLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10)
            ])

        } else {
            titleLabelBottomAnchor.isActive = true
        }
    }

    func toggleIsChosenOption() {
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
        toggleIsChosenOption()
        delegate?.checkboxButton(wasPressedOnCell: self)
    }
}
