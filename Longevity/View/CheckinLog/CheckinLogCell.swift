//
//  CheckinLogCell.swift
//  Longevity
//
//  Created by vivek on 27/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CheckinLogCell: UITableViewCell {

    lazy var card:CardView = {
        let view = CardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
           super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(card)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            card.topAnchor.constraint(equalTo: self.topAnchor),
            card.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
