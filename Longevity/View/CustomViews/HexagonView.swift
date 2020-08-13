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
    
    // Got it from internet
    fileprivate func roundedPolygonPath(rect: CGRect, lineWidth: CGFloat, sides: NSInteger, cornerRadius: CGFloat, rotationOffset: CGFloat = 0) -> UIBezierPath {
        
        let theta: CGFloat = CGFloat(2.0 * .pi) / CGFloat(sides) // How much to turn at every corner
        let width = min(rect.size.width, rect.size.height)        // Width of the square

        let center = self.center

        // Radius of the circle that encircles the polygon
        // Notice that the radius is adjusted for the corners, that way the largest outer
        // dimension of the resulting shape is always exactly the width - linewidth
        let radius = (width - lineWidth + cornerRadius - (cos(theta) * cornerRadius)) / 2.0

        // Start drawing at a point, which by default is at the right hand edge
        // but can be offset
        var angle = CGFloat(rotationOffset)

        let corner = CGPoint(x: center.x + (radius - cornerRadius) * cos(angle), y: center.y + (radius - cornerRadius) * sin(angle))
        let path = UIBezierPath()
        path.move(to: CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta)))

        for _ in 0..<sides {
            angle += theta

            let corner = CGPoint(x: center.x + (radius - cornerRadius) * cos(angle), y: center.y + (radius - cornerRadius) * sin(angle))
            let shapetip = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            let start = CGPoint(x: corner.x + cornerRadius * cos(angle - theta), y: corner.y + cornerRadius * sin(angle - theta))
            let spaeend = CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta))

            path.addLine(to: start)
            path.addQuadCurve(to: spaeend, controlPoint: shapetip)
        }
        
        path.close()

        path.apply(CATransform3DGetAffineTransform(CATransform3DMakeRotation(-CGFloat.pi/2, 0, 0, 1)))
        // Move the path to the correct origins
        let bounds = path.bounds
        let transform = CGAffineTransform(translationX: -bounds.origin.x + rect.origin.x + lineWidth / 2.0, y: -bounds.origin.y + rect.origin.y + lineWidth / 2.0)
        path.apply(transform)
        return path
    }
}
