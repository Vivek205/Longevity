//
//  SetupCompleteVC.swift
//  Longevity
//
//  Created by vivek on 14/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//
//
import UIKit
import ResearchKit

class SetupCompleteVC: BaseProfileSetupViewController {
    @IBOutlet weak var noteLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeBackButtonNavigation()
        
        let footerheight: CGFloat = UIDevice.hasNotch ? 130.0 : 96.0
        
        let headingAttributes:[NSAttributedString.Key:Any] =
            [.font: UIFont(name: "Montserrat-SemiBold", size: CGFloat(18)), .foregroundColor: UIColor.sectionHeaderColor]
        let heading = NSMutableAttributedString(string: "Note: ", attributes: headingAttributes)

        let detailsAttributes:[NSAttributedString.Key:Any] =
            [.font: UIFont(name: "Montserrat-Italic", size: CGFloat(18)),
             .foregroundColor: UIColor.sectionHeaderColor
        ]

        let details =
            NSMutableAttributedString(
                string: "You can edit your health profile any time from your Profile Settings",attributes: detailsAttributes)

        var noteContent: NSMutableAttributedString = NSMutableAttributedString()
        noteContent.append(heading)
        noteContent.append(details)

        noteLabel.attributedText = noteContent
    }

    func navigateForward() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setRootViewController()
    }
    
    @IBAction func onShowDashboard(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        appDelegate.setRootViewController()
    }

    @IBAction func handleBeginSurvey(_ sender: Any) {
        self.showSpinner()
        func onCreateSurveyCompletion(_ task: ORKOrderedTask?) {
            DispatchQueue.main.async {
                self.removeSpinner()
                if task != nil {
                    self.dismiss(animated: false) { [weak self] in
                        let taskViewController = SurveyViewController(task: task, isFirstTask: true, isFirstCheckin: true)
                        NavigationUtility.presentOverCurrentContext(destination: taskViewController, style: .overCurrentContext)
                    }
                } else {
                    Alert(title: "Survey Not available",
                                   message: "No questions are found for the survey. Please try after sometime")
                }
            }
        }
        func onCreateSurveyFailure(_ error: Error) {
            DispatchQueue.main.async {
                self.removeSpinner()
                Alert(title: "Survey Not available",
                               message: "No questions are found for the survey. Please try after sometime")
            }
        }
        
        SurveyTaskUtility.shared.createSurvey(surveyId: nil, completion: onCreateSurveyCompletion(_:),
                                              onFailure: onCreateSurveyFailure(_:))
    }
}
