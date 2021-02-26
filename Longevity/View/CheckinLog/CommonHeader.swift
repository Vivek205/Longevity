//
//  CommonHeader.swift
//  COVID Signals
//
//  Created by Jagan Kumar Mudila on 24/02/2021.
//  Copyright © 2021 vivek. All rights reserved.
//

import UIKit

class CommonHeader: UITableViewHeaderFooterView {
    
    lazy var headerlabel: UILabel = {
        let headerlabel = UILabel()
        headerlabel.text = ""
        headerlabel.font = UIFont(name: "Montserrat-SemiBold", size: 18.0)
        headerlabel.textColor = UIColor(hexString: "#4E4E4E")
        headerlabel.translatesAutoresizingMaskIntoConstraints = false
        return headerlabel
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(view)
        view.addSubview(headerlabel)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            headerlabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.0),
            headerlabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupHeaderText(font: UIFont?, title: String) {
        self.headerlabel.text = title
        self.headerlabel.font = font
    }
}
