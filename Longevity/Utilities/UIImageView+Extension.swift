//
//  UIImageView+Extension.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 28/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func cacheImage(urlString: String) {
        guard let urlstring = URL(string: urlString) else {
            self.image = UIImage(named: "avatar")
            return
        }
        
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: urlstring) {
            data, response, error in
            if data != nil {
                DispatchQueue.main.async {
                    guard let imageToCache = UIImage(data: data!) else {
                        self.image = UIImage(named: "avatar")
                        return
                    }
                    imageCache.setObject(imageToCache, forKey: urlString as AnyObject)
                    self.image = imageToCache
                }
            }
            }.resume()
    }
}
