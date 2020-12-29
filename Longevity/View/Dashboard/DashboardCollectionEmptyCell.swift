//
//  DashboardCollectionEmptyCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 01/09/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class DashboardCollectionEmptyCell: CommonHexagonCell {
    
    lazy var tileTitle: UILabel = {
        let title = UILabel()
        title.textAlignment = .center
        title.text = "Longevity"
        title.font = UIFont(name: AppFontName.medium, size: 14.0)
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    lazy var emptyCellMessage: UILabel = {
        let emptyMessage = UILabel()
        emptyMessage.font = UIFont(name: AppFontName.lightitalic, size: 14.0)
        emptyMessage.textColor = .white
        emptyMessage.text = "Coming Soon"
        emptyMessage.textAlignment = .center
        emptyMessage.translatesAutoresizingMaskIntoConstraints = false
        return emptyMessage
    }()
    
    lazy var infoButton: UIButton = {
        let info = UIButton()
        info.setImage(UIImage(named: "icon-info"), for: .normal)
        info.tintColor = .white
        info.isUserInteractionEnabled = false
        info.translatesAutoresizingMaskIntoConstraints = false
        return info
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.hexagonView.backgroundColor = .clear
        self.hexagonView.borderColor = .white
        self.hexagonView.isEmptyCell = true
        
        self.contentView.addSubview(tileTitle)
        self.contentView.addSubview(emptyCellMessage)
        self.contentView.addSubview(infoButton)
        
        NSLayoutConstraint.activate([
            tileTitle.widthAnchor.constraint(equalTo: hexagonView.widthAnchor, multiplier: 0.60),
            tileTitle.centerXAnchor.constraint(equalTo: hexagonView.centerXAnchor),
            tileTitle.bottomAnchor.constraint(equalTo: emptyCellMessage.topAnchor, constant: -8.0),
            emptyCellMessage.widthAnchor.constraint(equalTo: hexagonView.widthAnchor, multiplier: 0.60),
            emptyCellMessage.centerXAnchor.constraint(equalTo: hexagonView.centerXAnchor),
            emptyCellMessage.centerYAnchor.constraint(equalTo: hexagonView.centerYAnchor),
            infoButton.topAnchor.constraint(equalTo: emptyCellMessage.bottomAnchor, constant: 20.0),
            infoButton.centerXAnchor.constraint(equalTo: emptyCellMessage.centerXAnchor),
            infoButton.widthAnchor.constraint(equalToConstant: 30.0),
            infoButton.heightAnchor.constraint(equalTo: infoButton.widthAnchor)
        ])
    }
    
    func setupcell(index: Int) {
        let isEvenCell = index % 2 == 0
        let vTop = isEvenCell ? 0.0 : self.bounds.height * 0.40
        NSLayoutConstraint.activate([
            hexagonView.topAnchor.constraint(equalTo: self.topAnchor, constant: vTop),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func doOpenInfo() {
        NavigationUtility.presentOverCurrentContext(
        destination: LongevityComingSoonPopupViewController(),
            style: .overCurrentContext, transitionStyle: .crossDissolve,
        completion: nil)
    }
}

class CommonHexagonCell: UICollectionViewCell {
    
    lazy var hexagonView : HexagonView = {
        let hexagon = HexagonView()
        hexagon.backgroundColor = .hexagonColor
        hexagon.translatesAutoresizingMaskIntoConstraints = false
        return hexagon
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(hexagonView)
        
        NSLayoutConstraint.activate([
            hexagonView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            hexagonView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            hexagonView.heightAnchor.constraint(equalTo: self.contentView.widthAnchor)
        ])
        
        self.hexagonView.isUserInteractionEnabled = true
        let taprecognizer = UITapGestureRecognizer(target: self, action: #selector(doOpenInfo))
        self.hexagonView.addGestureRecognizer(taprecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func doOpenInfo() {
        
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        for view in self.contentView.subviews {
            if view == hitView {
                return view
            }
        }
        return nil
    }
}

extension UIFont {
    func withTraits(traits:UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }

    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }

    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
}
