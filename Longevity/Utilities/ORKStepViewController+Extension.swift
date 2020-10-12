//
//  ORKStepViewController+Extension.swift
//  Longevity
//
//  Created by vivek on 07/10/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

extension ORKStepViewController {

    open override func viewDidLoad() {
        super.viewDidLoad()

        self.hideBackButtonForFirstQuestion()
        self.customizeStyle()
    }

    func hideBackButtonForFirstQuestion() {
        let isFirstQuestion = SurveyTaskUtility.shared.isFirstStep(stepId: self.step?.identifier)
        self.navigationItem.hidesBackButton = isFirstQuestion
    }

    func customizeStyle() {
        self.view.backgroundColor = .appBackgroundColor
    }
}
