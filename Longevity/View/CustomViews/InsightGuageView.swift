//
//  InsightGuageView.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 11/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class InsightGuageView: UIView {
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        let radius = self.bounds.width / 2 - 10.0
        let circularPath = UIBezierPath(arcCenter: self.center, radius: radius, startAngle: CGFloat(135.0).toRadians(), endAngle: CGFloat(45.0).toRadians(), clockwise: true)
        
        super.layoutSubviews()
        let trackLayer = CAShapeLayer()
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.progressTrackColor.cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 10.0
        trackLayer.position = self.center
        layer.addSublayer(trackLayer)
        
        let progressLayer = CAShapeLayer()
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = UIColor.red.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 10.0
        progressLayer.strokeEnd = 0
        progressLayer.position = self.center
        layer.addSublayer(progressLayer)
        
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = 0.60
        basicAnimation.duration = 0.8
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        progressLayer.add(basicAnimation, forKey: "guageAnimation")
        
        let guageNeedleLayer = CAShapeLayer()
        let needlePath = UIBezierPath(arcCenter: self.center, radius: 5, startAngle: CGFloat(270.0).toRadians(), endAngle: CGFloat(90.0).toRadians(), clockwise: true)
            needlePath.addLine(to: CGPoint(x: self.center.x - (self.bounds.width / 2 - 14.0), y: self.center.y + 2))
        needlePath.addArc(withCenter: CGPoint(x: self.center.x - (self.bounds.width / 2 - 14.0), y: self.center.y), radius: 2.0, startAngle: CGFloat(90.0).toRadians(), endAngle: CGFloat(270.0).toRadians(), clockwise: true)
        needlePath.close()
        guageNeedleLayer.path = needlePath.cgPath
        guageNeedleLayer.fillColor = UIColor.themeColor.cgColor
        guageNeedleLayer.position = self.center
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = CGFloat(135.0).toRadians()
        rotationAnimation.toValue = CGFloat(200.0).toRadians()
        rotationAnimation.duration = 0.8
        rotationAnimation.isRemovedOnCompletion = false
        guageNeedleLayer.add(rotationAnimation, forKey: "needleAnimation")
        layer.addSublayer(guageNeedleLayer)
    }
}

extension CGFloat {
    func toRadians() -> CGFloat {
        return self * .pi / 180.0
    }
}
