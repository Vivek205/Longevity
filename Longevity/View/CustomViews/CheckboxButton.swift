//
//  CheckboxButton.swift
//  Longevity
//
//  Created by vivek on 13/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CheckboxButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)

         layer.masksToBounds = true
        setImage(#imageLiteral(resourceName: "icon: Checkbox-unselected"), for: .normal)
        setImage(#imageLiteral(resourceName: "icon: checkbox-selected"), for: .selected)
        layer.cornerRadius = frame.width / 2
        setTitleColor(UIColor.white, for: .selected)
//         isSelected = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
         layer.masksToBounds = true
        setImage(#imageLiteral(resourceName: "icon: Checkbox-unselected"), for: .normal)
        setImage(#imageLiteral(resourceName: "icon: checkbox-selected"), for: .selected)
        layer.cornerRadius = frame.width / 2
        setTitleColor(UIColor.white, for: .selected)
//         isSelected = true
    }

//    func styleButton() {
//        layer.masksToBounds = true
//        setImage(#imageLiteral(resourceName: "icon: Checkbox-unselected"), for: .normal)
//        setImage(#imageLiteral(resourceName: "icon: checkbox-selected"), for: .selected)
//        layer.cornerRadius = frame.width / 2
//        setTitleColor(UIColor.white, for: .selected)
//    }

}
