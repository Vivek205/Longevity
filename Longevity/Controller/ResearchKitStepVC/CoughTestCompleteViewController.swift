//
//  CoughTestCompleteViewController.swift
//  COVID Signals
//
//  Created by Jagan Kumar Mudila on 03/03/2021.
//  Copyright © 2021 vivek. All rights reserved.
//

import UIKit
import ResearchKit

class CoughTestCompleteViewController: CompleteStepBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presentViews()
        
        self.navigationItem.title = "Cough Test Complete"
            
        self.infoLabel.text = "Thank you for completing the cough test. Your results are being processed by our AI analyzer.\n\nThis may take few seconds to process and update."
        self.primaryActionButton.setTitle("View Results", for: .normal)
        self.secondaryActionButton.setTitle("Back to My Dashboard.", for: .normal)
        self.secondaryActionButton.setTitleColor(.themeColor, for: .normal)
        self.secondaryActionButton.titleLabel?.font = UIFont(name: AppFontName.regular, size: 20.0)
        self.primaryActionButton.addTarget(self, action: #selector(doViewResults), for: .touchUpInside)
        self.secondaryActionButton.addTarget(self, action: #selector(handleContinue(sender:)), for: .touchUpInside)
        
        self.secondaryActionButton.layer.borderWidth = 0
        self.secondaryActionButton.layer.borderColor = UIColor.clear.cgColor
        self.secondaryActionButton.isEnabled = true
        
        self.uploadFiles { [unowned self] in
            self.completeSurvey {

            } onFailure: { (error) in

            }
        } failure: { [unowned self] in
            self.goForward()
        }
    }
    
    fileprivate func uploadFiles(success: @escaping() -> Void, failure: @escaping() -> Void) {
        self.showSpinner()
        let coughRecordUploader = CoughRecordUploader()
        coughRecordUploader.uploadCoughTestFiles {
            success()
            coughRecordUploader.removeDirectory()
        } failure: { [unowned self] (message) in
            DispatchQueue.main.async {
                self.removeSpinner()
                let tryAction = UIAlertAction(title: "Try Again", style: .default) { [unowned self] (_) in
                    self.uploadFiles(success: success, failure: failure)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
                    coughRecordUploader.removeDirectory()
                    failure()
                }
                Alert(title: "Upload Error", message: "Unable to upload cough recordings. Would you like to try again?", actions: tryAction, cancelAction)
            }
        }
    }
    
    @objc func doViewResults() {
        let progressView = CoughTestResultProgressViewController()
        progressView.delegate = self
        NavigationUtility.presentOverCurrentContext(destination: progressView, style: .overFullScreen, transitionStyle: .crossDissolve, completion: nil)
    }
}

extension CoughTestCompleteViewController: CoughTestResultCancelDelegate {
    func cancel() {
        self.goForward()
    }
}
