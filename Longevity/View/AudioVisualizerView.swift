//
//  AudioVisualizerView.swift
//  COVID Signals
//
//  Created by Jagan Kumar Mudila on 10/12/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class AudioVisualizerView: UIView {
    
    lazy var totalWaves: Int = {
        let totalWidth = UIScreen.main.bounds.size.width
        return Int (totalWidth / 2)
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
    var waveforms: [Int]! {
        didSet {
            self.visualizerView.reloadData()
        }
    }
    
    var lastIndex: Int = 0
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        self.backgroundColor = UIColor.clear
        
        self.addSubview(self.visualizerView)
        
        self.visualizerView.delegate = self
        self.visualizerView.dataSource = self
        
        NSLayoutConstraint.activate([
            self.visualizerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.visualizerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.visualizerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.visualizerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        guard let layout = visualizerView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        layout.sectionInset = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)
        layout.itemSize = CGSize(width: 2.0, height: self.visualizerView.bounds.height)
        layout.minimumLineSpacing = 1
        layout.scrollDirection = .horizontal
        layout.invalidateLayout()
        
        self.waveforms = Array(repeating: 2, count: self.totalWaves)
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.backgroundColor = UIColor.clear
    }
    
    func updateWave(length: Int) {
        if lastIndex < (waveforms.count) {
            self.waveforms[lastIndex] = length
            lastIndex += 1
        }
    }
    
    func resetWaves() {
        self.lastIndex = 0
        self.waveforms = Array(repeating: 2, count: self.totalWaves)
    }
}

extension AudioVisualizerView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.waveforms.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.getUniqueCell(with: AudioWaveCell.self, at: indexPath) as? AudioWaveCell else { preconditionFailure("Invalid cell")}
        cell.waveLength = self.waveforms[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 2.0, height: collectionView.bounds.height)
    }
}

class AudioWaveCell: UICollectionViewCell {
    
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
