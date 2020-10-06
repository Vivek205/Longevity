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
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: CustomButtonOutlined!

    // MARK: Delegate
    var delegate: SetupProfileBioOptionCellDelegate?

    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.font = UIFont(name: "Montserrat-Medium", size: 18)
        self.label.textColor = .sectionHeaderColor
    }

    // MARK: Actions
    @IBAction func handleButtonPress(_ sender: Any) {
        delegate?.button(wasPressedOnCell: self)
    }
}
