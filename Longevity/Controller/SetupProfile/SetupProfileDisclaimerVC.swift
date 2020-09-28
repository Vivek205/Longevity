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
    @IBOutlet weak var disclaimer: UILabel!
    @IBOutlet weak var infoLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        customizeDisclaimerLabel()
        self.removeBackButtonNavigation()
        self.addProgressbar(progress: 20.0)
        let width = self.view.frame.width
        NSLayoutConstraint.activate([
            infoLabel.widthAnchor.constraint(equalToConstant: (width - 30)),
            disclaimer.widthAnchor.constraint(equalToConstant: (width - 30))
        ])
    }

    func customizeDisclaimerLabel() {
        let headingAttributes:[NSAttributedString.Key:Any] =
            [.font: UIFont(name: "Montserrat-SemiBold", size: CGFloat(18))]
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
