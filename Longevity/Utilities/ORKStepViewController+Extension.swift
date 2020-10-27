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

        self.customizeStyle()
        self.customizeNavbarButtons()

        if !(step is ORKInstructionStep) {
            self.customizeBackButton()
            self.addProgressBar()
        }
    }

    func customizeBackButton() {
        let isFirstQuestion = SurveyTaskUtility.shared.isFirstStep(stepId: self.step?.identifier)
        self.navigationItem.hidesBackButton = isFirstQuestion
        if !isFirstQuestion {
            self.backButtonItem = UIBarButtonItem(image: UIImage(named: "icon: arrow-left"), style: .plain,
                                                  target: self, action: #selector(goBackward))
        }
    }

    func customizeStyle() {
        self.view.backgroundColor = .appBackgroundColor
    }

    func addProgressBar() {
        let progressView: UIProgressView = UIProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false

        let progressViewHeight = progressView.frame.size.height
        progressView.layer.cornerRadius = progressViewHeight / 2
        progressView.clipsToBounds = true
        progressView.subviews.forEach { (subview) in
            subview.layer.masksToBounds = true
            subview.layer.cornerRadius = progressViewHeight / 2.0
            subview.clipsToBounds = true
        }
        self.navigationItem.titleView = UIView()
        self.navigationItem.titleView?.addSubview(progressView)

        NSLayoutConstraint.activate([
            progressView.widthAnchor.constraint(equalToConstant: 200.0),
            progressView.heightAnchor.constraint(equalToConstant: 4.0),
            progressView.centerYAnchor.constraint(equalTo: (self.navigationItem.titleView?.centerYAnchor)!),
            progressView.centerXAnchor.constraint(equalTo: (self.navigationItem.titleView?.centerXAnchor)!)
        ])
        let progress = Float(0) / Float(100)
        progressView.setProgress(progress, animated: false)

        self.calculateAndUpdateProgress()
    }

    func calculateAndUpdateProgress() {
        func updateProgress(progress: Float) {
            self.navigationItem.titleView?.subviews.forEach({ (subview) in
                if let subview = subview as? UIProgressView {
                    subview.setProgress(progress, animated: false)
                }
            })
        }
        if let task = self.taskViewController?.task as? ORKOrderedTask,
           let step = self.step {
            let currentStepIndex = task.steps.firstIndex { (taskStep) -> Bool in
                return taskStep.identifier == step.identifier
            } ?? 0
            let progress = Float(currentStepIndex) / Float(task.steps.count - 1) // excluding intro step from taskStepsCount
            updateProgress(progress: progress)
        }else {
            updateProgress(progress: 0)
        }
    }

    func customizeNavbarButtons() {
//        navigationController?.navigationBar.backgroundColor = .yellow
//        navigationController?.navigationBar.barTintColor = .blue
//        self.navigationBar
//        navigationController?.navigationBar.tintColor = .orange
        UINavigationBar.appearance().barTintColor = .systemPink
//        self.navigationItem.backgr
        self.cancelButtonItem?.title = "Exit"
    }
}
