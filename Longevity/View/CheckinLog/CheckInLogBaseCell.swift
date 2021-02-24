//
//  CheckInLogBaseCell.swift
//  COVID Signals
//
//  Created by Jagan Kumar Mudila on 24/02/2021.
//  Copyright © 2021 vivek. All rights reserved.
//

import UIKit

class CheckInLogBaseCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
