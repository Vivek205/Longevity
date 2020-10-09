//
//  SetupProfileDevicesConnectCell.swift
//  Longevity
//
//  Created by vivek on 26/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

protocol SetupProfileDevicesConnectCellDelegate {
    func connectBtn(wasPressedOnCell cell:SetupProfileDevicesConnectCell)
}

class SetupProfileDevicesConnectCell: UICollectionViewCell {
    // MARK: Outlets
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var connectBtn: UIButton!
    
    // MARK: Delegate
    var delegate: SetupProfileDevicesConnectCellDelegate?

    // MARK: Actions
    @IBAction func handleConnectDevice(_ sender: UIButton) {
        delegate?.connectBtn(wasPressedOnCell: self)
    }
    
    lazy var addedStateView: UIStackView = {
        let addedImage = UIImageView()
        addedImage.image = UIImage(#imageLiteral(resourceName: "icon: checked"))
        addedImage.contentMode = .scaleAspectFit
        addedImage.translatesAutoresizingMaskIntoConstraints = false
        
        let addTitle = UILabel()
        addTitle.text = "ADDED"
        addTitle.font = UIFont(name: "Montserrat-Medium", size: 14.0)
        addTitle.textAlignment = .center
        addTitle.textColor = .themeColor
        addTitle.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [addedImage, addTitle])
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    func setupCell(index: Int) {
        let option = setupProfileConnectDeviceOptionList[index]
        self.image.image = option?.image
        self.titleLabel.text = option?.title
        self.descriptionLabel.text = option?.description
        
        self.addedStateView.removeFromSuperview()
        
        if option?.isConnected == true {
            self.contentView.addSubview(addedStateView)
            
            NSLayoutConstraint.activate([
                addedStateView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
                addedStateView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8.0)
            ])
            self.connectBtn.isHidden = true
        } else {
            self.connectBtn.isHidden = false
            self.connectBtn.setImage(#imageLiteral(resourceName: "icon: add"), for: .normal)
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
