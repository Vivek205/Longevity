//
//  RKCFormLocationView.swift
//  Longevity
//
//  Created by vivek on 20/10/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class RKCFormLocationView: UICollectionViewCell {
    lazy var questionLabel: UILabel  = {
        let label = UILabel()
        label.textColor = .sectionHeaderColor
        label.font = UIFont(name: AppFontName.medium, size: 18)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var locationSelectorButton: CustomButtonOutlined = {
        let button = CustomButtonOutlined()
        button.setTitle("Enter", for: .normal)
        button.addTarget(self, action: #selector(getCurrentLocation), for: .touchUpInside)
        return button
    }()

    lazy var locationLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont(name: AppFontName.medium, size: 18), textColor: .themeColor, textAlignment: .right, numberOfLines: 1)
        return label
    }()

    func updateLocationLabel(location: String) {
        locationSelectorButton.removeFromSuperview()
        addSubview(locationLabel)

        locationLabel.text = location
        locationLabel.anchor(top: topAnchor, leading: questionLabel.trailingAnchor,
                             bottom: bottomAnchor, trailing: trailingAnchor)
        locationLabel.anchor(.height(32))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        LocationUtil.shared.currentLocation.addAndNotify(observer: self) {
            if let currentlocation = LocationUtil.shared.currentLocation.value {
                var locationString = ""
                if let city = currentlocation.city,
                   let state = currentlocation.state
                {
                    locationString = "\(city), \(state)"
                }
                if  let postalCode = currentlocation.zipcode {
                    locationString = "\(locationString) \(postalCode)"
                }
                if !locationString.isEmpty {
                    DispatchQueue.main.async {
                        self.updateLocationLabel(location: locationString)
                    }
                }
            }
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    func setupCell(identifier:String, question:String, lastResponseAnswer: String?) {
        questionLabel.text = question

        addSubview(questionLabel)
        addSubview(locationSelectorButton)

        questionLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: locationSelectorButton.leadingAnchor, padding: .init(top: 0, left: 60, bottom: 0, right: 0), size: .zero)
        locationSelectorButton.centerYTo(centerYAnchor)
        locationSelectorButton.anchor(top: nil, leading: nil, bottom: nil, trailing: trailingAnchor, padding: .zero, size: .init(width: 113, height: 32))
    }
}

extension RKCFormLocationView: CLLocationManagerDelegate {
    @objc func getCurrentLocation() {
        LocationUtil.shared.getCurrentLocation { (error) in
            if let error = error as? LocationError, error != .accesNotDetermined {
                if var topController = UIApplication.shared.keyWindow?.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    DispatchQueue.main.async {
                        topController.showAlert(title: "Allow Location Access",
                                                message: "Please enable location access in your device settings")
                    }
                }
            }
        }
    }


}
