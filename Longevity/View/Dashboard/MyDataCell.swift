//
//  MyDataCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 12/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class MyDataCell: UICollectionViewCell {
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.cornerRadius = 5.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.borderColor.cgColor
        contentView.layer.masksToBounds = true
    }
}
