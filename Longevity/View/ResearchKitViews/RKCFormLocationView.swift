//
//  RKCFormLocationView.swift
//  Longevity
//
//  Created by vivek on 20/10/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class RKCFormLocationView: UICollectionViewCell {
    var itemIdentifier: String?
    lazy var questionLabel: UILabel  = {
        let label = UILabel()
        label.textColor = .sectionHeaderColor
        label.font = UIFont(name: AppFontName.medium, size: 18)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        label.textAlignment = .left
        return label
    }()

    lazy var locationSelectorButton: UIButton = {
        let button = UIButton()
        button.setTitle("Enter", for: .normal)
        button.addTarget(self, action: #selector(getCurrentLocation), for: .touchUpInside)
        button.layer.borderColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
        button.layer.cornerRadius = CGFloat(10)
        button.layer.borderWidth = 2
        button.setTitleColor(#colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1), for: .normal)
        return button
    }()

    lazy var locationLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont(name: AppFontName.medium, size: 18), textColor: .themeColor, textAlignment: .right, numberOfLines: 2)
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }()

    func updateLocationLabel(location: LocationDetails) {
        guard location.latitude != nil else { return }
        var locationString = ""
        if let city = location.city,
           let state = location.state
        {
            locationString = "\(city), \(state)"
        }
        if  let postalCode = location.zipcode {
            locationString = "\(locationString)\n\(postalCode)"
        }

        locationSelectorButton.removeFromSuperview()
        addSubview(locationLabel)

        locationLabel.text = locationString
        locationLabel.anchor(top: topAnchor, leading: questionLabel.trailingAnchor,
                             bottom: bottomAnchor, trailing: trailingAnchor)
        locationLabel.anchor(.height(32))
    }

    func saveAnswerLocally() {
        guard let identifier = self.itemIdentifier,
              let locationJsonString = LocationUtil.shared.locationJsonString else {return}
        SurveyTaskUtility.shared.setCurrentSurveyLocalAnswer(questionIdentifier: identifier, answer: locationJsonString)
    }


    override init(frame: CGRect) {
        super.init(frame: frame)

        LocationUtil.shared.currentLocation.addAndNotify(observer: self) {
            if let currentlocation = LocationUtil.shared.currentLocation.value {
                self.saveAnswerLocally()
                DispatchQueue.main.async {
                    self.updateLocationLabel(location: currentlocation)
                }
            }
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        LocationUtil.shared.currentLocation.remove(observer: self)
    }

    func setupCell(identifier:String, question:String, lastResponseAnswer: String?) {
        self.itemIdentifier = identifier
        questionLabel.text = question

        addSubview(questionLabel)
        addSubview(locationSelectorButton)

        questionLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: locationSelectorButton.leadingAnchor, padding: .init(top: 0, left: 60, bottom: 0, right: 0), size: .zero)
        locationSelectorButton.centerYTo(centerYAnchor)
        locationSelectorButton.anchor(top: nil, leading: nil, bottom: nil, trailing: trailingAnchor, padding: .zero, size: .init(width: 113, height: 32))


        if let lastResponseAnswer = lastResponseAnswer,
           let location = LocationUtil.shared.saveLocation(json: lastResponseAnswer) {
            self.updateLocationLabel(location: location)
        }

        if let location = LocationUtil.shared.currentLocation.value as? LocationDetails {
            self.updateLocationLabel(location: location)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(getCurrentLocation))
        tapGesture.numberOfTapsRequired = 1
        locationLabel.addGestureRecognizer(tapGesture)
        locationLabel.isUserInteractionEnabled = true
    }
}

extension RKCFormLocationView: CLLocationManagerDelegate {
    @objc func getCurrentLocation() {
        LocationUtil.shared.getCurrentLocation { (error) in
            if let error = error as? LocationError, error != .accesNotDetermined {
                    DispatchQueue.main.async {
                        Alert(title: "Allow Location Access",
                                                message: "Please enable location access in your device settings")
                    }
            }
        }
    }


}
