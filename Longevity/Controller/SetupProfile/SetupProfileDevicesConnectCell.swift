//
//  SetupProfileDevicesConnectCell.swift
//  Longevity
//
//  Created by vivek on 26/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

protocol SetupProfileDevicesConnectCellDelegate: class {
    func connectBtn(wasPressedOnCell cell:SetupProfileDevicesConnectCell)
}

class SetupProfileDevicesConnectCell: UICollectionViewCell {
    var deviceEnum: SetupProfileExternalDevice? {
        didSet {
            if let device = deviceEnum {
                self.setupCell(title: device.title, description: device.description, image: device.image)
            }
        }
    }
    
    lazy var deviceIcon:UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont(name: AppFontName.semibold, size: 20), textColor: UIColor.black.withAlphaComponent(0.87), textAlignment: .left, numberOfLines: 1)
        return label
    }()
    
    lazy var descriptionLabel:UILabel = {
        let label = UILabel(text: nil, font: UIFont(name: AppFontName.regular, size: 14), textColor: .checkinCompleted, textAlignment: .left, numberOfLines: 0)
        return label
    }()
    
    lazy var connectImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "icon: add")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
//    lazy var tapGesture:UITapGestureRecognizer = {
//        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleConnectDevice(_:)))
//        gesture.numberOfTouchesRequired = 1
//        return gesture
//    }()
    
    // MARK: Delegate
    weak var delegate: SetupProfileDevicesConnectCellDelegate?
    
    // MARK: Actions
    @objc func handleConnectDevice(_ sender: Any) {
        delegate?.connectBtn(wasPressedOnCell: self)
    }
    
    func setupCell(title:String, description:String, image: UIImage?) {
        self.backgroundColor = .white
        
        self.deviceIcon.image = image
        self.titleLabel.text = title
        self.descriptionLabel.text = description
        
        self.contentView.addSubview(deviceIcon)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(descriptionLabel)
        self.contentView.addSubview(connectImage)
        
        
        deviceIcon.centerYTo(centerYAnchor)
        deviceIcon.anchor(.leading(leadingAnchor, constant: 13),.width(46), .height(48))
        titleLabel.anchor(.leading(deviceIcon.trailingAnchor, constant: 15.0),
                          .top(self.topAnchor, constant: 6),
                          .trailing(connectImage.leadingAnchor))
        descriptionLabel.anchor(.leading(deviceIcon.trailingAnchor, constant: 15.0),
                                .top(titleLabel.bottomAnchor, constant: 4),
                                .trailing(connectImage.leadingAnchor),
                                .bottom(self.bottomAnchor, constant: 9))
        connectImage.centerYTo(centerYAnchor)
        connectImage.anchor(.trailing(trailingAnchor, constant: 12),
                            .width(69),.height(52))
        
        guard let device = deviceEnum else {return}
        var isConnected = false
        if let devices = AppSyncManager.instance.healthProfile.value?.devices {
            switch device {
            case .fitbit:
                if let fitbit = devices[ExternalDevices.fitbit], let connected = fitbit["connected"] {
                    isConnected = connected == 1
                }
            case .appleWatch:
                if let watch = devices[ExternalDevices.watch], let connected = watch["connected"] {
                    isConnected = connected == 1
                }
            }
        }
        
        connectImage.image = isConnected ? UIImage(named: "icon: added") : UIImage(named: "icon: add")
    }
    
    func setupConnectButton(_ isConnected:Bool) {
        if isConnected {
            connectImage.image = UIImage(named: "icon: added")
        } else {
            connectImage.image = UIImage(named: "icon: add")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.cornerRadius = 5.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.cornerRadius = 5.0
        layer.shadowRadius = 1.0
        layer.shadowOpacity = 0.25
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
}
