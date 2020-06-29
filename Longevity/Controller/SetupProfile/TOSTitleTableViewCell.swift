//
//  TOSTitleTableViewCell.swift
//  Longevity
//
//  Created by vivek on 25/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class TOSTitleTableViewCell: UITableViewCell {
    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
