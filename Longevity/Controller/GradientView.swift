//
//  GradientView.swift
//  Longevity
//
//  Created by vivek on 29/05/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {
    // MARK: Variables
    @IBInspectable var firstColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }

    @IBInspectable var secondColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }

    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }

    func updateView() {
        print("view updated")
        let newGradientLayer = CAGradientLayer()
        newGradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        newGradientLayer.frame = self.frame
        self.layer.insertSublayer(newGradientLayer, at: 0)
    }

}
