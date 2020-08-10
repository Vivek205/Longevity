//
//  DashboardCollectionTileView.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 08/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class DashboardCollectionTileCell: UICollectionViewCell {
    
    lazy var hexagonView : UIView = {
        let hexagon = UIView()
        hexagon.backgroundColor = .hexagonColor
        hexagon.translatesAutoresizingMaskIntoConstraints = false
        return hexagon
    }()
    
    lazy var tileTitle: UILabel = {
        let title = UILabel()
        title.textAlignment = .center
        title.font = UIFont(name: "Montserrat-Medium", size: 14)
        title.textAlignment = .center
        title.numberOfLines = 0
        title.lineBreakMode = .byWordWrapping
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    var borderColor: UIColor = .hexagonBorderColor
    var isEmptyCell: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(hexagonView)
        self.hexagonView.addSubview(tileTitle)
        
        NSLayoutConstraint.activate([
            hexagonView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2.5),
            hexagonView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2.5),
            hexagonView.heightAnchor.constraint(equalTo: widthAnchor)
        ])
    }
    
    func setupCell(index: Int, isEmpty : Bool) {
        let isEvenCell = index % 2 == 0
        let vTop = isEvenCell ? 5.0 : self.bounds.height * 0.40
        
        NSLayoutConstraint.activate([
            hexagonView.topAnchor.constraint(equalTo: topAnchor, constant: vTop)
        ])
        
        if isEmpty {
            self.hexagonView.backgroundColor = .clear
            self.borderColor = .white
            self.isEmptyCell = true
        } else {
            self.hexagonView.backgroundColor = .hexagonColor
            self.borderColor = .hexagonBorderColor
            self.isEmptyCell = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let shapeSide = bounds.width - 5.0
        let shapePath = self.roundedPolygonPath(rect: CGRect(x: 0, y: 0, width: shapeSide, height: shapeSide), lineWidth: 1.0, sides: 6, cornerRadius: 5.0)
        
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = CGRect(x: 0, y: 0, width: shapeSide, height: shapeSide)
        maskLayer.path = shapePath.cgPath
        hexagonView.layer.mask = maskLayer
        
        let borderLayer: CAShapeLayer = CAShapeLayer()
        borderLayer.frame = CGRect(x: 0, y: 0, width: shapeSide, height: shapeSide)
        borderLayer.path = shapePath.cgPath
        borderLayer.strokeColor = self.borderColor.cgColor
        borderLayer.lineWidth = 2.0
        borderLayer.fillColor = UIColor.clear.cgColor
        hexagonView.layer.insertSublayer(borderLayer, at: 0)
        
        if !self.isEmptyCell {
            hexagonView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
            hexagonView.layer.shadowColor = UIColor.black.cgColor
            hexagonView.layer.shadowRadius = 2.0
            hexagonView.layer.shadowOpacity = 0.25
            hexagonView.layer.masksToBounds = false
            hexagonView.layer.shadowPath = shapePath.cgPath
        }
    }
    
    // Got it from internet
    fileprivate func roundedPolygonPath(rect: CGRect, lineWidth: CGFloat, sides: NSInteger, cornerRadius: CGFloat, rotationOffset: CGFloat = 0) -> UIBezierPath {
        let path = UIBezierPath()
        let theta: CGFloat = CGFloat(2.0 * .pi) / CGFloat(sides) // How much to turn at every corner
        let width = min(rect.size.width, rect.size.height)        // Width of the square

        let center = CGPoint(x: rect.origin.x + width / 2.0, y: rect.origin.y + width / 2.0)

        // Radius of the circle that encircles the polygon
        // Notice that the radius is adjusted for the corners, that way the largest outer
        // dimension of the resulting shape is always exactly the width - linewidth
        let radius = (width - lineWidth + cornerRadius - (cos(theta) * cornerRadius)) / 2.0

        // Start drawing at a point, which by default is at the right hand edge
        // but can be offset
        var angle = CGFloat(rotationOffset)

        let corner = CGPoint(x: center.x + (radius - cornerRadius) * cos(angle), y: center.y + (radius - cornerRadius) * sin(angle))
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
