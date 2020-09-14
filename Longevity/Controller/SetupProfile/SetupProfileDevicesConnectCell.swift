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
}
