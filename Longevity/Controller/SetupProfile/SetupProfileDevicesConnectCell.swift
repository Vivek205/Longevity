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
