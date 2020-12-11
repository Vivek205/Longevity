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
                questionView.createLayout(question: step.question ?? "")

                if let answerFormat = step.answerFormat as? ORKContinuousScaleAnswerFormat {
                    print(answerFormat)
                    slider.minimumValue = Float(answerFormat.minimum)
                    slider.maximumValue = Float(answerFormat.maximum)
                    slider.minimumValueImage = answerFormat.minimumValueDescription?.toImage()
                    slider.maximumValueImage = answerFormat.maximumValueDescription?.toImage()

                }

                if let localSavedAnswer =
                    SurveyTaskUtility.shared.getCurrentSurveyLocalAnswer(questionIdentifier: step.identifier)  {
                    slider.setValue((localSavedAnswer as NSString).floatValue, animated: true)
                    sliderLabel.text = localSavedAnswer
                    continueButton.isEnabled = true
                }
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
        buttonView.setTitle("Continue", for: .normal)
        buttonView.addTarget(self, action: #selector(handleContinue(_:)), for: .touchUpInside)
        buttonView.isEnabled = false
        return buttonView
    }()

    lazy var slider:UISlider = {
        let uiSlider = UISlider()
        uiSlider.isContinuous = true
        uiSlider.tintColor = .green
        uiSlider.translatesAutoresizingMaskIntoConstraints = false
        uiSlider.addTarget(self, action: #selector(handleSliderValueChanged(_:)), for: .valueChanged)
        return uiSlider
    }()

    lazy var sliderLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont(name: AppFontName.medium, size: 28), textColor: .themeColor, textAlignment: .center, numberOfLines: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationItem.hidesBackButton = isFirstQuestion
        createLayout()
    }

    func createLayout() {
        self.view.addSubview(questionView)
        self.view.addSubview(sliderLabel)
        self.view.addSubview(slider)
        self.view.addSubview(footerView)
        footerView.addSubview(continueButton)
        var questionViewHeight = CGFloat(0)

        if let step = self.step as? ORKQuestionStep,
           let surveyName = SurveyTaskUtility.shared.getCurrentSurveyName(),
           let question = step.question{

            questionViewHeight += "\n\n\n\(surveyName)".height(withConstrainedWidth: self.view.bounds.width, font: questionView.headerLabel.font)
            questionViewHeight += "\n\(question)".height(withConstrainedWidth: self.view.bounds.width, font: UIFont(name: AppFontName.regular, size: 24.0) ?? .init())
        }

        NSLayoutConstraint.activate([
            questionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            questionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            questionView.topAnchor.constraint(equalTo: view.topAnchor),
            questionView.heightAnchor.constraint(equalToConstant: questionViewHeight),

            sliderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sliderLabel.topAnchor.constraint(equalTo: questionView.bottomAnchor, constant: 6),
            sliderLabel.heightAnchor.constraint(equalToConstant: 50),

            slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            slider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            slider.topAnchor.constraint(equalTo: sliderLabel.bottomAnchor, constant: 12),

            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 130),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            continueButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 15),
            continueButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -15),
            continueButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 24),
            continueButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    @objc func handleContinue(_ sender: UIButton) {
        self.goForward()
    }

    @objc func handleSliderValueChanged(_ sender: UISlider) {
        guard let identifer = step?.identifier else { return }
        SurveyTaskUtility.shared.setCurrentSurveyLocalAnswer(questionIdentifier: identifer, answer: String(format: "%.1f", sender.value))
        sliderLabel.text = String(format: "%.1f", sender.value)
        continueButton.isEnabled = true
    }

}
