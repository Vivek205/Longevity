//
//  SetupProfileOtherOptionCell.swift
//  Longevity
//
//  Created by vivek on 15/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

protocol SetupProfileOtherOptionCellDelegate {
    func updateCurrentText(text: String?)
    func textViewDidEndEditing(_ textView: UITextView)
    func textViewDidBeginEditing(_ textView: UITextView)
}

class SetupProfileOtherOptionCell: UICollectionViewCell {
    
    var delegate: SetupProfileOtherOptionCellDelegate?
    
    @IBOutlet weak var otherOptionTextView: UITextView!
    @IBOutlet weak var clearDescriptionButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureTextView(text: String?) {
        if text?.isEmpty ?? true {
            self.otherOptionTextView.layer.borderWidth = 1.0
            self.otherOptionTextView.layer.borderColor = UIColor(hexString: "#C8C8CC").cgColor
            self.clearDescriptionButton.isHidden = true
        } else {
            self.otherOptionTextView.layer.borderWidth = 2.0
            self.otherOptionTextView.layer.borderColor = UIColor.themeColor.cgColor
            self.clearDescriptionButton.isHidden = false
        }
        self.otherOptionTextView.text = text
        self.otherOptionTextView.delegate = self
        self.otherOptionTextView.addInputAccessoryView(title: "Done", target: self, selector: #selector(endTextEditing))
        self.clearDescriptionButton.addTarget(self, action: #selector(doClearDescription), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.otherOptionTextView.layer.cornerRadius = 16.5
        self.otherOptionTextView.layer.masksToBounds = true
        self.otherOptionTextView.textContainerInset = UIEdgeInsets(top: 7.0, left: 14.0, bottom: 7.0, right: 14.0)
    }
    
    @objc func endTextEditing() {
        self.otherOptionTextView.endEditing(true)
    }
    
    @objc func doClearDescription() {
        self.otherOptionTextView.text = nil
        self.delegate?.updateCurrentText(text: nil)
        self.clearDescriptionButton.isHidden =  self.otherOptionTextView.text.isEmpty
        self.endTextEditing()
    }
}

extension SetupProfileOtherOptionCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.otherOptionTextView.layer.borderWidth = 2.0
        self.otherOptionTextView.layer.borderColor = UIColor.themeColor.cgColor
        self.delegate?.textViewDidBeginEditing(textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.clearDescriptionButton.isHidden =  textView.text.isEmpty
        self.delegate?.updateCurrentText(text: textView.text)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.otherOptionTextView.layer.borderWidth = 1.0
        self.otherOptionTextView.layer.borderColor = UIColor(hexString: "#C8C8CC").cgColor
        self.clearDescriptionButton.isHidden =  textView.text.isEmpty
        self.delegate?.textViewDidEndEditing(textView)
    }
    
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        return true
    }
}
