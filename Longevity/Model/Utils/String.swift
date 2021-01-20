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
    func toImage(color:UIColor = .black,
                 backgroundColor:UIColor = .appBackgroundColor,
                 font:UIFont? = UIFont.systemFont(ofSize: 20)) -> UIImage {
        guard let font = font else {return UIImage()}
        let attributes:[NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.backgroundColor: backgroundColor,
            NSAttributedString.Key.font: font
        ]
       let attributedSize = self.size(withAttributes: attributes)
        let textSize = CGSize(width: attributedSize.width - 1, height: attributedSize.height )

        let drawingRect = CGRect(x: 0, y: 0, width: attributedSize.width, height: attributedSize.height)

        UIGraphicsBeginImageContextWithOptions(textSize, true, 0)
        self.draw(in: drawingRect, withAttributes: attributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return  image ?? UIImage()
    }
}

// MARK: Capitalizing First Character
extension String {
    func capitalizeFirstChar() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstChar() {
        self = self.capitalizeFirstChar()
    }
}
