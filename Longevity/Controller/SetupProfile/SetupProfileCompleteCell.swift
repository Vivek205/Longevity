//
//  SetupProfileCompleteCell.swift
//  Longevity
//
//  Created by vivek on 14/09/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class SetupProfileCompleteCell: UICollectionViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!{
        didSet {
            descriptionLabel.numberOfLines = 0
            descriptionLabel.text = "You are ready to begin your first COVID Check-in which will help determine your current COVID-19 infection risk and symptoms."
            descriptionLabel.font = UIFont(name: AppFontName.regular, size: 24)
            descriptionLabel.textColor = .sectionHeaderColor
        }
    }
    @IBOutlet weak var noteLabel: UILabel! {
        didSet {
            noteLabel.numberOfLines = 0
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.semibold, size: 18.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
            let attributedInfoText = NSMutableAttributedString(string: "Note: ", attributes: attributes)

            attributedInfoText.append(NSAttributedString(string: "You can edit your health profile anytime from your Profile Settings", attributes: [NSAttributedString.Key.font: UIFont(name: AppFontName.italic, size: 18.0)]))
            noteLabel.attributedText = attributedInfoText
            noteLabel.textColor = .sectionHeaderColor
        }
    }
}
