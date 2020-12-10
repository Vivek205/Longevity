//
//  SetupProfileDevicesFooterView.swift
//  COVID Signals
//
//  Created by vivek on 10/12/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

protocol SetupProfileDevicesFooterViewCellDelegate {
    func continueButton(wasPressedOnCell cell:SetupProfileDevicesFooterView)
}

class SetupProfileDevicesFooterView: UICollectionViewCell {
    var delegate: SetupProfileDevicesFooterViewCellDelegate?

    lazy var continueButton: CustomButtonFill = {
        let button = CustomButtonFill(title: "Continue", target: self, action: #selector(handleContinue(_:)))
        return button
    }()

    @objc func handleContinue(_ sender: UIButton){
        delegate?.continueButton(wasPressedOnCell: self)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(continueButton)

        continueButton.anchor(.leading(leadingAnchor, constant: 15), .trailing(trailingAnchor, constant: 15),
                              .top(topAnchor, constant: 15), .height(48))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
