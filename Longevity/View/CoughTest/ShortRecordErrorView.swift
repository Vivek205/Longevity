//
//  ShortRecordErrorView.swift
//  COVID Signals
//
//  Created by Jagan Kumar Mudila on 18/12/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class ShortRecordErrorView: UIView {
    
    lazy var statusMessage: UILabel = {
        let status = UILabel()
        status.text = "length too short, please try again"
        status.textAlignment = .center
        status.textColor = UIColor(hexString: "#4A4A4A")
        status.font = UIFont(name: AppFontName.regular, size: 14.0)
        status.translatesAutoresizingMaskIntoConstraints = false
        return status
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(hexString: "#FDE5E8")
        self.addSubview(statusMessage)
        
        NSLayoutConstraint.activate([
            statusMessage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            statusMessage.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            statusMessage.topAnchor.constraint(equalTo: self.topAnchor, constant: 13.0),
            statusMessage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -13.0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor(hexString: "#E67381").cgColor
        layer.cornerRadius  = 4.0
    }
}
