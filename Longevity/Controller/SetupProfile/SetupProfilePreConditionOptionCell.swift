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
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Medium", size: 18.0),.foregroundColor: UIColor(hexString: "#000000")]
            let attributedoptionData = NSMutableAttributedString(string: optionData.name, attributes: attributes)
            
            let gapAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Medium", size: 17.0)]
            
            let gapAttributedText = NSMutableAttributedString(string: "\n", attributes: gapAttributes)
            
            attributedoptionData.append(gapAttributedText)
            
            let optionDataDesc = optionData.description ?? ""
            
            let descAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Regular", size: 14.0),.foregroundColor: UIColor(hexString: "#666666")]
            let attributedDescText = NSMutableAttributedString(string: optionDataDesc, attributes: descAttributes)
            
            attributedoptionData.append(attributedDescText)
            attributedoptionData.addAttribute(NSAttributedString.Key.kern, value: CGFloat(0.4), range: NSRange(location: 0, length: attributedoptionData.length))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 1.8
            attributedoptionData.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedoptionData.length))
            self.conditionName.attributedText = attributedoptionData
            
            self.optionId = optionData.id
            self.checkBoxButton.isSelected = optionData.selected
        }
    }
    
    
//    @IBOutlet weak var contentContainerView: SetupProfilePreConditionOptionCell!
    @IBOutlet weak var contentContainerView: UIView!
    
    @IBOutlet weak var checkBoxButton: CheckboxButton!
    
    @IBOutlet weak var conditionName: UILabel!


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
