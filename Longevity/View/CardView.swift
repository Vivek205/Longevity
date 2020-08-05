//
//  CardView.swift
//  Longevity
//
//  Created by vivek on 03/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CardView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        styleView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        styleView()
    }

    override func layoutSubviews() {
        applyShadow()
    }

    func styleView() {
        self.backgroundColor = .white
    }

    func applyShadow() {
           let shadowPath = UIBezierPath(rect: self.bounds)
           self.layer.masksToBounds = false
           self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.14).cgColor
           self.layer.shadowOpacity = 1
           self.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
           self.layer.shadowRadius = 10
           self.layer.shadowPath = shadowPath.cgPath
       }

}
