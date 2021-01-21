//
//  SetupProfileDisclaimerVC.swift
//  Longevity
//
//  Created by vivek on 25/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify

class SetupProfileDisclaimerVC: BaseProfileSetupViewController {
    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var disclaimer: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var footerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeDisclaimerLabel()
        titleLabel.font = UIFont(name: AppFontName.semibold,
                                 size: 24)
        titleLabel.textColor = .sectionHeaderColor
        infoLabel.font = UIFont(name: AppFontName.regular, size: 20)
        infoLabel.textColor = .sectionHeaderColor

        self.removeBackButtonNavigation()
        self.addProgressbar(progress: 20.0)
        
        let footerheight: CGFloat = UIDevice.hasNotch ? 130.0 : 96.0
        
        NSLayoutConstraint.activate([
            self.footerView.heightAnchor.constraint(equalToConstant: footerheight)
        ])
    }

    func customizeDisclaimerLabel() {
        let headingAttributes:[NSAttributedString.Key:Any] =
            [.font: UIFont(name: "Montserrat-SemiBold", size: CGFloat(18)), .foregroundColor: UIColor.sectionHeaderColor]
        let heading = NSMutableAttributedString(string: "Disclaimer: ", attributes: headingAttributes)

        let detailsAttributes:[NSAttributedString.Key:Any] =
            [.font: UIFont(name: "Montserrat-Italic", size: CGFloat(18)),
             .foregroundColor: UIColor.sectionHeaderColor
        ]

        let details =
            NSMutableAttributedString(
                string: "If you are experiencing an acute medical condition, you need to consult your doctor immediatly.",attributes: detailsAttributes)

        var disclaimerContent: NSMutableAttributedString = NSMutableAttributedString()
        disclaimerContent.append(heading)
        disclaimerContent.append(details)

        disclaimer.attributedText = disclaimerContent
    }

    // MARK: Actions
    @IBAction func handleContinue(_ sender: Any) {
        performSegue(withIdentifier: "SetupProfileDisclaimerToBioData", sender: self)
    }
}
