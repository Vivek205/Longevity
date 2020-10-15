//
//  RKCTextChoiceAnswer.swift
//  Longevity
//
//  Created by vivek on 23/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation

class RKCTextChoiceAnswerView: UIView {
    var answer: String?
    var info: String?
    var checkbox: CheckboxButton = CheckboxButton()

    private let answerLabel: AnswerTitleLabel = {
        let label = AnswerTitleLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        return label
    }()

    private let infoLabel: AnswerDescriptionLabel = {
        let label = AnswerDescriptionLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func createLayout(answer: String, info: String?) {
        self.addSubview(checkbox)
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        checkbox.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        checkbox.widthAnchor.constraint(equalToConstant: 24).isActive = true
        checkbox.contentMode = .scaleAspectFill

        let stackView = createChoiceStackView()
        self.addSubview(stackView)

        stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 15).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: checkbox.leadingAnchor, constant: 0).isActive = true
    }

    func createChoiceStackView() -> UIStackView {

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 3.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        if answer != nil {
            answerLabel.text = answer
            stackView.addArrangedSubview(answerLabel)
        }
        if info != nil {
            infoLabel.text = info
            stackView.addArrangedSubview(infoLabel)
        }
        return stackView
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyShadow()
        self.backgroundColor = .white
        self.layer.cornerRadius = 4.0
    }

    func applyShadow() {
        let shadowPath = UIBezierPath(rect: self.bounds)
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.14).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        self.layer.shadowRadius = 10
        self.layer.shadowPath = shadowPath.cgPath
    }

    func setSelected(_ selected: Bool) {
        if selected {
            self.layer.borderColor =
                UIColor(red: 90/255, green: 167/255, blue: 167/255, alpha: 1).cgColor
            self.layer.borderWidth = 2
        }else {
            self.layer.borderColor = UIColor.white.cgColor
        }

    }
}
