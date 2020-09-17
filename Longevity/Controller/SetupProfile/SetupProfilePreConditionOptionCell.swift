//
//  SetupProfilePreConditionOptionCell.swift
//  Longevity
//
//  Created by vivek on 14/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

protocol SetupProfilePreConditionOptionCellDelegate {
    func checkBoxButton(wasPressedOnCell cell:SetupProfilePreConditionOptionCell)
}

class SetupProfilePreConditionOptionCell: UICollectionViewCell {
    
    var optionData: PreExistingMedicalConditionModel! {
        didSet {
            self.conditionName.text = optionData.name
            self.conditionDescription.text = optionData.description
            self.optionId = optionData.id
            self.checkBoxButton.isSelected = optionData.selected
        }
    }
    
    
//    @IBOutlet weak var contentContainerView: SetupProfilePreConditionOptionCell!
    @IBOutlet weak var contentContainerView: UIView!
    
    @IBOutlet weak var checkBoxButton: CheckboxButton!
    
    @IBOutlet weak var conditionName: UILabel!
    @IBOutlet weak var conditionDescription: UILabel!


    var optionId: PreExistingMedicalConditionId?
    var delegate: SetupProfilePreConditionOptionCellDelegate?


    @IBAction func handleButtonPressed(_ sender: UIButton) {
        print("pressed", sender)
        delegate?.checkBoxButton(wasPressedOnCell: self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.cornerRadius = 4.0
        contentView.layer.masksToBounds = true
        
        if optionData?.selected ?? false {
            contentView.layer.borderWidth = 2.0
            contentView.layer.borderColor = UIColor.themeColor.cgColor
        } else {
            contentView.layer.borderWidth = 0
        }
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.cornerRadius = 4.0
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.25
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
    
}
