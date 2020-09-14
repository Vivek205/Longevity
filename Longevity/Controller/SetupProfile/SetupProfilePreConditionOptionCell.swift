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

}
