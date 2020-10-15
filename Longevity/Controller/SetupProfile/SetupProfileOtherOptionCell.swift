//
//  SetupProfileOtherOptionCell.swift
//  Longevity
//
//  Created by vivek on 15/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit


class SetupProfileOtherOptionCell: UICollectionViewCell {
    @IBOutlet weak var otherOptionTextView: UITextView!
    @IBOutlet weak var clearDescriptionButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.otherOptionTextView.layer.borderWidth = 2.0
        self.otherOptionTextView.layer.cornerRadius = 16.5
        self.otherOptionTextView.layer.masksToBounds = true
        self.otherOptionTextView.layer.borderColor = UIColor.themeColor.cgColor
        
        self.otherOptionTextView.textContainerInset = UIEdgeInsets(top: 7.0, left: 14.0, bottom: 7.0, right: 14.0)
    }
}
