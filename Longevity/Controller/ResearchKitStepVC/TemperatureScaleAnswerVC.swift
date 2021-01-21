//
//  TemperatureScaleAnswerVC.swift
//  Longevity
//
//  Created by vivek on 02/09/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

fileprivate let minCelsius = Double(36)
fileprivate let maxCelsius = Double(39)

fileprivate func celsiusToFahrenheit(value: Double) -> Double {
    let celsius = Measurement(value: value, unit: UnitTemperature.celsius)
    let fahrenheit = celsius.converted(to: .fahrenheit)
    return fahrenheit.value
}

fileprivate func fahrenheitToCelsius(value: Double) -> Double {
    let fahrenheit = Measurement(value: value, unit: UnitTemperature.fahrenheit)
    let celsius = fahrenheit.converted(to: .fahrenheit)
    return celsius.value
}

class TemperatureScaleAnswerVC: ContinuousScaleAnswerVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppSyncManager.instance.healthProfile.addAndNotify(observer: self) {
            [weak self] in
            if let unit = AppSyncManager.instance.healthProfile.value?.unit {
                switch unit {
                case .metric:
                    self?.slider.minimumValue = Float(minCelsius)
                    self?.slider.maximumValue = Float(maxCelsius)
                    self?.slider.minimumValueImage = "\(String(format: "%.1f", minCelsius)) \u{00B0}C".toImage(color: .black, backgroundColor: .appBackgroundColor, font: UIFont(name: AppFontName.regular, size: 18))
                    self?.slider.maximumValueImage = "\(String(format: "%.1f", maxCelsius)) \u{00B0}C".toImage(color: .black, backgroundColor: .appBackgroundColor, font: UIFont(name: AppFontName.regular, size: 18))
                    if let localSavedAnswer =
                        SurveyTaskUtility.shared.getCurrentSurveyLocalAnswer(questionIdentifier: self?.step?.identifier ?? "")  {
                        let localanswer = (localSavedAnswer as NSString).floatValue //print((localSavedAnswer as NSString).floatValue)
                        self?.slider.setValue(localanswer, animated: true)
                        self?.sliderLabel.text = "\(String(format:"%.1f",localanswer)) \u{00B0}C"
                        self?.continueButton.isEnabled = true
                    } else {
                        self?.slider.setValue(Float(minCelsius), animated: true)
                        self?.sliderLabel.text = "\(String(format:"%.1f",minCelsius)) \u{00B0}C"
                    }
                case .imperial:
                    let minFahrenheit = celsiusToFahrenheit(value: minCelsius)
                    let maxFahrenheit = celsiusToFahrenheit(value: maxCelsius)
                    self?.slider.minimumValue = Float(minFahrenheit)
                    self?.slider.maximumValue = Float(maxFahrenheit)
                    self?.slider.minimumValueImage = "\(String(format: "%.1f", minFahrenheit)) \u{00B0}F".toImage(color: .black, backgroundColor: .appBackgroundColor, font: UIFont(name: AppFontName.regular, size: 18))
                    self?.slider.maximumValueImage = "\(String(format: "%.1f", maxFahrenheit)) \u{00B0}F".toImage(color: .black, backgroundColor: .appBackgroundColor, font: UIFont(name: AppFontName.regular, size: 18))
                    if let localSavedAnswer =
                        SurveyTaskUtility.shared.getCurrentSurveyLocalAnswer(questionIdentifier: self?.step?.identifier ?? "")  {
                        let localAnswerFahrenheit = celsiusToFahrenheit(value: (localSavedAnswer as NSString).doubleValue)
                        self?.slider.setValue(Float(localAnswerFahrenheit), animated: true)
                        self?.sliderLabel.text = "\(String(format:"%.1f",localAnswerFahrenheit)) \u{00B0}F"
                        self?.continueButton.isEnabled = true
                    }else {
                        self?.slider.setValue(Float(minFahrenheit), animated: true)
                        self?.sliderLabel.text = "\(String(format:"%.1f",minFahrenheit)) \u{00B0}F"
                    }
                }
            }
        }
        print("temperature scale answer")
    }

    override func handleSliderValueChanged(_ sender: UISlider) {
        super.handleSliderValueChanged(sender)
        if let unit = AppSyncManager.instance.healthProfile.value?.unit {
            switch unit {
            case .metric:
                self.sliderLabel.text = "\(String(format:"%.1f",sender.value)) \u{00B0}C"
            case .imperial:
                self.sliderLabel.text = "\(String(format:"%.1f",sender.value)) \u{00B0}F"
            }
        }

    }
}
