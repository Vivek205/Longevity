//
//  HomeVC.swift
//  Longevity
//
//  Created by vivek on 20/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

// FIXME: Delete this view controller and storyboard

class HomeVC: UIViewController {
    var surveysData: [SurveyListItem]?
    var surveyId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveDataAndInitializeTheViews()
    }

    func retrieveDataAndInitializeTheViews() {
        self.showSpinner()

        func completion(_ surveys:[SurveyListItem]) {
            DispatchQueue.main.async {
                self.surveysData = surveys
                self.removeSpinner()
            }
        }

        func onFailure(_ error:Error) {
            DispatchQueue.main.async {
                self.removeSpinner()
            }

        }
        getSurveys(completion: completion(_:), onFailure: onFailure(_:))
    }
}
