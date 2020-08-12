//
//  RKCFormBooleanAnswerView.swift
//  Longevity
//
//  Created by vivek on 11/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

protocol RKCFormBooleanAnswerViewDelegate {
    func segmentedControl(wasChangedOnCell cell:RKCFormBooleanAnswerView)
}

class RKCFormBooleanAnswerView: UIView {
    var delegate:RKCFormBooleanAnswerViewDelegate?
    var currentAnswer:Bool = false

    lazy var segmentedControl: UISegmentedControl = {
        let uiSegmentedControl = UISegmentedControl(items: ["No","Yes"])
        uiSegmentedControl.selectedSegmentIndex = 0
        uiSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return uiSegmentedControl
    }()

    lazy var switchView:UISwitch = {
        let switchView = UISwitch()
        switchView.translatesAutoresizingMaskIntoConstraints = false
        return switchView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createLayout(yesText: String, noText: String) {
        self.addSubview(segmentedControl)

        NSLayoutConstraint.activate([
            segmentedControl.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            segmentedControl.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])

        segmentedControl.addTarget(self, action: #selector(handleSegmentedControlChanged(_:)), for: .valueChanged)
    }

    @objc func handleSegmentedControlChanged(_ sender: UISwitch) {
        self.currentAnswer = !self.currentAnswer
        delegate?.segmentedControl(wasChangedOnCell: self)
    }
}
