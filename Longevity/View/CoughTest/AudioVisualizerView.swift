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

    // Given waveforms
    var waveforms: [Int]! {
        didSet {
            self.visualizerView.reloadData()
        }
    }
    
    var audioSignals: [AudioWaveSignal]! {
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
        self.lastIndex = 0
        self.audioSignals = []
    }
}

extension AudioVisualizerView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = max(self.waveforms.count, self.audioSignals.count)
        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.getUniqueCell(with: AudioWaveCell.self, at: indexPath) as? AudioWaveCell else { preconditionFailure("Invalid cell")}
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
