//
//  MyUnwindSegue.swift
//  Longevity
//
//  Created by vivek on 09/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CustomUnwindSegue: UIStoryboardSegue {

    override func perform() {
//        print("custom segue", source)
        guard let navigation = source.navigationController else {return}
//        print("navigation", source.navigationController)
        guard let root = navigation.viewControllers.first else {return}
//        print("root", root)
//        print(destination)
//        let root  =  UIApplication.shared.windows.first!.rootViewController
//        print("root", root)
        let viewControllers: [UIViewController] = [root, destination]
//        print("view controllers", viewControllers)
        navigation.setViewControllers(viewControllers, animated: true)
    }

}
