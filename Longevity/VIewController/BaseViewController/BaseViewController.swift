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
    case logger
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
        default:
            return "Local Logs"
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
        default:
            return "Logs"
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
        default:
            return UIImage(named: "tab-share")
        }
    }
}

class BaseViewController: UIViewController {
    var viewTab: RejuveTab?
    
    let headerHeight = UIDevice.hasNotch ? 100.0 : 80.0
    
    lazy var titleView: TitleView = {
        let title = TitleView(viewTab: self.viewTab ?? .home)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    init(viewTab: RejuveTab) {
        super.init(nibName: nil, bundle: nil)
        self.viewTab = viewTab
        self.setTabItems()
        self.view.backgroundColor = UIColor(hexString: "#F5F6FA")
        self.view.addSubview(titleView)
        
        NSLayoutConstraint.activate([titleView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                     titleView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                                     titleView.topAnchor.constraint(equalTo: self.view.topAnchor),
                                     titleView.heightAnchor.constraint(equalToConstant: CGFloat(headerHeight))
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setTabItems() {
        self.tabBarItem = UITabBarItem(title: self.viewTab?.tabTitle, image: self.viewTab?.tabIcon, tag: self.viewTab?.rawValue ?? 0)
        
        let textAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor(hexString: "#8E8E93"), NSAttributedString.Key.font: UIFont(name: "Montserrat-Regular", size: 11.0)]
        
        self.tabBarItem.setTitleTextAttributes(textAttributes, for: .normal)
        
        let selectedTextAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor(hexString: "#4A4A4A"), NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 11.0)]
        self.tabBarItem.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        
        self.tabBarItem.imageInsets = UIEdgeInsets(top: 2.0, left: 2.0, bottom: 0.0, right: 2.0)
    }
}
