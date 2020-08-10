//
//  TextChoiceAnswerViewCell.swift
//  Longevity
//
//  Created by vivek on 10/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class TextChoiceAnswerViewCell: UICollectionViewCell {
    var text: String?
    var extraInfo: String?

    let titleLabel: AnswerTitleLabel = {
        let label = AnswerTitleLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        styleCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        styleCell()
    }

    init(text:String, extraInfo:String?) {
        super.init(frame:CGRect())
        self.text = text
        self.extraInfo = extraInfo
//        styleCell()
    }

    func styleCell() {
        if self.text != nil {
            self.addSubview(titleLabel)

            let estimatedWidth = self.bounds.width - 40.0
            let attributes = [NSAttributedString.Key.font: titleLabel.font.pointSize]
            let estimatedSize = CGSize(width: estimatedWidth, height: 1000.0)
            let estimatedFrame = NSString(string: self.text!).boundingRect(with: estimatedSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)

            let estimatedHeight = estimatedFrame.height

            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
                titleLabel.heightAnchor.constraint(equalToConstant: estimatedHeight)
            ])
        }
    }
}
