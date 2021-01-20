//
//  UICollectionView+Extension.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 07/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

extension UICollectionView {
    func getCell(with cellClass: AnyClass, at indexPath: IndexPath) -> UICollectionViewCell {
        let cellTypeName = NSStringFromClass(cellClass)
        self.register(cellClass, forCellWithReuseIdentifier: cellTypeName)
        return self.dequeueReusableCell(withReuseIdentifier: cellTypeName, for: indexPath)
    }
    
    func getUniqueCell(with cellClass: AnyClass, at indexPath: IndexPath) -> UICollectionViewCell {
        let cellTypeName = NSStringFromClass(cellClass) + "\(indexPath.item)"
        self.register(cellClass, forCellWithReuseIdentifier: cellTypeName)
        return self.dequeueReusableCell(withReuseIdentifier: cellTypeName, for: indexPath)
    }
    
    func getSupplementaryView(with viewClass: AnyClass, viewForSupplementaryElementOfKind kind: String,
                              at indexPath: IndexPath) -> UICollectionReusableView
    {
        let reusableViewName = NSStringFromClass(viewClass)
        self.register(viewClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: reusableViewName)
        return self.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reusableViewName, for: indexPath)
    }
}
