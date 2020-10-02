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
        let uiSegmentedControl = UISegmentedControl(items: ["",""])
        uiSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        uiSegmentedControl.backgroundColor = UIColor(red: 118/255, green: 118/255, blue: 128/255, alpha: 0.12)
        uiSegmentedControl.tintColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
        if #available(iOS 13.0, *) {
            uiSegmentedControl.selectedSegmentTintColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
        } else {
            if self.currentAnswer {
                uiSegmentedControl.tintColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
            } else {
                uiSegmentedControl.tintColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 0.8979291524)
            }
        }
        uiSegmentedControl.layer.cornerRadius = 6.93

        return uiSegmentedControl
    }()

    lazy var switchView:UISwitch = {
        let switchView = UISwitch()
        switchView.translatesAutoresizingMaskIntoConstraints = false
        return switchView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(segmentedControl)

        NSLayoutConstraint.activate([
            segmentedControl.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            segmentedControl.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])

        segmentedControl.addTarget(self, action: #selector(handleSegmentedControlChanged(_:)), for: .valueChanged)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")

    }

    func createLayout(yesText: String, noText: String) {
        self.segmentedControl.setTitle(noText, forSegmentAt: 0)
        self.segmentedControl.setTitle(yesText, forSegmentAt: 1)
    }

    @objc func handleSegmentedControlChanged(_ sender: UISwitch) {
        self.currentAnswer = !self.currentAnswer
        delegate?.segmentedControl(wasChangedOnCell: self)
    }

    func preSelectOption(index: Int) {
        self.segmentedControl.selectedSegmentIndex = index
    }
}
