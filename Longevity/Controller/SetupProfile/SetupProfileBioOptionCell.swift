//
//  SetupProfileBioOptionCell.swift
//  Longevity
//
//  Created by vivek on 25/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

protocol SetupProfileBioOptionCellDelegate {
    func button(wasPressedOnCell cell: SetupProfileBioOptionCell)
}

class SetupProfileBioOptionCell: UICollectionViewCell {
    // MARK: Outlets
//    @IBOutlet weak var logo: UIImageView!
//    @IBOutlet weak var label: UILabel!
//    @IBOutlet weak var button: CustomButtonOutlined!
    
    lazy var biometricImage: UIImageView = {
        let biometricImage = UIImageView()
        biometricImage.contentMode = .scaleAspectFit
        biometricImage.translatesAutoresizingMaskIntoConstraints = false
        return biometricImage
    }()
    
    lazy var biometricLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Montserrat-Medium", size: 18)
        label.textColor = .sectionHeaderColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var biometricSyncButton: UIButton = {
        let syncButton = UIButton()
        syncButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        syncButton.translatesAutoresizingMaskIntoConstraints = false
        return syncButton
    }()

    lazy var verticalLine: UIView = {
        let verticalLine = UIView()
        verticalLine.backgroundColor = UIColor(hexString: "#D6D6D6")
        verticalLine.translatesAutoresizingMaskIntoConstraints = false
        return verticalLine
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = .clear
        
        self.contentView.addSubview(biometricImage)
        self.contentView.addSubview(biometricLabel)
        self.contentView.addSubview(biometricSyncButton)
        
        
        NSLayoutConstraint.activate([
            self.biometricImage.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20.0),
            self.biometricImage.heightAnchor.constraint(equalToConstant: 48.0),
            self.biometricImage.widthAnchor.constraint(equalTo: self.biometricImage.heightAnchor),
            self.biometricImage.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            
            self.biometricLabel.leadingAnchor.constraint(equalTo: self.biometricImage.trailingAnchor, constant: 14.0),
            self.biometricLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.biometricSyncButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.biometricSyncButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20.0),
            self.biometricSyncButton.widthAnchor.constraint(equalToConstant: 100.0),
            self.biometricSyncButton.leadingAnchor.constraint(greaterThanOrEqualTo: self.biometricLabel.trailingAnchor, constant: 10.0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: Delegate
    var delegate: SetupProfileBioOptionCellDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.biometricSyncButton.layer.cornerRadius = 10.0
        self.biometricSyncButton.layer.masksToBounds = true
    }

    // MARK: Actions
    @IBAction func handleButtonPress(_ sender: Any) {
        delegate?.button(wasPressedOnCell: self)
    }
    
    @objc func buttonPressed(_ sender: Any) {
        delegate?.button(wasPressedOnCell: self)
    }
    
    func setupCell(index: Int) {
        let option = setupProfileOptionList[index]
        
        self.biometricImage.image = option?.image
        self.biometricLabel.text = option?.label
        self.biometricSyncButton.setTitle(option?.buttonText, for: .normal)
        self.biometricSyncButton.setImage(nil, for: .normal)
        let isSynced = option?.isSynced
        if(isSynced == true) {
            self.biometricSyncButton.layer.borderColor = UIColor.clear.cgColor
            self.biometricSyncButton.setTitleColor(.themeColor, for: .normal)
            self.biometricSyncButton.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 18)

        } else {
            self.biometricSyncButton.layer.borderColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
            self.biometricSyncButton.layer.borderWidth = 2.0
            self.biometricSyncButton.setTitleColor(.themeColor, for: .normal)
            self.biometricSyncButton.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 14)
        }
        
        print(index)

        if index == 7 {
            self.biometricSyncButton.titleLabel?.lineBreakMode = .byWordWrapping
            self.biometricSyncButton.titleLabel?.numberOfLines = 2
            self.biometricSyncButton.titleLabel?.textAlignment = .center
            self.biometricSyncButton.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 14)
        }
        
        // Connect Apple Health Button
        if index == 2 && self.biometricLabel.text == "Apple Health" {
            if let profile = AppSyncManager.instance.healthProfile.value,
               let device = profile.devices?[ExternalDevices.healthkit], device["connected"] == 1 {
                self.biometricSyncButton.setTitle("DISCONNECT", for: .normal)
                self.biometricSyncButton.setTitleColor(UIColor(hexString: "#B00020"), for: .normal)
                self.biometricSyncButton.layer.borderColor = UIColor.clear.cgColor
            } else {
                self.biometricSyncButton.setTitle("CONNECT", for: .normal)
                self.biometricSyncButton.setTitleColor(.themeColor, for: .normal)
                self.biometricSyncButton.layer.borderColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
            }
        }
        
        self.verticalLine.removeFromSuperview()
        self.contentView.addSubview(verticalLine)
        self.contentView.sendSubviewToBack(verticalLine)
        
        NSLayoutConstraint.activate([
            verticalLine.widthAnchor.constraint(equalToConstant: 1.5),
            verticalLine.centerXAnchor.constraint(equalTo: self.biometricImage.centerXAnchor)
        ])
        
        if index == 2 {
            NSLayoutConstraint.activate([
                verticalLine.topAnchor.constraint(equalTo: self.topAnchor, constant: 30.0),
                verticalLine.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        } else if index == 7 {
            NSLayoutConstraint.activate([
                verticalLine.topAnchor.constraint(equalTo: self.topAnchor),
                verticalLine.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30.0)
            ])
        } else {
            NSLayoutConstraint.activate([
                verticalLine.topAnchor.constraint(equalTo: self.topAnchor),
                verticalLine.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        }
    }
}
