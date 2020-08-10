//
//  UITableView+Extension.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 07/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

extension UITableView {
    func getCell(with cellClass: AnyClass, at indexPath: IndexPath) -> UITableViewCell {
        let cellTypeName = NSStringFromClass(cellClass)
        self.register(cellClass, forCellReuseIdentifier: cellTypeName)
        return self.dequeueReusableCell(withIdentifier: cellTypeName, for: indexPath)
    }
    
    func getHeader(with viewClass: AnyClass) -> UITableViewHeaderFooterView? {
        let viewTypeName = NSStringFromClass(viewClass)
        self.register(viewClass, forHeaderFooterViewReuseIdentifier: viewTypeName)
        return self.dequeueReusableHeaderFooterView(withIdentifier: viewTypeName)
    }
}
