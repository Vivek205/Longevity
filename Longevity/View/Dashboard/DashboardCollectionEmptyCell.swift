//
//  DashboardCollectionEmptyCell.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 01/09/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class DashboardCollectionEmptyCell: UICollectionViewCell {
    
    lazy var hexagonView : HexagonView = {
        let hexagon = HexagonView()
        hexagon.backgroundColor = .hexagonColor
        hexagon.translatesAutoresizingMaskIntoConstraints = false
        return hexagon
    }()
    
    lazy var tileTitle: UILabel = {
        let title = UILabel()
        title.textAlignment = .center
        title.text = "COVID-19 Infection"
        title.font = UIFont(name: "Montserrat-Medium", size: 14)
        title.textColor = .checkinCompleted
        title.numberOfLines = 0
        title.lineBreakMode = .byWordWrapping
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    lazy var emptyCellMessage: UILabel = {
        let emptyMessage = UILabel()
        emptyMessage.font = UIFont(name: "Montserrat-Medium", size: 14.0)
        emptyMessage.numberOfLines = 0
        emptyMessage.lineBreakMode = .byWordWrapping
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
        info.translatesAutoresizingMaskIntoConstraints = false
        info.addTarget(self, action: #selector(doOpenInfo), for: .touchUpInside)
        return info
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let vTop = self.bounds.height * 0.40
        
        self.hexagonView.backgroundColor = .clear
        self.hexagonView.borderColor = .white
        self.hexagonView.isEmptyCell = true
        
        self.tileTitle.text = "Longevity"
        self.tileTitle.textColor = .white
        self.infoButton.tintColor = .white
        
        self.addSubview(hexagonView)
        self.hexagonView.addSubview(tileTitle)
        self.hexagonView.addSubview(emptyCellMessage)
        self.hexagonView.addSubview(infoButton)
        
        NSLayoutConstraint.activate([
            hexagonView.topAnchor.constraint(equalTo: topAnchor, constant: vTop),
            tileTitle.widthAnchor.constraint(equalTo: hexagonView.widthAnchor, multiplier: 0.60),
            tileTitle.centerXAnchor.constraint(equalTo: hexagonView.centerXAnchor),
            tileTitle.topAnchor.constraint(equalTo: hexagonView.topAnchor, constant: 25.0),
            emptyCellMessage.widthAnchor.constraint(equalTo: hexagonView.widthAnchor, multiplier: 0.60),
            emptyCellMessage.centerXAnchor.constraint(equalTo: hexagonView.centerXAnchor),
            emptyCellMessage.topAnchor.constraint(equalTo: tileTitle.bottomAnchor, constant: 25.0),
            infoButton.topAnchor.constraint(equalTo: emptyCellMessage.bottomAnchor, constant: 20.0),
            infoButton.centerXAnchor.constraint(equalTo: emptyCellMessage.centerXAnchor),
            infoButton.widthAnchor.constraint(equalToConstant: 30.0),
            infoButton.heightAnchor.constraint(equalTo: infoButton.widthAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func doOpenInfo() {
        NavigationUtility.presentOverCurrentContext(
        destination: LongevityComingSoonPopupViewController(),
        style: .overCurrentContext,
        completion: nil)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var view = infoButton.hitTest(infoButton.convert(point, from: self), with: event)
        if view == nil {
            view = super.hitTest(point, with: event)
        }

        return view
    }
}
