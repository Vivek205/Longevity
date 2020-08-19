//
//  ContinuousScaleAnswerVC.swift
//  Longevity
//
//  Created by vivek on 19/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

class ContinuousScaleAnswerVC: ORKStepViewController {
    override var step: ORKStep? {
        didSet {
            if let step = self.step as? ORKQuestionStep {
                let questionSubheader = SurveyTaskUtility.surveyTagline ?? ""
                questionView.createLayout(header: step.title ?? "",
                                          subHeader: questionSubheader,
                                          question: step.question ?? "",
                                          extraInfo: step.text)
            }
        }
    }

    lazy var questionView:RKCQuestionView = {
        let uiView = RKCQuestionView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()

    lazy var footerView:UIView = {
          let uiView = UIView()
          uiView.translatesAutoresizingMaskIntoConstraints = false
          uiView.backgroundColor = .white
          return uiView
      }()

      lazy var continueButton: CustomButtonFill = {
          let buttonView = CustomButtonFill()
          buttonView.translatesAutoresizingMaskIntoConstraints = false
          buttonView.setTitle("Next", for: .normal)
          return buttonView
      }()

    lazy var slider:UISlider = {
        let uiSlider = UISlider()
//        uiSlider.vert
        uiSlider.minimumValue = 0
        uiSlider.maximumValue = 20
        uiSlider.isContinuous = true
        uiSlider.tintColor = .green
//        uiSlider.
        uiSlider.translatesAutoresizingMaskIntoConstraints = false
        return uiSlider
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

//        let questionView = UIView()
//        questionView.backgroundColor = .black
//        questionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(questionView)
        self.view.addSubview(slider)
        self.view.addSubview(footerView)
        footerView.addSubview(continueButton)

        NSLayoutConstraint.activate([
            questionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            questionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            questionView.heightAnchor.constraint(equalToConstant: 300),

            slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            slider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            slider.topAnchor.constraint(equalTo: questionView.bottomAnchor),


            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 130),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            continueButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 15),
            continueButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -15),
            continueButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 24),
            continueButton.heightAnchor.constraint(equalToConstant: 48)
        ])

        continueButton.isEnabled = false
        continueButton.addTarget(self, action: #selector(handleContinue(sender:)), for: .touchUpInside)

    }

    @objc func handleContinue(sender: UIButton) {
        self.goForward()
    }

}


class ContinuousScaleQuestionView: UIView {

    let headerLabel: UILabel = {
        let labelView = QuestionHeaderLabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.textAlignment = .center
        return labelView
    }()

    let subHeaderLabel: UILabel = {
        let labelView = QuestionSubheaderLabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.textAlignment = .center
        return labelView
    }()

    let questionLabel: UILabel = {
        let labelView = QuestionQuestionLabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.textAlignment = .center
        labelView.numberOfLines = 0
        return labelView
    }()

    let extraInfoLabel: UILabel = {
        let labelView = QuestionExtraInfoLabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.textAlignment = .center
        labelView.numberOfLines = 2
        return labelView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }


    func createLayout(header: String, subHeader: String, question:String, extraInfo: String?) {
        self.addBottomRoundedEdge(desiredCurve: 0.5)
        backgroundColor = .white

        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: self.topAnchor),
        ])

        headerLabel.text = header
        headerView.addSubview(headerLabel)

        NSLayoutConstraint.activate([
            headerLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor),
            headerLabel.rightAnchor.constraint(equalTo: headerView.rightAnchor),
            headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
        ])


        subHeaderLabel.text = subHeader
        headerView.addSubview(subHeaderLabel)

        NSLayoutConstraint.activate([
            subHeaderLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor),
            subHeaderLabel.rightAnchor.constraint(equalTo: headerView.rightAnchor),
            subHeaderLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor),
            subHeaderLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])

        questionLabel.text = question
        self.addSubview(questionLabel)

        NSLayoutConstraint.activate([
            questionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            questionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            questionLabel.topAnchor.constraint(equalTo:headerView.bottomAnchor)
        ])

        let bottomAnchorQuestionLabel = questionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30)

        if extraInfo != nil {
            extraInfoLabel.text = extraInfo
            self.addSubview(extraInfoLabel)
            NSLayoutConstraint.activate([
                extraInfoLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                extraInfoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                extraInfoLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor),
                extraInfoLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30)
            ])
        } else {
            bottomAnchorQuestionLabel.isActive = true
        }

    }
}
