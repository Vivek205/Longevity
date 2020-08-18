//
//  HexagonView.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 11/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class HexagonView: UIView {
    
    var borderColor: UIColor = .borderColor
    var isEmptyCell: Bool = false
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let shapeSide = bounds.width - 5.0
        let shapePath = self.roundedPolygonPath(rect: CGRect(x: 10.0, y: 0.0, width: shapeSide, height: shapeSide), lineWidth: 1.0, sides: 6, cornerRadius: 5.0)
        
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.path = shapePath.cgPath
        self.layer.mask = maskLayer
        
        let borderLayer: CAShapeLayer = CAShapeLayer()
        borderLayer.path = shapePath.cgPath
        borderLayer.strokeColor = self.borderColor.cgColor
        borderLayer.lineWidth = 2.0
        borderLayer.fillColor = UIColor.clear.cgColor
        self.layer.insertSublayer(borderLayer, at: 0)
        
        if !self.isEmptyCell {
            self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowRadius = 2.0
            self.layer.shadowOpacity = 0.25
            self.layer.masksToBounds = false
            self.layer.shadowPath = shapePath.cgPath
        }
    }
}
