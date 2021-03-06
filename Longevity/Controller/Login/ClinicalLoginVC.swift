//
//  ClinicalLoginVC.swift
//  Longevity
//
//  Created by vivek on 24/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class ClinicalLoginVC: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var clinicalTrialImageView: UIView!
    @IBOutlet weak var personalImageView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "#F5F6FA")
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 24.0)!,
                                                                        NSAttributedString.Key.foregroundColor: UIColor(hexString: "#4E4E4E")]
        
        self.view.backgroundColor = UIColor(hexString: "#F5F6FA")
        highlightImageButton(imgButton: clinicalTrialImageView)
        customizeImageButton(imgButton: clinicalTrialImageView)
        customizeImageButton(imgButton: personalImageView)
        normalizeImageButton(imgButton: personalImageView)
        self.removeBackButtonNavigation()
    }

    func customizeImageButton(imgButton: UIView){
        imgButton.layer.masksToBounds = true
        imgButton.layer.borderWidth = 2
        imgButton.layer.cornerRadius = 10
    }

    func normalizeImageButton(imgButton: UIView){
        imgButton.layer.borderColor = #colorLiteral(red: 0.9176470588, green: 0.9294117647, blue: 0.9450980392, alpha: 1)
        imgButton.tintColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
        for subview in imgButton.subviews{
            if let item = subview as? UIImageView{
                item.image = item.image?.withRenderingMode(.alwaysTemplate)
                item.tintColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
            }
        }
    }

    func highlightImageButton(imgButton: UIView){
        imgButton.layer.borderColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
        imgButton.tintColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
        for subview in imgButton.subviews{
            if let item = subview as? UIImageView{
                item.image = item.image?.withRenderingMode(.alwaysTemplate)
                item.tintColor = #colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1)
            }
        }
    }

    // MARK: Actions
    @IBAction func handlePersonalLogin(_ sender: Any) {
        performSegue(withIdentifier: "UnwindClinicalToPersonalLogin", sender: self)
    }
}
