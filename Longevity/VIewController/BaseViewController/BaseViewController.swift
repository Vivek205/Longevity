//
//  BaseViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 06/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

enum RejuveTab: Int, CaseIterable {
    case home = 0
    case myData
    case profile
    case shareApp
}

extension RejuveTab {
    var tabTitle : String {
        switch self {
        case .home:
            return "Home"
        case .myData:
            return "My Data"
        case .profile:
            return "Profile"
        case .shareApp:
            return "Share App"
        }
    }
    
    var tabViewTitle : String {
        switch self {
        case .home:
            return "Home"
        case .myData:
            return "My Data"
        case .profile:
            return "Profile Activity"
        case .shareApp:
            return "Share App"
        }
    }
    
    var tabIcon: UIImage? {
        switch self {
        case .home:
            return UIImage(named: "tab-home")
        case .myData:
            return UIImage(named: "tab-mydata")
        case .profile:
            return UIImage(named: "tab-profile")
        case .shareApp:
            return UIImage(named: "tab-share")
        }
    }
}

class BaseViewController: UIViewController {
    var viewTab: RejuveTab?
    
    lazy var titleView: TitleView = {
        let title = TitleView(viewTab: self.viewTab ?? .home)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    

    init(viewTab: RejuveTab) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewTab = viewTab
        
        self.setTabItems()
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(titleView)
        
        let vTop = UIDevice.hasNotch ? 30.0 : 0.0
        
        NSLayoutConstraint.activate([titleView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                     titleView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                                     titleView.topAnchor.constraint(equalTo: self.view.topAnchor),
                                     titleView.heightAnchor.constraint(equalToConstant: CGFloat(70 + vTop))
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setTabItems() {
        self.tabBarItem = UITabBarItem(title: self.viewTab?.tabTitle, image: self.viewTab?.tabIcon, tag: 0)
    }
}