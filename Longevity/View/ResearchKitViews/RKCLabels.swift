//
//  RKCLabels.swift
//  Longevity
//
//  Created by vivek on 23/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation

class QuestionHeaderLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        styleLabel()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        styleLabel()
    }
    func styleLabel() {
        self.font = UIFont(name: "Montserrat-SemiBold", size: 24)
        self.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 1)
    }
}

class QuestionSubheaderLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        styleLabel()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        styleLabel()
    }
    func styleLabel() {
        self.font = UIFont(name: "Montserrat-Light", size: 18)
        self.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 1)
    }
}

class QuestionQuestionLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        styleLabel()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        styleLabel()
    }
    func styleLabel() {
        self.font = UIFont(name: "Montserrat-Regular", size: 24)
        self.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 1)
    }
}


class QuestionExtraInfoLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        styleLabel()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        styleLabel()
    }
    func styleLabel() {
        self.font = UIFont(name: "Montserrat-Medium", size: 24)
        self.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 1)
    }
}

class AnswerTitleLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        styleLabel()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        styleLabel()
    }
    func styleLabel() {
        self.font = UIFont(name: "Montserrat-Medium", size: 22)
        self.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    }
}

class AnswerDescriptionLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        styleLabel()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        styleLabel()
    }
    func styleLabel() {
        self.font = UIFont(name: "Montserrat-Medium", size: 14)
        self.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
    }
}
