//
//  SetupProfileDisclaimerVC.swift
//  Longevity
//
//  Created by vivek on 25/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Amplify

class SetupProfileDisclaimerVC: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var disclaimer: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        customizeDisclaimerLabel()
        self.removeBackButtonNavigation()
    }

    func customizeDisclaimerLabel() {
        let headingAttributes:[NSAttributedString.Key:Any] =
            [.font: UIFont(name: "Montserrat-SemiBold", size: CGFloat(18))]
        let heading = NSMutableAttributedString(string: "Disclaimer: ", attributes: headingAttributes)

        let detailsAttributes:[NSAttributedString.Key:Any] =
            [.font: UIFont(name: "Montserrat-Italic", size: CGFloat(18)),
             .foregroundColor:UIColor.darkGray
        ]

        let details =
            NSMutableAttributedString(
                string: "If you are experiencing an acute medical condition, you need to consult your doctor immediatly.",attributes: detailsAttributes)

        var disclaimerContent: NSMutableAttributedString = NSMutableAttributedString();
        disclaimerContent.append(heading)
        disclaimerContent.append(details)

        disclaimer.attributedText = disclaimerContent
    }

    // MARK: Actions
    @IBAction func handleContinue(_ sender: Any) {
        performSegue(withIdentifier: "SetupProfileDisclaimerToBioData", sender: self)
    }


}
