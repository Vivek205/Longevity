//
//  AudioVisualizerView.swift
//  COVID Signals
//
//  Created by Jagan Kumar Mudila on 10/12/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class AudioVisualizerView: UIView {
    
    // Bar width
    var barWidth: CGFloat = 4.0
    // Indicate that waveform should draw active/inactive state
    var active = false {
        didSet {
            if self.active {
                self.color = UIColor.red.cgColor
            }
            else {
                self.color = UIColor.gray.cgColor
            }
        }
    }
    // Color for bars
    var color = UIColor.gray.cgColor
    // Given waveforms
    var waveforms: [Int] = Array(repeating: 0, count: 100)
    
    // MARK: - Init
    override init (frame : CGRect) {
        super.init(frame : frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.backgroundColor = UIColor.clear
    }
    
    // MARK: - Draw bars
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.clear(rect)
        context.setFillColor(red: 0, green: 0, blue: 0, alpha: 0)
        context.fill(rect)
        context.setLineWidth(1)
        context.setStrokeColor(self.color)
        let width = rect.size.width
        let height = rect.size.height
        let time = Int(width / self.barWidth)
        let side = max(0, self.waveforms.count - time)
        let middle = height / 2
        let radius = self.barWidth / 2
        let xposition = middle - radius
        var bar: CGFloat = 0
        for index in side ..< self.waveforms.count {
            var velocity = height * CGFloat(self.waveforms[index]) / 50.0
            if velocity > xposition {
                velocity = xposition
            }
            else if velocity < 3 {
                velocity = 3
            }
            let oneX = bar * self.barWidth
            var oneY: CGFloat = 0
            let twoX = oneX + radius
            var twoY: CGFloat = 0
            var twoS: CGFloat = 0
            var twoE: CGFloat = 0
            var twoC: Bool = false
            let threeX = twoX + radius
            let threeY = middle
            if index % 2 == 1 {
                oneY = middle - velocity
                twoY = middle - velocity
                twoS = -180.degreesToRadians
                twoE = 0.degreesToRadians
                twoC = false
            }
            else {
                oneY = middle + velocity
                twoY = middle + velocity
                twoS = 180.degreesToRadians
                twoE = 0.degreesToRadians
                twoC = true
            }
            context.move(to: CGPoint(x: oneX, y: middle))
            context.addLine(to: CGPoint(x: oneX, y: oneY))
            context.addArc(center: CGPoint(x: twoX, y: twoY), radius: radius, startAngle: twoS, endAngle: twoE, clockwise: twoC)
            context.addLine(to: CGPoint(x: threeX, y: threeY))
            context.strokePath()
            bar += 1
        }
    }

}

extension UIColor {
  public convenience init(redvalue: CGFloat, greenvalue: CGFloat, bluevalue: CGFloat) {
    self.init(red: redvalue/255, green: greenvalue/255, blue: bluevalue/255, alpha: 1)
  }
}
extension Int {
  var degreesToRadians: CGFloat {
    return CGFloat(self) * .pi / 180.0
  }
}
extension Double {
  var toTimeString: String {
    let seconds: Int = Int(self.truncatingRemainder(dividingBy: 60.0))
    let minutes: Int = Int(self / 60.0)
    return String(format: "%d:%02d", minutes, seconds)
  }
}
