//
//  String.swift
//  Longevity
//
//  Created by vivek on 13/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation

// MARK: Regex Validation of String
extension String {
   var isValidEmail: Bool {
      let regularExpressionForEmail = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
      let testEmail = NSPredicate(format:"SELF MATCHES %@", regularExpressionForEmail)
      return testEmail.evaluate(with: self)
   }
   var isValidPhone: Bool {
      let regularExpressionForPhone = "^((\\+)|(00))[0-9]{6,14}$" 
      let testPhone = NSPredicate(format:"SELF MATCHES %@", regularExpressionForPhone)
      return testPhone.evaluate(with: self)
   }
}

// MARK: Calculate Height/Width based on font
extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil)
        return ceil(boundingBox.height)
    }
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat{
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil)
        return ceil(boundingBox.width)
    }
}


//MARK: Convert Text to image
extension String {
    func toImage(color:UIColor = .white, fontSize:CGFloat = 20) -> UIImage {
        let attributes = [
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)
        ]
        let textSize = self.size(withAttributes: attributes)

        UIGraphicsBeginImageContextWithOptions(textSize, true, 0)
        self.draw(at: CGPoint.zero, withAttributes: attributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return  image ?? UIImage()
    }
}
