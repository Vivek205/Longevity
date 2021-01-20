//
//  AudioWaveCell.swift
//  COVID Signals
//
//  Created by Jagan Kumar Mudila on 18/12/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class AudioWaveCell: UICollectionViewCell {
    
    var audioSignal: AudioWaveSignal! {
        didSet {
            //Removing all existing layers
            if let layers = self.layer.sublayers {
                for layer in layers {
                        layer.removeFromSuperlayer()
                }
            }
            
            let rectBounds: CGRect = CGRect(x: bounds.origin.x, y: bounds.origin.y,
                                            width: bounds.size.width, height: CGFloat(audioSignal.signalLength))
            let rectPath: UIBezierPath = UIBezierPath(roundedRect: rectBounds, cornerRadius: rectBounds.width / 2.0)
            
            let maskLayer: CAShapeLayer = CAShapeLayer()
            maskLayer.frame = rectBounds
            maskLayer.path = rectPath.cgPath
            maskLayer.fillColor =  audioSignal.isPlaying ? UIColor.themeColor.cgColor : UIColor(hexString: "#50555C").cgColor
            maskLayer.position = self.center
            
            self.layer.addSublayer(maskLayer)
        }
    }
    
    var waveLength:Int! {
        didSet {
            //Removing all existing layers
            if let layers = self.layer.sublayers {
                for layer in layers {
                        layer.removeFromSuperlayer()
                }
            }
            
            let rectBounds: CGRect = CGRect(x: bounds.origin.x, y: bounds.origin.y,
                                            width: bounds.size.width, height: CGFloat(self.waveLength))
            let rectPath: UIBezierPath = UIBezierPath(roundedRect: rectBounds, cornerRadius: rectBounds.width / 2.0)
            
            let maskLayer: CAShapeLayer = CAShapeLayer()
            maskLayer.frame = rectBounds
            maskLayer.path = rectPath.cgPath
            maskLayer.fillColor = UIColor.black.cgColor
            maskLayer.position = self.center
            
            self.layer.addSublayer(maskLayer)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
