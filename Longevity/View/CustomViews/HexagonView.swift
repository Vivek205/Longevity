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
    var borderWidth: CGFloat = 2.0
    var isEmptyCell: Bool = false
    
    var shapePath:UIBezierPath?
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let shapeSide = bounds.width - 5.0
        self.shapePath = self.roundedPolygonPath(rect: CGRect(x: 10.0, y: 0.0, width: shapeSide, height: shapeSide), lineWidth: 1.0, sides: 6, cornerRadius: 5.0)
        
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.path = shapePath!.cgPath
        self.layer.mask = maskLayer
        
        let borderLayer: CAShapeLayer = CAShapeLayer()
        borderLayer.path = shapePath!.cgPath
        borderLayer.strokeColor = self.borderColor.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.fillColor = UIColor.clear.cgColor
        self.layer.insertSublayer(borderLayer, at: 0)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if !isEmptyCell {
            let points = UIBezierPath(ovalIn: shapePath?.bounds ?? CGRect.zero)
            return points.contains(point)
        }
        return shapePath?.contains(point) ?? false
    }
}
