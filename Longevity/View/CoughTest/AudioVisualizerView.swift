//
//  AudioVisualizerView.swift
//  COVID Signals
//
//  Created by Jagan Kumar Mudila on 10/12/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

struct AudioWaveSignal {
    let time: TimeInterval
    var isPlaying: Bool
    let signalLength: Int
}

class AudioVisualizerView: UIView {
    
    lazy var totalWaves: Int = {
        let totalWidth = UIScreen.main.bounds.size.width
        return Int (totalWidth / 3)
    }()
    
    lazy var visualizerView: UICollectionView = {
        let visualizerview = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        visualizerview.backgroundColor = .clear
        visualizerview.showsVerticalScrollIndicator = false
        visualizerview.showsHorizontalScrollIndicator = false
        visualizerview.allowsSelection = false
        visualizerview.isScrollEnabled = false
        visualizerview.translatesAutoresizingMaskIntoConstraints = false
        return visualizerview
    }()

    var barWidth: CGFloat = 4.0
    
    // Given waveforms
    var waveforms: [Int]! {
        didSet {
            self.setNeedsDisplay()
//            DispatchQueue.main.async {
//                self.visualizerView.reloadData()
//            }
        }
    }
    
    var audioSignals: [AudioWaveSignal]! {
        didSet {
            self.setNeedsDisplay()
//            DispatchQueue.main.async {
//                self.visualizerView.reloadData()
//            }
        }
    }
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        self.backgroundColor = UIColor.clear
        
//        self.addSubview(self.visualizerView)
//
//        self.visualizerView.delegate = self
//        self.visualizerView.dataSource = self
//
//        NSLayoutConstraint.activate([
//            self.visualizerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//            self.visualizerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
//            self.visualizerView.topAnchor.constraint(equalTo: self.topAnchor),
//            self.visualizerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
//        ])
//
//        guard let layout = visualizerView.collectionViewLayout as? UICollectionViewFlowLayout else {
//            return
//        }
//
//        layout.sectionInset = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)
//        layout.itemSize = CGSize(width: 2.0, height: self.visualizerView.bounds.height)
//        layout.minimumLineSpacing = 1
//        layout.scrollDirection = .horizontal
//        layout.invalidateLayout()
        
        self.audioSignals = []
        self.waveforms = Array(repeating: 2, count: self.totalWaves)
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.backgroundColor = UIColor.clear
    }
    
    func updateWave(signal: AudioWaveSignal) {
        self.audioSignals.append(signal)
    }
    
    func resetWaves() {
        self.audioSignals = []
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
        
        var xPoistion: CGFloat = rect.origin.x + 1.0
        
        for index in 0 ..< self.waveforms.count {
            let signalHeight: CGFloat = index < self.audioSignals.count ? CGFloat(self.audioSignals[index].signalLength) : 2.0
            let isPlaying = index < self.audioSignals.count && self.audioSignals[index].isPlaying
            let middleY: CGFloat = (rect.height / 2) - (signalHeight / 2.0)
            let maxY: CGFloat = middleY + signalHeight
            context.move(to: CGPoint(x: xPoistion, y: middleY))
            context.addLine(to: CGPoint(x: xPoistion, y: maxY))
            if isPlaying {
                context.setStrokeColor(UIColor.themeColor.cgColor)
            } else {
                context.setStrokeColor(UIColor(hexString: "#50555C").cgColor)
            }
            context.strokePath()
            xPoistion += 3.0
        }
    }
}

extension AudioVisualizerView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = max(self.waveforms.count, self.audioSignals.count)
        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.getCell(with: AudioWaveCell.self, at: indexPath) as? AudioWaveCell else { preconditionFailure("Invalid cell")}
        if indexPath.item < self.audioSignals.count {
            cell.audioSignal = self.audioSignals[indexPath.item]
        } else {
            cell.waveLength = self.waveforms[indexPath.item]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height - 20.0
        return CGSize(width: 2.0, height: height)
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
