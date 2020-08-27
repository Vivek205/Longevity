//
//  UIImage+Extension.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 06/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

extension UIImage {
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRect(x: 0 , y: 0, width: size.width, height: size.height * 2)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIColor.lightGray.setStroke()
        let path = UIBezierPath(roundedRect: CGRect(origin: rect.origin, size: CGSize(width: rect.width, height: rect.height)) , byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 25.0, height: 25.0))
        path.fill()
        path.lineWidth = 0.5
        path.stroke()
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }

        return self
    }
}
